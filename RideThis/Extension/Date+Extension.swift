import Foundation

extension Date {
    static func getDateDiff(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute], from: startDate, to: endDate)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        print("hours >> \(hours)")
        print("minutes >> \(minutes)")
        
        return (hours * 60) + minutes
    }
}
