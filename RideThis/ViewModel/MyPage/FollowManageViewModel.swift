import Foundation
import Combine

enum FollowType {
    case follower
    case following
}

class FollowManageViewModel {
    
    @Published var followers: [User] = []
    @Published var followings: [User] = []
    private let userService = UserService.shared
    private let firebaseService = FireBaseService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        Task {
            await fetchFollow()
        }
        
        userService.$combineUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.fetchFollow()
                }
            }
            .store(in: &cancellable)
    }
    
    func fetchFollow() async {
        guard let user = userService.combineUser else { return }
        var tempFollowers: [User] = []
        for userId in user.user_follower {
            do {
                if case .user(let userCollection) = try await firebaseService.fetchUser(at: userId, userType: true) {
                    guard let existUser = userCollection else { continue }
                    tempFollowers.append(existUser)
                }
            } catch {
                print(error)
            }
        }
        followers = tempFollowers
        
        var tempFollowings: [User] = []
        for userId in user.user_following {
            do {
                if case .user(let userCollection) = try await firebaseService.fetchUser(at: userId, userType: true) {
                    guard let existUser = userCollection else { continue }
                    tempFollowings.append(existUser)
                }
            } catch {
                print(error)
            }
        }
        followings = tempFollowings
    }
    
    func changeSegmentValue(type: FollowType) {
        Task {
            await fetchFollow()
        }
    }
    
    func isEachFollow(userId: String) -> Bool {
        return followings.contains(where: { $0.user_id == userId })
    }
    
    func searchUser(text: String, type: FollowType) {
        let target = type == .follower ? followers : followings
        if text.count > 0 {
            let filteredUser = target.filter{ $0.user_nickname.contains(text) || $0.user_email.contains(text) }
            if type == .follower {
                followers = filteredUser
            } else {
                followings = filteredUser
            }
        } else {
            Task {
                await fetchFollow()
            }
        }
    }
    
    func unFollowUser(user: User) {
        guard let signedUser = userService.combineUser else { return }
        signedUser.user_following.remove(at: signedUser.user_following.firstIndex(of: user.user_id)!)
        firebaseService.updateUserInfo(user: signedUser)
        user.user_follower.remove(at: user.user_follower.firstIndex(of: signedUser.user_id)!)
        firebaseService.updateUserInfo(user: user, isProfileEdit: false)
        
        Task {
            await fetchFollow()
        }
    }
    
    func followUser(user: User) {
        guard let signedUser = userService.combineUser else { return }
        signedUser.user_following.append(user.user_id)
        firebaseService.updateUserInfo(user: signedUser)
        user.user_follower.append(signedUser.user_id)
        firebaseService.updateUserInfo(user: user, isProfileEdit: false)
        
        Task {
            await fetchFollow()
        }
    }
}
