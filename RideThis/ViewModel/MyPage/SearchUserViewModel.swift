import Foundation
import Combine

class SearchUserViewModel {
    @Published var users: [User] = []
    @Published var searchText: String = ""
    private var cancellable = Set<AnyCancellable>()
    private let firebaseService = FireBaseService()
    private let signedUser = UserService.shared.combineUser
    
    init() {
        self.$searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                
                Task {
                    await self.searchUser(text: text)
                }
            }
            .store(in: &cancellable)
    }
    
    func searchUser(text: String) async {
        let searchedUsers = await firebaseService.findUser(text: text)
        guard let signedUser = self.signedUser else { return }
        users = searchedUsers.filter { user in
            !signedUser.user_following.contains(user.user_id) && signedUser.user_id != user.user_id && user.user_account_public == false
        }
    }
}
