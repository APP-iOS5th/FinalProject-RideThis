import Foundation
import Combine

class SearchUserViewModel {
    @Published var users: [User] = []
    @Published var searchText: String = ""
    private var cancellable = Set<AnyCancellable>()
    private let firebaseService = FireBaseService()
    var signedUser: User
    
    init(user: User) {
        self.signedUser = user
        
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
        users = searchedUsers.filter { user in
            !signedUser.user_following.contains(user.user_id)
        }
    }
}
