import Foundation
import CoreLocation
import WeatherKit
import Combine

class HomeViewModel: NSObject, CLLocationManagerDelegate {
    // MARK: - Published Properties
    @Published var model: HomeModel
    @Published var currentWeather: Weather?
    @Published var locationName: String = "Location not found."
    @Published var hourlyForecast: [HourWeather] = []
    
    // MARK: - Private Properties
    private let firebaseService = FireBaseService()
    private let userService = UserService.shared
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService.shared
    
    // MARK: - Computed Properties
    /// 사용자의 로그인 상태를 확인
    var isUserLoggedIn: Bool {
        return UserService.shared.loginStatus == .appleLogin
    }
    
    // MARK: - Initialization
    override init() {
        let initialWeeklyRecord = WeeklyRecord(runCount: 0, runTime: "0시간 0분", runDistance: 0.0)
        self.model = HomeModel(weeklyRecord: initialWeeklyRecord, userName: "")
        super.init()
        
        setupLocationManager()
    }
    
    // MARK: - Location Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        requestLocation()
    }
    
    /// 위치 정보 요청
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    /// 사용자 기록 가져오기
    func fetchUserRecords(user: User) async {
        do {
            let allRecords = await firebaseService.findRecordsBy(userId: user.user_id)
            
            var records = allRecords
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            records = records.filter{ $0.record_data! >= oneWeekAgo }
            
            let sortedRecords = records.sorted { $0.record_start_time ?? Date() > $1.record_start_time ?? Date() }
            let recentRecords = Array(sortedRecords.prefix(7))
            
            let runCount = records.count
            let runTime = calculateTotalRunTime(records: recentRecords)
            let runDistance = recentRecords.reduce(0.0) { $0 + $1.record_distance }
            
            DispatchQueue.main.async {
                let weeklyRecord = WeeklyRecord(runCount: runCount, runTime: self.formatRunTime(seconds: runTime), runDistance: runDistance)
                self.model = HomeModel(weeklyRecord: weeklyRecord, userName: user.user_nickname)
            }
        }
    }
    
    /// 총 달린 시간 계산
    private func calculateTotalRunTime(records: [RecordModel]) -> Int {
        records.reduce(0) { total, record in
            guard let startTime = record.record_start_time,
                  let endTime = record.record_end_time else {
                return total
            }
            return total + Int(endTime.timeIntervalSince(startTime))
        }
    }
    
    /// 달린 시간을 문자열로 포맷
    private func formatRunTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)시간 \(minutes)분"
    }
    
    // MARK: - Weather Methods
    /// 특정 위치의 날씨 정보 가져오기
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
    
    /// 위치 이름 가져오기
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
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            Task {
                await fetchWeather(for: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    
    // MARK: 로그인 시 User에 FCM토큰
    func fetchAddFCM() {
        if let fcmToken = TokenManager.shared.fcmToken {
            Task {
                do {
                    guard let user = self.userService.combineUser else { return }
                    try await self.firebaseService.updateUserFCMToken(userId: user.user_id, fcmToken: fcmToken)
                    print("FCM 토큰 업데이트")
                } catch {
                    print("FCM 토큰 업데이트 실패: \(error)")
                }
            }
        } else {
            print("FCM token을 찾을 수 없습니다.")
        }
    }
    
    // MARK: 알람 개수 가져오기
    func getAlarmCount(userId: String) async -> Int {
        return await firebaseService.fetchAlarms(userId: userId).filter{ $0.alarm_status == false }.count
    }
}
