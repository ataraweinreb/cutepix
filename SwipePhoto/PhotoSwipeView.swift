import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct PhotoSwipeView: View {
    let month: PhotoMonth
    var onBatchDelete: (() -> Void)? = nil
    @ObservedObject var photoManager: PhotoManager
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var keepCount = 0
    @State private var deleteCount = 0
    @State private var isAnimatingOff = false
    @GestureState private var dragState = CGSize.zero
    @State private var assetsToDelete: [PHAsset] = []
    @State private var isDeleting = false
    @State private var showDeleted = false
    @State private var buttonActionInProgress = false
    @State private var keepPressed = false
    @State private var deletePressed = false
    @State private var showConfetti = false
    @State private var showPaywall = false
    @AppStorage("isPremium") private var isPremium: Bool = false
    @AppStorage("totalSwipes") private var totalSwipes: Int = 0
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            handleSessionEnd()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Text(month.title)
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Text("\(min(currentIndex+1, month.assets.count))/\(month.assets.count)")
                            .foregroundColor(.white)
                            .font(.custom("Poppins-Regular", size: 16))
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, geo.safeAreaInsets.top + 8)
                    .padding(.bottom, 4)
                    Spacer(minLength: 0)
                    if isDeleting {
                        Color.black.opacity(0.7).ignoresSafeArea()
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                            Text("Deleting photos...")
                                .foregroundColor(.white)
                                .font(.custom("Poppins-Regular", size: 20))
                                .lineLimit(nil)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                    } else if month.assets.isEmpty {
                        Text("No photos in this month!")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    } else if !showDeleted {
                        ZStack {
                            ForEach((currentIndex..<min(currentIndex+2, month.assets.count)).reversed(), id: \.self) { idx in
                                PhotoCard(
                                    asset: month.assets[idx],
                                    offset: idx == currentIndex ? offset : .zero,
                                    overlayText: idx == currentIndex ? overlayText : nil
                                )
                                .offset(x: idx == currentIndex ? offset.width : 0, y: CGFloat(idx - currentIndex) * 10)
                                .rotationEffect(.degrees(idx == currentIndex ? Double(offset.width / 12) : 0))
                                .scaleEffect(idx == currentIndex ? 1.0 : 0.96)
                                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.5), value: offset)
                                .allowsHitTesting(idx == currentIndex && !buttonActionInProgress && canSwipe)
                                .gesture(
                                    idx == currentIndex && canSwipe ?
                                    DragGesture()
                                        .updating($dragState) { value, state, _ in
                                            state = value.translation
                                        }
                                        .onChanged { gesture in
                                            offset = gesture.translation
                                        }
                                        .onEnded { gesture in
                                            let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                                            let threshold: CGFloat = 100
                                            let shouldKeep = offset.width > threshold || velocity > 200
                                            let shouldDelete = offset.width < -threshold || velocity < -200
                                            if shouldKeep {
                                                animateKeep()
                                            } else if shouldDelete {
                                                animateDelete()
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
                        .frame(height: min(geo.size.height * 0.45, 340))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    Spacer(minLength: 0)
                    if !showDeleted {
                        HStack(spacing: 32) {
                            Spacer()
                            Button(action: {
                                if !buttonActionInProgress && currentIndex < month.assets.count && canSwipe {
                                    deletePressed = true
                                    animateDelete()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { deletePressed = false }
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text("DELETE")
                                        .font(.custom("Poppins-SemiBold", size: 18))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text("\(deleteCount)")
                                        .font(.custom("Poppins-SemiBold", size: 28))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 0)
                                        .padding(.vertical, 0)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                .frame(width: min(geo.size.width * 0.36, 140), height: min(geo.size.width * 0.36, 140))
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 3)
                                .scaleEffect(deletePressed ? 0.93 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: deletePressed)
                            }
                            .disabled(buttonActionInProgress || currentIndex >= month.assets.count || !canSwipe)
                            Spacer()
                            Button(action: {
                                if !buttonActionInProgress && currentIndex < month.assets.count && canSwipe {
                                    keepPressed = true
                                    animateKeep()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { keepPressed = false }
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text("KEEP")
                                        .font(.custom("Poppins-SemiBold", size: 18))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Text("\(keepCount)")
                                        .font(.custom("Poppins-SemiBold", size: 28))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 0)
                                        .padding(.vertical, 0)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                .frame(width: min(geo.size.width * 0.36, 140), height: min(geo.size.width * 0.36, 140))
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 3)
                                .scaleEffect(keepPressed ? 0.93 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: keepPressed)
                            }
                            .disabled(buttonActionInProgress || currentIndex >= month.assets.count || !canSwipe)
                            Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal, 0)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 18)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            // Overlay for centered confetti and message
            if showDeleted {
                ZStack {
                    // Dark rainbow gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red:0.18, green:0.09, blue:0.32), // deep purple
                            Color(red:0.22, green:0.09, blue:0.32), // indigo
                            Color(red:0.13, green:0.13, blue:0.23), // midnight blue
                            Color(red:0.35, green:0.13, blue:0.32), // magenta
                            Color(red:0.09, green:0.18, blue:0.32), // dark teal
                            Color(red:0.25, green:0.09, blue:0.32)  // more purple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).ignoresSafeArea()
                    Color.black.opacity(0.38).ignoresSafeArea() // Slightly stronger overlay for contrast
                    VStack(spacing: 24) {
                        Spacer(minLength: 40)
                        WebImage(url: URL(string: "https://media.giphy.com/media/3oz8xAFtqoOUUrsh7W/giphy.gif"))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFit()
                            .frame(maxWidth: 220, maxHeight: 120)
                            .clipped()
                        Text("\(month.title) complete!")
                            .font(.custom("Poppins-SemiBold", size: 28))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.95), radius: 8, x: 0, y: 4)
                            .padding(.top, 24)
                        
                        Text("Nice work bestie, you're the GOAT 🐐")
                            .font(.custom("Poppins-Regular", size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.95), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 24)
                        
                        if !assetsToDelete.isEmpty {
                            ScrollView {
                                let columns = [GridItem(.adaptive(minimum: 90, maximum: 120), spacing: 14)]
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(assetsToDelete, id: \ .localIdentifier) { asset in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                                            PhotoCard(asset: asset)
                                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                                .padding(6)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                                        )
                                        .frame(width: 100, height: 100)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            .frame(maxHeight: 200)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            if !assetsToDelete.isEmpty {
                                onBatchDelete?()
                            }
                        }) {
                            Text("Return to Home")
                                .font(.custom("Poppins-SemiBold", size: 22))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red:1.0, green:0.0, blue:0.6),
                                            Color.yellow,
                                            Color(red:0.0, green:0.6, blue:1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(18)
                                .shadow(color: Color.yellow.opacity(0.18), radius: 10, x: 0, y: 3)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 12)
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: 500)
                    .padding(.vertical, 24)
                    .padding(.bottom, 24)
                }
            }
            if showPaywall {
                Color.black.opacity(0.6).ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            // Only dismiss parent if user is NOT premium after paywall closes
            if !isPremium {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            PaywallView(onUnlock: {
                isPremium = true
                showPaywall = false
                totalSwipes = 0
                hasSeenPaywall = false
                // Do NOT dismiss parent here; user stays on swipe view
            })
        }
        .onAppear {
            if !isPremium && (totalSwipes >= 3 || hasSeenPaywall) {
                showPaywall = true
            }
        }
        .onDisappear {
            handleSessionEnd()
        }
    }
    
    var canSwipe: Bool {
        isPremium || totalSwipes < 3
    }
    
    var overlayText: String? {
        if offset.width > 60 {
            return "KEEP"
        } else if offset.width < -60 {
            return "DELETE"
        } else {
            return nil
        }
    }
    
    func nextPhoto() {
        if currentIndex < month.assets.count - 1 {
            currentIndex += 1
        } else {
            currentIndex += 1 // To show confirmation
            handleSessionEnd() // Automatically show confirmation screen
        }
    }
    
    func handleSessionEnd() {
        guard !isDeleting, !showDeleted else { return }
        
        if !assetsToDelete.isEmpty {
            // If there are photos to delete, delete them first
            isDeleting = true
            deleteBatch(assets: assetsToDelete) {
                isDeleting = false
                showDeleted = true
                assetsToDelete.removeAll()
                // Notify parent to refresh
                onBatchDelete?()
            }
        } else {
            // If no photos to delete, just show the confirmation screen
            showDeleted = true
        }
    }
    
    private func deleteBatch(assets: [PHAsset], completion: @escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    // Update current state instead of reloading
                    if let currentMonth = photoManager.photoMonths.first(where: { $0.assets.contains(where: { assets.contains($0) }) }) {
                        // Remove deleted assets from the current month
                        let updatedAssets = currentMonth.assets.filter { !assets.contains($0) }
                        if let monthIndex = photoManager.photoMonths.firstIndex(where: { $0.month == currentMonth.month && $0.year == currentMonth.year }) {
                            if updatedAssets.isEmpty {
                                // Remove the month if it's empty
                                photoManager.photoMonths.remove(at: monthIndex)
                            } else {
                                // Update the month with remaining assets
                                photoManager.photoMonths[monthIndex] = PhotoMonth(
                                    month: currentMonth.month,
                                    year: currentMonth.year,
                                    assets: updatedAssets
                                )
                            }
                        }
                    }
                    completion()
                } else if let error = error {
                    print("Error deleting photos: \(error)")
                    completion()
                }
            }
        }
    }

    // Button tap helpers
    func animateDelete() {
        guard !buttonActionInProgress else { return }
        buttonActionInProgress = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = CGSize(width: -1000, height: 0)
        }
        isAnimatingOff = true
        if currentIndex < month.assets.count {
            let assetToDelete = month.assets[currentIndex]
            assetsToDelete.append(assetToDelete)
            deleteCount += 1
            incrementSwipeCountIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            nextPhoto()
            offset = .zero
            isAnimatingOff = false
            buttonActionInProgress = false
        }
    }
    func animateKeep() {
        guard !buttonActionInProgress else { return }
        buttonActionInProgress = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = CGSize(width: 1000, height: 0)
        }
        isAnimatingOff = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            keepCount += 1
            incrementSwipeCountIfNeeded()
            nextPhoto()
            offset = .zero
            isAnimatingOff = false
            buttonActionInProgress = false
        }
    }
    func incrementSwipeCountIfNeeded() {
        if !isPremium && totalSwipes < 3 {
            totalSwipes += 1
            if totalSwipes == 3 {
                hasSeenPaywall = true
                showPaywall = true
            }
        }
    }
}

