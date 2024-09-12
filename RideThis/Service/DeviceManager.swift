
import Foundation

class DeviceManager {
    static let shared = DeviceManager()
    
    var isCompetetionUse: Bool = false
    var isRecordUse: Bool = false
    
    private init() {}
}
