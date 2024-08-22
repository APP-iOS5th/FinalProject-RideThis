import Foundation
import Combine

enum FollowType {
    case follower
    case following
}

class FollowManageViewModel {
    
    @Published var showingData: [User] = []
    private var followers: [User] = []
    private var followings: [User] = []
    private let userService = UserService.shared
    private let firebaseService = FireBaseService()
    
    init() {
        Task {
            await fetchFollow()
        }
    }
    
    func fetchFollow() async {
        guard let user = userService.combineUser else { return }
        for userId in user.user_follower {
            do {
                if case .user(let userCollection) = try await firebaseService.fetchUser(at: userId, userType: true) {
                    guard let existUser = userCollection else { continue }
                    followers.append(existUser)
                }
            } catch {
                print(error)
            }
        }
        
        for userId in user.user_following {
            do {
                if case .user(let userCollection) = try await firebaseService.fetchUser(at: userId, userType: true) {
                    guard let existUser = userCollection else { continue }
                    followings.append(existUser)
                }
            } catch {
                print(error)
            }
        }
        
        showingData = followers
    }
    
    func changeSegmentValue(type: FollowType) {
        switch type {
        case .follower:
            self.showingData = self.followers
        case .following:
            self.showingData = self.followings
        }
    }
    
    func isEachFollow(userId: String) -> Bool {
        return followings.contains(where: { $0.user_id == userId })
    }
    
    func searchUser(text: String, type: FollowType) {
        let target = type == .follower ? followers : followings
        if text.count > 0 {
            let filteredUser = target.filter{ $0.user_nickname.contains(text) || $0.user_email.contains(text) }
            self.showingData = filteredUser
        } else {
            self.showingData = target
        }
    }
}
