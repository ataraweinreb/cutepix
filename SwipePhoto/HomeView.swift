import SwiftUI
import Photos
import PhotosUI

import SwiftUI

struct HomeView: View {
    @ObservedObject var photoManager: PhotoManager
    @State private var selectedMonth: PhotoMonth?
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var showSettings = false
    @State private var headerHidden: Bool = false
    @State private var lastOffset: CGFloat = 0
    @State private var showPaywall = false
    @AppStorage("isPremium") private var isPremium: Bool = false
    @AppStorage("totalSwipes") private var totalSwipes: Int = 0
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.0), Color(red: 1.0, green: 0.24, blue: 0.49)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    headerView
                        .offset(y: headerHidden ? -120 : 0)
                        .animation(.easeInOut(duration: 0.25), value: headerHidden)
                    Button("Show Paywall (Test)") { showPaywall = true }
                        .padding(.bottom, 8)
                    ScrollView {
                        ScrollOffsetReader()
                            .frame(height: 0)
                        let columns: [GridItem] = [
                            GridItem(.adaptive(minimum: UIScreen.main.bounds.width > 600 ? 220 : 160, maximum: UIScreen.main.bounds.width > 600 ? 260 : 200), spacing: 16)
                        ]
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(menuItems, id: \ .id) { item in
                                MenuCardView(item: item, recentsCount: item.month?.assets.count ?? 0) {
                                    if let month = item.month, !month.assets.isEmpty {
                                        if isPremium || (totalSwipes < 3 && !hasSeenPaywall) {
                                            selectedMonth = month
                                        } else {
                                            showPaywall = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                    }
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        let delta = value - lastOffset
                        if abs(delta) > 6 {
                            if delta < 0 {
                                headerHidden = true
                            } else if delta > 0 {
                                headerHidden = false
                            }
                            lastOffset = value
                        }
                    }
                    .sheet(item: $selectedMonth) { month in
                        PhotoSwipeView(month: month, onBatchDelete: {
                            photoManager.fetchPhotos()
                        })
                    }
                }
                
                if photoManager.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(2)
                                Text("Loading Photos...")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onUnlock: {
                isPremium = true
                showPaywall = false
                totalSwipes = 0
                hasSeenPaywall = false
            })
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                showOnboarding = false
            }
        }
        .onAppear {
            if photoManager.authorizationStatus == .authorized || photoManager.authorizationStatus == .limited {
                photoManager.fetchPhotos()
            }
        }
    }
    
    var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Color Clean")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .overlay(
                        LinearGradient(
                            colors: [
                                .red, .orange, .yellow, .green, .blue, .indigo, .purple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Color Clean")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                        )
                    )
                Text("choose a month to sort and delete photos.")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(8)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
        .background(Color.white.opacity(0.01))
    }
    
    var menuItems: [MenuItem] {
        photoManager.photoMonths.map { month in
            let style = styleForMonth(title: month.title)
            return MenuItem(
                id: month.id.uuidString,
                title: month.title.uppercased(),
                style: style,
                badge: false,
                month: month
            )
        }
    }
    
    func styleForMonth(title: String) -> MenuCardStyle {
        let baseFont = Font.system(size: 36, weight: .semibold, design: .serif)
        let baseTextCase: Text.Case? = .none
        let upper = title.uppercased()
        if upper.contains("JAN") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.0, green: 0.36, blue: 0.92), // deep blue
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.36, blue: 0.92), Color(red: 0.0, green: 0.78, blue: 0.98)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "sparkles",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("FEB") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.95, green: 0.18, blue: 0.36), // punchy pink
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.0, blue: 0.4), Color(red: 1.0, green: 0.76, blue: 0.44)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "heart.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("MAR") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.0, green: 0.7, blue: 0.3), // bold green
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 1.0, blue: 0.5), Color(red: 0.0, green: 0.8, blue: 0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "leaf.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("APR") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.0, green: 0.5, blue: 0.7), // teal blue
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.9, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "cloud.rain.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("MAY") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.95, green: 0.7, blue: 0.0), // gold
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 1.0, green: 0.5, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "flower",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("JUN") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.8, green: 0.0, blue: 0.8), // magenta
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.0, blue: 1.0), Color(red: 1.0, green: 0.7, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "sun.max.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("JUL") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 1.0, green: 0.3, blue: 0.0), // orange red
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.2, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "flame.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("AUG") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.0, green: 0.7, blue: 0.5), // teal
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 1.0, blue: 0.7), Color(red: 0.0, green: 0.5, blue: 0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "drop.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("SEP") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.5, green: 0.2, blue: 0.8), // purple
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.5, green: 0.2, blue: 0.8), Color(red: 0.0, green: 0.8, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "book.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("OCT") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 1.0, green: 0.4, blue: 0.0), // orange
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.4, blue: 0.0), Color(red: 1.0, green: 0.0, blue: 0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "moon.stars.fill",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("NOV") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.3, green: 0.3, blue: 0.3), // dark gray
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.7, green: 0.7, blue: 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "wind",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        } else if upper.contains("DEC") {
            return MenuCardStyle(
                font: baseFont,
                textColor: Color(red: 0.0, green: 0.2, blue: 1.0), // electric blue
                background: AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.2, blue: 1.0), Color(red: 0.0, green: 0.6, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)),
                icon: "snowflake",
                iconColor: Color.white.opacity(0.8),
                textCase: baseTextCase
            )
        }
        // Default style for other months
        return MenuCardStyle(
            font: baseFont,
            textColor: Color.black,
            background: AnyView(Color.gray.opacity(0.2)),
            icon: "star.fill",
            iconColor: Color.black.opacity(0.7),
            textCase: baseTextCase
        )
    }
}

