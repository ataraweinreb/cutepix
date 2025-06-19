import Foundation
import Photos

struct PhotoMonth: Identifiable, Equatable {
    let id = UUID()
    let month: Int
    let year: Int
    let assets: [PHAsset]
    var status: AlbumStatus
    
    var title: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM ''yy"
        if let firstAsset = assets.first {
            let date = firstAsset.creationDate ?? Date()
            return dateFormatter.string(from: date).uppercased()
        }
        return "\(month)/\(year)"
    }

    var statusKey: String {
        "albumStatus-\(month)-\(year)"
    }
    
    static func == (lhs: PhotoMonth, rhs: PhotoMonth) -> Bool {
        lhs.id == rhs.id && lhs.month == rhs.month && lhs.year == rhs.year && lhs.assets == rhs.assets && lhs.status == rhs.status
    }
}

enum AlbumStatus: String, Equatable, Codable {
    case notStarted
    case inProgress
    case completed
} 
