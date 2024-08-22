import Foundation
import Combine

class SearchUserViewModel {
    @Published var searchedUser: [User] = []
    private let firebaseService = FireBaseService()
    private let userService = UserService.shared
    private var allUsers: [User] = []
    
    init() {
        Task {
            do {
                let allUserDocs = try await firebaseService.fetchAllUsers()
                for doc in allUserDocs {
                    let user = try doc.data(as: User.self)
                    allUsers.append(user)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func searchUser(text: String) {
        guard let signedUser = userService.combineUser else { return }
        
        let filteredUser = allUsers.filter { $0.user_nickname.contains(text) || $0.user_email.contains(text) }
        let filteredFollowUser = filteredUser.filter { user in
            !signedUser.user_following.contains(user.user_id)
        }
        searchedUser = filteredFollowUser
    }
}
