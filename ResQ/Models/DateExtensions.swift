import Foundation

extension Date {
    var iso8601: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    init?(iso8601: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso8601) else {
            return nil
        }
        self = date
    }
}