struct CounterCircle: View {
    let label: String
    let count: Int
    let gradient: Gradient
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            Text("\(count)")
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(.white)
        }
        .frame(width: 90, height: 90)
        .background(
            RadialGradient(gradient: gradient, center: .center, startRadius: 10, endRadius: 60)
        )
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

struct ConfettiView: View {
    @State private var confettiParticles: [ConfettiParticle] = []
    let colors: [Color] = [.yellow, .green, .pink, .purple, .orange, .cyan, .white]
    var body: some View {
        ZStack {
            ForEach(confettiParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(.easeOut(duration: particle.duration), value: particle.position)
            }
        }
        .onAppear {
            confettiParticles = (0..<32).map { _ in ConfettiParticle.random(in: UIScreen.main.bounds, colors: colors) }
            for i in confettiParticles.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0.2)) {
                    confettiParticles[i].animate()
                }
            }
        }
    }
}

class ConfettiParticle: Identifiable, ObservableObject {
    let id = UUID()
    var color: Color
    var size: CGFloat
    var position: CGPoint
    var opacity: Double
    var duration: Double
    init(color: Color, size: CGFloat, position: CGPoint, opacity: Double, duration: Double) {
        self.color = color
        self.size = size
        self.position = position
        self.opacity = opacity
        self.duration = duration
    }
    static func random(in bounds: CGRect, colors: [Color]) -> ConfettiParticle {
        ConfettiParticle(
            color: colors.randomElement()!,
            size: CGFloat.random(in: 10...22),
            position: CGPoint(x: CGFloat.random(in: 0...bounds.width), y: -30),
            opacity: 1.0,
            duration: Double.random(in: 1.2...2.0)
        )
    }
    func animate() {
        let screenHeight = UIScreen.main.bounds.height
        withAnimation(.easeOut(duration: duration)) {
            position.y = screenHeight + 40
            opacity = 0.0
        }
    }
}

struct PhotoCard: View {
    let asset: PHAsset
    var offset: CGSize = .zero
    var overlayText: String? = nil
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .shadow(radius: 10)
            } else {
                Color.gray
                    .cornerRadius(20)
            }
            if let overlayText = overlayText {
                Text(overlayText)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(overlayText == "KEEP" ? .green : .purple)
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .padding(32)
                    .opacity(Double(min(abs(offset.width) / 120, 1)))
                    .animation(.easeInOut, value: offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .onAppear {
            fetchImage()
        }
    }
    
    func fetchImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFit, options: options) { img, _ in
            self.image = img
        }
    }
}
