
import Foundation

extension Date {
    func relativeDisplay() -> String {
        let calendar = Calendar.current
        if let daysAgo = calendar.dateComponents([.day], from: self, to: Date()).day, daysAgo < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
}
