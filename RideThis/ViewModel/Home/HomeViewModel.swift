import Foundation
import CoreLocation
import WeatherKit
import Combine

class HomeViewModel: NSObject, CLLocationManagerDelegate {
    @Published var model: HomeModel
    
    // MARK: Weather, Location
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService.shared
    @Published var currentWeather: Weather?
    @Published var locationName: String = "지역을 찾을 수 없습니다."
    @Published var hourlyForecast: [HourWeather] = []
    
    override init() {
        let weeklyRecord = HomeModel.WeeklyRecord(runCount: 6, runTime: "15시간 34분", runDistance: 404.51)
        self.model = HomeModel(weeklyRecord: weeklyRecord, userName: "전두광")
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        requestLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    // MARK: Weather
    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            await MainActor.run {
                self.currentWeather = weather

                let endDate = Date().addingTimeInterval(6 * 3600)
                self.hourlyForecast = weather.hourlyForecast.forecast.filter { $0.date <= endDate }
            }
            await fetchLocationName(for: location)
        } catch {
            print("Weather Error: \(error.localizedDescription)")
        }
    }
    
    func fetchLocationName(for location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                DispatchQueue.main.async {
                    self.locationName = placemark.locality ?? placemark.name ?? "지역을 찾을 수 없습니다."
                }
            }
        } catch {
            print("지역 오류: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("@@@@Location: \(location)")
            Task {
                await fetchWeather(for: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
}
