import Foundation
import UIKit

protocol UpdateUserDelegate {
    func updateUser(user: User)
}

protocol ProfileImageUpdateDelegate {
    func imageUpdate(image: UIImage)
}