struct MenuCardStyle {
    let font: Font
    let textColor: Color
    let background: AnyView
    let icon: String?
    let iconColor: Color?
    let textCase: Text.Case?
}

struct MenuItem: Identifiable {
    let id: String
    let title: String
    let style: MenuCardStyle
    var badge: Bool = false
    var month: PhotoMonth? = nil
    var imageBackground: String? = nil
}

struct SettingsView: View {
    var body: some View {
        VStack { Spacer(); Text("Settings").font(.largeTitle); Spacer() }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollOffsetReader: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
        }
    }
}

import SwiftUI
import Photos

struct MenuCardView: View {
    let item: MenuItem
    var recentsCount: Int = 0
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            Button(action: action) {
                VStack(alignment: .center, spacing: size * 0.05) {
                    if let month = item.month {
                        PolaroidStack(assets: month.assets, maxCount: 3, thumbSize: size * 0.28)
                            .padding(.top, size * 0.03)
                    } else {
                        // Placeholder skeleton
                        RoundedRectangle(cornerRadius: size * 0.06)
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: size * 0.82, height: size * 0.82)
                            .shimmer()
                            .padding(.top, size * 0.03)
                    }
                    Text(item.title)
                        .font(.system(size: size * 0.18, weight: .semibold, design: .serif))
                        .foregroundColor(.black)
                        .kerning(1.5)
                        .textCase(item.style.textCase)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("\(recentsCount) photos")
                        .font(.system(size: size * 0.10, weight: .regular))
                        .foregroundColor(.gray)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .padding(size * 0.11)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(item.style.background)
                .cornerRadius(size * 0.16)
                .shadow(color: Color.black.opacity(0.10), radius: size * 0.06, x: 0, y: size * 0.02)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PolaroidStack: View {
    let assets: [PHAsset]
    let maxCount: Int
    var thumbSize: CGFloat = 64

    var body: some View {
        let indices = polaroidIndices(assetCount: assets.count, maxCount: maxCount)
        ZStack {
            ForEach(Array(indices.enumerated()), id: \ .element) { idx, assetIdx in
                PolaroidThumbnail(asset: assets[assetIdx], size: thumbSize)
                    .rotationEffect(.degrees(Double(idx - 1) * 8))
                    .offset(x: CGFloat(idx - 1) * thumbSize * 0.45)
                    .zIndex(Double(idx))
            }
        }
        .frame(width: CGFloat(maxCount) * thumbSize * 0.7 + thumbSize * 0.7, height: thumbSize * 1.45)
    }

    func polaroidIndices(assetCount: Int, maxCount: Int) -> [Int] {
        guard assetCount > 0 else { return [] }
        if assetCount == 1 { return [0] }
        if assetCount == 2 { return [0, assetCount-1] }
        if assetCount == 3 { return [0, assetCount/2, assetCount-1] }
        // For more than 3, pick first, middle, last
        let first = 0
        let mid = assetCount / 2
        let last = assetCount - 1
        return [first, mid, last]
    }
}

struct PolaroidThumbnail: View {
    let asset: PHAsset
    var size: CGFloat = 64
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            // Outer polaroid frame (1:1 aspect)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                // Photo window (square, centered)
                ZStack {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: size * 0.82, height: size * 0.82)
                            .clipped()
                    } else {
                        Color.gray
                            .frame(width: size * 0.82, height: size * 0.82)
                    }
                }
                .background(Color.white)
                // Even top/side borders, no corner radius on photo
                Spacer(minLength: 0)
            }
            .frame(width: size, height: size)
            .background(
                ZStack {
                    Color.white
                    // Optional: subtle dot pattern overlay for texture
                    // If you want a texture, you could use an overlay image here
                }
            )
            .overlay(
                // Thicker bottom border
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: size * 0.22)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.06)
                    .stroke(Color.gray.opacity(0.18), lineWidth: size * 0.018)
            )
            .cornerRadius(size * 0.06)
            .shadow(color: Color.black.opacity(0.18), radius: size * 0.13, y: size * 0.09)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = false
            options.resizeMode = .fast
            manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: options) { img, _ in
                self.image = img
            }
        }
    }
}

// Shimmer effect for skeletons
import SwiftUI
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.4), Color.clear]), startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase * 350)
                    .blendMode(.plusLighter)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
extension View {
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
} 
