import Foundation

extension Date {
    func brFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyy H:mm:ss"
        
        return dateFormatter.string(from: self)
    }
}
