import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private init() {}
    
    func saveUnloginUserSummary(_ summaryData: SummaryData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(summaryData) {
            UserDefaults.standard.set(encoded, forKey: "UnloginUserSummary")
        }
    }
    
    func getUnloginUserSummary() -> SummaryData? {
        if let data = UserDefaults.standard.data(forKey: "UnloginUserSummary"),
           let summaryData = try? JSONDecoder().decode(SummaryData.self, from: data) {
            return summaryData
        }
        return nil
    }
    
    func clearUnloginUserSummary() {
        UserDefaults.standard.removeObject(forKey: "UnloginUserSummary")
    }
}
