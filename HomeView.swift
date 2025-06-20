@State private var monthToReviewAgain: PhotoMonth? = nil
@State private var isPremium: Bool = UserDefaults.standard.bool(forKey: "isPremium")
@State private var totalSwipes: Int = UserDefaults.standard.integer(forKey: "totalSwipes")
@State private var hasSeenPaywall: Bool = UserDefaults.standard.bool(forKey: "hasSeenPaywall")
@State private var isReadyToReviewMonth = false

// For header scroll animation
@State private var headerHidden = false 

let columns: [GridItem] = [
    GridItem(.adaptive(minimum: UIScreen.main.bounds.width > 600 ? 220 : 160, maximum: UIScreen.main.bounds.width > 600 ? 260 : 200), spacing: 18)
]

LazyVGrid(columns: columns, spacing: 28) {
    if photoManager.isLoading && photoManager.photoMonths.isEmpty {
        ForEach(0..<10, id: \.self) { index in
            ShimmerAlbumCard(gradient: rainbowGradients[index % rainbowGradients.count])
        }
    } else {
        ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
            MenuCardView(item: item, recentsCount: item.month?.assets.count ?? 0, gradient: rainbowGradients[index % rainbowGradients.count]) {
                if let month = item.month, !month.assets.isEmpty {
                    if month.status == .completed {
                        monthToReviewAgain = month
                    }
                }
            }
        }
    }
}
.padding(.vertical, 24)
.padding(.horizontal, 14) 