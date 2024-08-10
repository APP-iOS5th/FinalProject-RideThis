import UIKit

extension UIColor {
    
    /// 앱의 주 배경색 (튜나피셜 주색과 잘 어울리는 색)
    static var primaryBackgroundColor: UIColor {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "F5F1EB").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    /// 앱의 주색 (쉽게 말해서 주황색)
    static var primaryColor: UIColor {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "FB4800").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    /// 기록 / 경쟁에서 사용하는 Timer / Speed 등의 Title 색상
    static var recordTitleColor: UIColor {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "999999").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
