import Foundation

extension Int64 {
    static func generateId() -> Int64 {
        let date = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHmmssSSSS"
        
        return Int64(dateFormatter.string(from: date)) ?? -1
    }
}
