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
        // Set loading state and clear existing data on the main thread
        DispatchQueue.main.async {
            self.isLoading = true
            self.photoMonths = []
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            guard assets.count > 0 else {
                    DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Group assets by month efficiently in the background
            var months: [DateComponents: [PHAsset]] = [:]
            let calendar = Calendar.current
            assets.enumerateObjects { (asset, _, _) in
                let components = calendar.dateComponents([.year, .month], from: asset.creationDate ?? Date())
                if months[components] != nil {
                    months[components]?.append(asset)
                } else {
                    months[components] = [asset]
                }
            }
            
            let sortedMonthKeys = months.keys.sorted {
                if $0.year != $1.year { return $0.year ?? 0 > $1.year ?? 0 }
                return $0.month ?? 0 > $1.month ?? 0
            }
            
            // Process and publish each month individually
            for key in sortedMonthKeys {
                let assetsForMonth = months[key] ?? []
                let month = key.month ?? 1
                let year = key.year ?? 1970
                let statusKey = "albumStatus-\(month)-\(year)"
                let statusString = UserDefaults.standard.string(forKey: statusKey) ?? "notStarted"
                let status = AlbumStatus(rawValue: statusString) ?? .notStarted
                let photoMonth = PhotoMonth(month: month, year: year, assets: assetsForMonth, status: status)
                
                // Send the new month to the UI
                DispatchQueue.main.async {
                    self.photoMonths.append(photoMonth)
                }
            }
            
            // Signal that loading is complete
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
