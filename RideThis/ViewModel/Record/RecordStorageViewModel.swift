//import Foundation
//import Combine
//import FirebaseFirestore
//
//class RecordStorageViewModel: ObservableObject {
//    private let firebaseService = FireBaseService()
//    
//    @Published var records: [RecordModel] = []
//    
//    func saveRecord(timer: String, cadence: Double, speed: Double, distance: Double, calorie: Double, startTime: Date, endTime: Date, date: Date, competitionStatus: Bool, targetDistance: Double?) {
//        Task {
//            do {
//                if let userSnapshot = try await firebaseService.fetchUser(at: "", userType: false) {
//                    let recordsCollection = firebaseService.fetchCollection(document: userSnapshot, collectionName: "RECORDS")
//                    try await firebaseService.fetchRecord(collection: recordsCollection, timer: timer, cadence: cadence, speed: speed, distance: distance, calorie: calorie, startTime: startTime, endTime: endTime, date: date, competetionStatus: competitionStatus, tagetDistance: targetDistance)
//                    print("Record saved successfully")
//                }
//            } catch {
//                print("Error saving record: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func fetchUserRecords(userId: String) {
//        Task {
//            do {
//                if let userSnapshot = try await firebaseService.fetchUser(at: userId) {
//                    let records = try await firebaseService.fetchAllRecordsForUsers([userSnapshot])
//                    DispatchQueue.main.async {
//                        self.records = records
//                    }
//                }
//            } catch {
//                print("Error fetching records: \(error.localizedDescription)")
//            }
//        }
//    }
//}
