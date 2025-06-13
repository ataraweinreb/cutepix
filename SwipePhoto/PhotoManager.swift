import Foundation
import Photos

class PhotoManager: ObservableObject {
    @Published var photoMonths: [PhotoMonth] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    private var monthsCache: [PhotoMonth] = []
    private var lastPhotoCount: Int = 0
    
    init() {
        checkPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(photoLibraryChanged), name: .PHPhotoLibraryDidChange, object: nil)
    }
    
    func checkPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }
    
    @objc func photoLibraryChanged() {
        // Invalidate cache and refetch
        monthsCache = []
        fetchPhotos()
    }
    
    func fetchPhotos() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if self.monthsCache.isEmpty || assets.count != self.lastPhotoCount {
                var grouped: [String: [PHAsset]] = [:]
                assets.enumerateObjects { asset, _, _ in
                    guard let date = asset.creationDate else { return }
                    let comps = Calendar.current.dateComponents([.year, .month], from: date)
                    let key = "\(comps.year!)-\(comps.month!)"
                    grouped[key, default: []].append(asset)
                }
                let months = grouped.map { (key, assets) -> PhotoMonth in
                    let comps = key.split(separator: "-")
                    return PhotoMonth(month: Int(comps[1])!, year: Int(comps[0])!, assets: assets)
                }
                .sorted { ($0.year, $0.month) > ($1.year, $1.month) }
                self.monthsCache = months
                self.lastPhotoCount = assets.count
            }
            DispatchQueue.main.async {
                self.photoMonths = self.monthsCache
                self.isLoading = false
            }
        }
    }
} 
