import Foundation
import Combine

enum FollowType {
    case follower
    case following
}

class FollowManageViewModel {
    
    @Published var followDatas: [User] = []
    private let firebaseService = FireBaseService()
    
    func changeSegmentValue(user: User, type: FollowType) {
        Task {
            await self.fetchFollowData(user: user, type: type)
        }
    }
    
    func fetchFollowData(user: User, type: FollowType) async {
        let target = type == .follower ? user.user_follower : user.user_following
        do {
            followDatas = try await firebaseService.fetchUsers(by: target)
        } catch {
            print(error)
        }
    }
    
    func searchUser(text: String) {
        
    }
}
