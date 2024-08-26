import Foundation
import Combine

class MyPageViewModel {
    
    @Published var recordsData: [RecordModel] = []
    private var cancellable = Set<AnyCancellable>()
    var firebaseService: FireBaseService
    
    init(firebaseService: FireBaseService) {
        self.firebaseService = firebaseService
    }
    
    func getRecords(userId: String) async {
        recordsData = await firebaseService.findRecordsBy(userId: userId)
    }
}
