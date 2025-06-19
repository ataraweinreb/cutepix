import Foundation
import Photos

class PhotoManager: ObservableObject {
    @Published var photoMonths: [PhotoMonth] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0.0 // (can be removed from UI)
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        // Check current authorization status first
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        if currentStatus == .authorized || currentStatus == .limited {
            self.authorizationStatus = currentStatus
            self.fetchPhotos()
            return
        }
        
        // If not authorized, request authorization
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self.fetchPhotos()
                }
            }
        }
    }
    
    func fetchPhotos() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var currentMonthKey: String? = nil
            var currentAssets: [PHAsset] = []

            func appendCurrentMonthIfNeeded() {
                if let key = currentMonthKey, !currentAssets.isEmpty {
                    let comps = key.split(separator: "-")
                    let month = Int(comps[1])!
                    let year = Int(comps[0])!
                    let statusKey = "albumStatus-\(month)-\(year)"
                    let statusString = UserDefaults.standard.string(forKey: statusKey) ?? "notStarted"
                    let status = AlbumStatus(rawValue: statusString) ?? .notStarted
                    let photoMonth = PhotoMonth(month: month, year: year, assets: currentAssets, status: status)
                    DispatchQueue.main.async {
                        self.photoMonths.append(photoMonth)
                    }
                }
            }

            DispatchQueue.main.async {
                self.photoMonths = []
            }
        
        assets.enumerateObjects { asset, _, _ in
                guard let asset = asset as? PHAsset else { return }
            guard let date = asset.creationDate else { return }
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            let key = "\(comps.year!)-\(comps.month!)"
                if key != currentMonthKey {
                    appendCurrentMonthIfNeeded()
                    currentMonthKey = key
                    currentAssets = []
                }
                currentAssets.append(asset)
            }
            // Append the last month
            appendCurrentMonthIfNeeded()
        DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    // Add this method to update status for a specific month
    func updateStatus(for month: Int, year: Int, status: AlbumStatus) {
        if let index = photoMonths.firstIndex(where: { $0.month == month && $0.year == year }) {
            photoMonths[index].status = status
        }
    }
} 
