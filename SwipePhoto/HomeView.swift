import SwiftUI
import Photos
import PhotosUI
import SDWebImageSwiftUI

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
    @State private var showFAQ = false
    @State private var refreshID = UUID()
    @State private var showReviewAgainTray = false
    @State private var monthToReviewAgain: PhotoMonth? = nil
    
    let rainbowGradients: [LinearGradient] = [
        // 1. Hot pink → peach
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.2, blue: 0.7), Color(red: 1.0, green: 0.5, blue: 0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 2. Rich purple → blue
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.5, blue: 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 3. Vibrant aqua → sky blue
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.9, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 4. Deep pink → lavender
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.9, green: 0.3, blue: 0.8), Color(red: 0.7, green: 0.5, blue: 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 5. Coral → golden
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.5, blue: 0.4), Color(red: 0.95, green: 0.8, blue: 0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 6. Emerald → teal
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.9, blue: 0.7), Color(red: 0.2, green: 0.7, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 7. Sunset orange → pink
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.5, blue: 0.4), Color(red: 0.9, green: 0.3, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 8. Royal blue → purple
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.6, green: 0.3, blue: 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 9. Deep fuchsia → magenta
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.9, green: 0.2, blue: 0.5), Color(red: 0.8, green: 0.2, blue: 0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 10. Golden → mint
        LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 0.4, green: 0.9, blue: 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 11. Deep coral → pink
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.5, blue: 0.4), Color(red: 0.95, green: 0.2, blue: 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing),
        // 12. Deep blue → aqua
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.3, green: 0.9, blue: 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red:0.13, green:0.09, blue:0.23),
                        Color(red:0.18, green:0.13, blue:0.32),
                        Color(red:0.22, green:0.09, blue:0.32),
                        Color(red:0.13, green:0.13, blue:0.23),
                        Color.purple.opacity(0.7),
                        Color.blue.opacity(0.7),
                        Color.pink.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Button(action: { showFAQ = true }) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                                .clipShape(Circle())
                                .shadow(radius: 2, y: 1)
                        }
                        .padding(.leading, 14)
                        .sheet(isPresented: $showFAQ) {
                            SettingsFAQView()
                        }
                        Spacer()
                        Text("Color Clean")
                            .font(.custom("Poppins-SemiBold", size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 5, x: 0, y: 2)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                                .clipShape(Circle())
                                .shadow(radius: 2, y: 1)
                        }
                        .padding(.trailing, 14)
                        .sheet(isPresented: $showSettings) {
                            SettingsMainView()
                        }
                    }
                    .frame(height: 80)
                    .padding(.horizontal, 14)
                    Divider()
                        .frame(height: 1)
                        .background(Color.white.opacity(0.09))
                    if photoManager.authorizationStatus == .denied || photoManager.authorizationStatus == .restricted {
                        ZStack {
                            Color.clear // for layout
                            VStack(spacing: 36) {
                                Text("Hey bestie! 🦄✨")
                                    .font(.custom("Poppins-SemiBold", size: 28))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.85), radius: 4, x: 0, y: 2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                Text("Color Clean needs access to your photos to help you clean your camera roll. 📸🧼")
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.85), radius: 4, x: 0, y: 2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                Image("camera-permissions")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 340, maxHeight: 220)
                                    .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 6)
                                    .padding(.vertical, 16)
                                PulsingButton(
                                    title: "Open Settings",
                                    subtitle: "",
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    action: {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    },
                                    disabled: false
                                )
                                .frame(height: 72)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 0)
                                .padding(.bottom, 0)
                                .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 7)
                                .shadow(color: Color.yellow.opacity(0.18), radius: 10, x: 0, y: 3)
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 32)
                            Spacer(minLength: 0)
                        }
                    } else {
                        //                        Button("Show Paywall (Test)") { showPaywall = true }
                        //                            .padding(.bottom, 8)
                        ScrollView {
                            ScrollOffsetReader()
                                .frame(height: 0)
                            let columns: [GridItem] = [
                                GridItem(.adaptive(minimum: UIScreen.main.bounds.width > 600 ? 220 : 160, maximum: UIScreen.main.bounds.width > 600 ? 260 : 200), spacing: 18)
                            ]
                            LazyVGrid(columns: columns, spacing: 28) {
                                if photoManager.isLoading && photoManager.photoMonths.isEmpty {
                                    ForEach(0..<10, id: \ .self) { index in
                                        ShimmerAlbumCard(gradient: rainbowGradients[index % rainbowGradients.count])
                                    }
                                } else {
                                    ForEach(Array(menuItems.enumerated()), id: \ .element.id) { index, item in
                                        MenuCardView(item: item, recentsCount: item.month?.assets.count ?? 0, gradient: rainbowGradients[index % rainbowGradients.count]) {
                                            if let month = item.month, !month.assets.isEmpty {
                                                if month.status == .completed {
                                                    monthToReviewAgain = month
                                                    showReviewAgainTray = true
                                                } else if isPremium || (totalSwipes < 3 && !hasSeenPaywall) {
                                                    selectedMonth = month
                                                } else {
                                                    showPaywall = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal, 14)
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
                        .sheet(item: $selectedMonth, onDismiss: {
                            if let month = selectedMonth {
                                let statusString = UserDefaults.standard.string(forKey: month.statusKey) ?? "notStarted"
                                let status = AlbumStatus(rawValue: statusString) ?? .notStarted
                                photoManager.updateStatus(for: month.month, year: month.year, status: status)
                            }
                        }) { month in
                            PhotoSwipeView(month: month, onBatchDelete: {
                                let statusString = UserDefaults.standard.string(forKey: month.statusKey) ?? "notStarted"
                                let status = AlbumStatus(rawValue: statusString) ?? .notStarted
                                photoManager.updateStatus(for: month.month, year: month.year, status: status)
                            }, photoManager: photoManager)
                        }
                        .confirmationDialog("This album is already done. Review again?", isPresented: $showReviewAgainTray, titleVisibility: .visible) {
                            Button("Review Again", role: .destructive) {
                                if let month = monthToReviewAgain {
                                    UserDefaults.standard.setValue("inProgress", forKey: month.statusKey)
                                    UserDefaults.standard.removeObject(forKey: "albumProgress-\(month.month)-\(month.year)")
                                    photoManager.updateStatus(for: month.month, year: month.year, status: .inProgress)
                                    selectedMonth = month
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                }
                .onAppear {
                    photoManager.objectWillChange.send()
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
        
        func gradientForMonth(_ title: String) -> LinearGradient {
            let upper = title.uppercased()
            if upper.contains("FEB") {
                // Red/Pink
                return LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.56, blue: 0.56), Color(red: 1.0, green: 0.74, blue: 0.83)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if upper.contains("MAR") {
                // Orange
                return LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if upper.contains("APR") {
                // Yellow
                return LinearGradient(gradient: Gradient(colors: [Color.yellow, Color(red: 1.0, green: 0.95, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if upper.contains("MAY") {
                // Green
                return LinearGradient(gradient: Gradient(colors: [Color.green, Color(red: 0.36, green: 0.98, blue: 0.56)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if upper.contains("JUN") {
                // Blue
                return LinearGradient(gradient: Gradient(colors: [Color.blue, Color(red: 0.36, green: 0.67, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if upper.contains("JAN") {
                // Purple/Blue
                return LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                // Default
                return LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        
        func emojiForMonth(_ title: String) -> String {
            let upper = title.uppercased()
            if upper.contains("JAN") { return "❄️" }
            if upper.contains("FEB") { return "💖" }
            if upper.contains("MAR") { return "🍀" }
            if upper.contains("APR") { return "🐣" }
            if upper.contains("MAY") { return "🌺" }
            if upper.contains("JUN") { return "🏳️‍🌈" }
            if upper.contains("JUL") { return "🇺🇸" }
            if upper.contains("AUG") { return "⛱️" }
            if upper.contains("SEP") { return "🍁" }
            if upper.contains("OCT") { return "🎃" }
            if upper.contains("NOV") { return "🦃" }
            if upper.contains("DEC") { return "🎅" }
            return "📅"
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
    
    
    struct MenuCardView: View {
        let item: MenuItem
        var recentsCount: Int = 0
        var gradient: LinearGradient
        var action: () -> Void
        
        var body: some View {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height / 0.95)
                Button(action: action) {
                    ZStack {
                        // Gradient background
                        gradient
                        VStack(alignment: .center, spacing: size * 0.06) {
                            // Emoji and month name in a row
                            HStack(spacing: size * 0.04) {
                                Text(emojiForMonth(item.title))
                                    .font(.system(size: size * 0.10, weight: .regular))
                                    .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Text(capitalizeFirst(item.title))
                                    .font(.custom("Poppins-SemiBold", size: size * 0.16))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 1)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                            // Polaroid stack
                            if let month = item.month {
                                PolaroidStack(assets: month.assets, maxCount: 3, thumbSize: size * 0.22, emoji: emojiForMonth(item.title))
                                    .padding(.top, size * 0.01)
                                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                            // Progress or photo count badge
                            if let month = item.month {
                                switch month.status {
                                case .inProgress:
                                    ProgressBadge(
                                        icon: "hourglass",
                                        color: Color(red: 1.0, green: 0.38, blue: 0.0),
                                        text: "In Prog",
                                        fontSize: size * 0.09
                                    )
                                    .frame(height: size * 0.17)
                                    .padding(.top, size * 0.01)
                                case .completed:
                                    ProgressBadge(
                                        icon: "checkmark",
                                        color: Color(red: 0.0, green: 0.78, blue: 0.32),
                                        text: "Done",
                                        fontSize: size * 0.09
                                    )
                                    .frame(height: size * 0.17)
                                    .padding(.top, size * 0.01)
                                case .notStarted:
                                    Text("\(recentsCount) photos")
                                        .font(.custom("Poppins-Medium", size: size * 0.08))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            } else {
                                Text("\(recentsCount) photos")
                                    .font(.custom("Poppins-Medium", size: size * 0.08))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                        .padding(.vertical, size * 0.06)
                        .padding(.horizontal, size * 0.06)
                    }
                    .frame(width: geo.size.width, height: geo.size.width * 0.95)
                    .background(Color.clear)
                    .cornerRadius(36)
                    .shadow(color: Color.black.opacity(0.18), radius: 22, x: 0, y: 10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .aspectRatio(1.05, contentMode: .fit)
        }
        
        func emojiForMonth(_ title: String) -> String {
            let upper = title.uppercased()
            if upper.contains("JAN") { return "❄️" }
            if upper.contains("FEB") { return "💖" }
            if upper.contains("MAR") { return "🍀" }
            if upper.contains("APR") { return "🐣" }
            if upper.contains("MAY") { return "🌺" }
            if upper.contains("JUN") { return "🏳️‍🌈" }
            if upper.contains("JUL") { return "🇺🇸" }
            if upper.contains("AUG") { return "⛱️" }
            if upper.contains("SEP") { return "🍁" }
            if upper.contains("OCT") { return "🎃" }
            if upper.contains("NOV") { return "🦃" }
            if upper.contains("DEC") { return "🎅" }
            return "📅"
        }
        
        // Helper function for capitalizing only the first letter
        func capitalizeFirst(_ str: String) -> String {
            guard let first = str.first else { return str }
            return first.uppercased() + str.dropFirst().lowercased()
        }
    }
    
    struct ProgressBadge: View {
        let icon: String
        let color: Color
        let text: String
        let fontSize: CGFloat
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fontSize * 1.2, height: fontSize * 1.2)
                    .foregroundColor(.white)
                Text(text)
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 18)
            .background(
                Capsule()
                    .fill(color)
            )
            .shadow(color: color.opacity(0.18), radius: 4, x: 0, y: 2)
        }
    }
    
    struct PolaroidStack: View {
        let assets: [PHAsset]
        let maxCount: Int
        var thumbSize: CGFloat = 64
        var emoji: String? = nil
        
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
                                .scaledToFill()
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
    
    struct ShimmerAlbumCard: View {
        var gradient: LinearGradient
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Simulate the polaroid/photo stack
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 80)
                    .shimmering()
                // Simulate the album title
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 100, height: 20)
                    .shimmering()
                // Simulate the photo count
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 60, height: 16)
                    .shimmering()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 180)
            .background(gradient)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }
    
    extension View {
        func shimmering() -> some View {
            self
                .modifier(ShimmerModifier())
        }
    }
    
    struct ShimmerModifier: ViewModifier {
        @State private var phase: CGFloat = 0
        func body(content: Content) -> some View {
            content
                .overlay(
                    GeometryReader { geo in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: -geo.size.width * 1.5 + phase * geo.size.width * 3)
                            .frame(width: geo.size.width * 1.5, height: geo.size.height)
                            .clipped()
                            .animation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
                            .onAppear { phase = 1 }
                    }
                )
        }
    }
    
    struct SwipeablePolaroidStack: View {
        let gifUrls: [String]
        let captions: [String]
        var cardSize: CGSize? = nil // Optional custom size
        @State private var currentIndex = 0
        @State private var offset: CGSize = .zero
        @GestureState private var dragState = CGSize.zero
        
        var body: some View {
            ZStack {
                ForEach((currentIndex..<min(currentIndex+3, gifUrls.count + 2)).reversed(), id: \.self) { idx in
                    let stackOffset = idx - currentIndex
                    PolaroidGifCard(
                        gifUrl: gifUrls[idx % gifUrls.count],
                        caption: captions[idx % captions.count],
                        baseRotation: Double(stackOffset) * 2.0,
                        cardSize: cardSize ?? CGSize(width: 200, height: 240)
                    )
                    .offset(
                        x: idx == currentIndex ? offset.width : CGFloat(stackOffset) * 7,
                        y: CGFloat(stackOffset) * 18
                    )
                    .rotationEffect(.degrees(idx == currentIndex ? Double(offset.width / 18) : Double(stackOffset) * 2.0))
                    .scaleEffect(idx == currentIndex ? 1.0 : 1.0 - CGFloat(stackOffset) * 0.04)
                    .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.5), value: offset)
                    .allowsHitTesting(idx == currentIndex)
                    .gesture(
                        idx == currentIndex ?
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                state = value.translation
                            }
                            .onChanged { gesture in
                                offset = gesture.translation
                            }
                            .onEnded { gesture in
                                let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                                let threshold: CGFloat = 80
                                if offset.width > threshold || velocity > 150 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset.width = UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        currentIndex = (currentIndex + 1) % gifUrls.count
                                        offset = .zero
                                    }
                                } else if offset.width < -threshold || velocity < -150 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset.width = -UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        currentIndex = (currentIndex + 1) % gifUrls.count
                                        offset = .zero
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset = .zero
                                    }
                                }
                            }
                        : nil
                    )
                }
            }
            .frame(height: (cardSize?.height ?? 240) + 30)
            .padding(.horizontal, 16)
        }
    }
    
    struct PolaroidGifCard: View {
        let gifUrl: String
        let caption: String
        let baseRotation: Double
        var cardSize: CGSize? = nil
        @State private var rotation: Double
        
        init(gifUrl: String, caption: String, baseRotation: Double = 0, cardSize: CGSize? = nil) {
            self.gifUrl = gifUrl
            self.caption = caption
            self.baseRotation = baseRotation
            self.cardSize = cardSize
            _rotation = State(initialValue: baseRotation + Double.random(in: -2...2))
        }
        
        var body: some View {
            let width = cardSize?.width ?? 200
            let height = cardSize?.height ?? 240
            VStack(spacing: 0) {
                // Polaroid image area
                ZStack {
                    Color.white
                    WebImage(url: URL(string: gifUrl))
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()
                        .frame(width: width * 0.78, height: width * 0.60)
                        .clipped()
                        .cornerRadius(width * 0.04)
                }
                .frame(width: width * 0.88, height: width * 0.68)
                .background(Color.white)
                .cornerRadius(width * 0.05)
                // Thicker bottom border for polaroid look
                Rectangle()
                    .fill(Color.white)
                    .frame(width: width * 0.88, height: width * 0.13)
                    .cornerRadius(width * 0.03, corners: [.bottomLeft, .bottomRight])
                // Caption
                Text(caption)
                    .font(.custom("Poppins-Regular", size: max(10, width * 0.10)))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .frame(width: width * 0.88)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.white)
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.03)
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1.2)
            )
            .cornerRadius(width * 0.03)
            .shadow(color: Color.black.opacity(0.18), radius: width * 0.03, x: 0, y: width * 0.015)
            .rotationEffect(.degrees(rotation))
        }
    }
    
    // Helper for corner radius on specific corners
    extension View {
        func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
            clipShape( RoundedCorner(radius: radius, corners: corners) )
        }
    }
    
    struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    struct SwirlyArrowSwipeHint: View {
        @State private var animate = false
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    SwirlyArrowShape()
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .frame(width: 70, height: 40)
                        .rotationEffect(.degrees(animate ? 8 : -8), anchor: .bottomLeading)
                        .offset(x: 0, y: 0)
                        .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: animate)
                    Text("swipe me! ⤵️")
                        .font(.custom("Poppins-Regular", size: 20))
                        .foregroundColor(.purple)
                        .offset(x: 50, y: 18)
                        .rotationEffect(.degrees(10))
                }
                .frame(height: 44)
            }
            .onAppear {
                animate = true
            }
        }
    }
    
    struct SwirlyArrowShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            // Swirly curve
            path.move(to: CGPoint(x: rect.minX + 10, y: rect.maxY - 10))
            path.addCurve(to: CGPoint(x: rect.maxX - 30, y: rect.minY + 18),
                          control1: CGPoint(x: rect.minX + 40, y: rect.maxY - 30),
                          control2: CGPoint(x: rect.maxX - 50, y: rect.minY + 40))
            // Arrowhead
            let tip = CGPoint(x: rect.maxX - 10, y: rect.minY + 10)
            path.addLine(to: tip)
            path.move(to: tip)
            path.addLine(to: CGPoint(x: tip.x - 16, y: tip.y + 10))
            path.move(to: tip)
            path.addLine(to: CGPoint(x: tip.x - 10, y: tip.y + 18))
            return path
        }
    }


