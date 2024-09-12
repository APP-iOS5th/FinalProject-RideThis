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
    
    func fetchFollowData(user: User, type: FollowType, search text: String? = nil) async {
        let target = type == .follower ? user.user_follower : user.user_following
        do {
            let followUsers = try await firebaseService.fetchUsers(by: target)
            if let text = text {
                followDatas = followUsers.filter{ $0.user_nickname.contains(text) || $0.user_email.contains(text) }
            } else {
                followDatas = followUsers
            }
        } catch {
            print(error)
        }
    }
    
    func searchUser(text: String, user: User, type: FollowType) {
        Task {
            await fetchFollowData(user: user, type: type, search: text.isEmpty ? nil : text)
        }
    }
}
