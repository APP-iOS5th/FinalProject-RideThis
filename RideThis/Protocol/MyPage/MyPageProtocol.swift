import Foundation
import UIKit

protocol UpdateUserDelegate {
    func updateUser(user: User)
}

protocol ProfileImageUpdateDelegate {
    func imageUpdate(image: UIImage)
}

protocol UserUnfollowDelegate {
    func unfollowUser(cellUser: User, signedUser: User, completion: @escaping ((User, User) -> Void))
}
