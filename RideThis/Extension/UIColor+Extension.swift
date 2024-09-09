import UIKit

extension UIColor {
    
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
