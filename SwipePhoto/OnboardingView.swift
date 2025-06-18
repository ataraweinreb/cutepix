import SwiftUI
import SDWebImageSwiftUI
import AVKit

struct OnboardingView: View {
    var onFinish: () -> Void
    @StateObject private var playerHolder = PlayerHolder()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [Color(red:0.13, green:0.09, blue:0.23), Color(red:0.18, green:0.13, blue:0.32), Color(red:0.22, green:0.09, blue:0.32), Color(red:0.13, green:0.13, blue:0.23), Color.purple.opacity(0.7), Color.blue.opacity(0.7), Color.pink.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 44)
                VStack(spacing: 30) {
                    Text("Welcome to Color Clean! ✨")
                        .font(.custom("Poppins-Bold", size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                        .multilineTextAlignment(.center)
                    Text("The playful, girly way to clean your camera roll 💖")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                        .multilineTextAlignment(.center)
                    OnboardingPolaroidStack(onFinish: onFinish)
                        .frame(height: 220)
                        .shadow(color: .cyan.opacity(0.25), radius: 16, x: 0, y: 8)
                        .padding(.vertical, 8)
                    PulsingButton(
                        title: "Get Started",
                        subtitle: "",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: {
                            playerHolder.player.pause()
                            playerHolder.player.seek(to: .zero)
                            DispatchQueue.main.async {
                                onFinish()
                            }
                        },
                        disabled: false
                    )
                    .frame(height: 72)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.horizontal, 0)
                    .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 7)
                    .shadow(color: Color.yellow.opacity(0.18), radius: 10, x: 0, y: 3)
                }
                .padding(.vertical, 36)
                .padding(.horizontal, 24)
                .frame(maxWidth: 500)
                .shadow(color: Color.black.opacity(0.18), radius: 32, x: 0, y: 12)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
                Spacer(minLength: 24)
            }
        }
    }
}

// Helper class to manage AVPlayer and looping
class PlayerHolder: ObservableObject {
    let player: AVPlayer
    private var observer: NSObjectProtocol?

    init() {
        if let url = Bundle.main.url(forResource: "onboarding", withExtension: "MP4") {
            self.player = AVPlayer(url: url)
        } else {
            self.player = AVPlayer()
        }
    }

    func playAndLoop() {
        player.seek(to: .zero)
        player.play()
        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        player.pause()
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = controller.view.bounds
        controller.view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.playerLayer?.frame = uiViewController.view.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// Add a new OnboardingPolaroidStack that calls onFinish when all polaroids are swiped
struct OnboardingPolaroidStack: View {
    let onFinish: () -> Void
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    let gifUrls = [
        "https://media.giphy.com/media/3o7aTvhUAeRLAVx8vm/giphy.gif",
        "https://media.giphy.com/media/TydZAW0DVCbGE/giphy.gif",
        "https://media.giphy.com/media/ydttw7Bg2tHVHecInE/giphy.gif"
    ]
    let captions = [
        "Swipe to clean! ✨",
        "Keep your faves 💖",
        "Delete the rest 🧼"
    ]
    var body: some View {
        VStack(spacing: 2) {
            // Handwritten 'swipe me' text with down arrow inline
            HStack(spacing: 8) {
                Text("swipe me")
                    .font(.custom("SnellRoundhand-Bold", size: 28, relativeTo: .title2))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
                Text("↓")
                    .font(.custom("SnellRoundhand-Bold", size: 32, relativeTo: .title2))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
            }
            .padding(.bottom, 2)
            ZStack {
                // Polaroid cards
                ForEach(currentIndex..<gifUrls.count, id: \.self) { i in
                    PolaroidCard(gifUrl: gifUrls[i], caption: captions[i])
                        .offset(x: i == currentIndex ? dragOffset.width : CGFloat(i - currentIndex) * 8,
                                y: i == currentIndex ? dragOffset.height : CGFloat(i - currentIndex) * 8)
                        .rotationEffect(i == currentIndex ? .degrees(Double(dragOffset.width / 12)) : .degrees(0))
                        .zIndex(Double(gifUrls.count - i))
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    if i == currentIndex {
                                        dragOffset = value.translation
                                    }
                                }
                                .onEnded { value in
                                    if i == currentIndex {
                                        if abs(value.translation.width) > 40 || abs(value.translation.height) > 40 {
                                            withAnimation(.spring()) {
                                                dragOffset = CGSize(width: value.translation.width * 2, height: value.translation.height * 2)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                                withAnimation(.spring()) {
                                                    dragOffset = .zero
                                                    if currentIndex < gifUrls.count - 1 {
                                                        currentIndex += 1
                                                    } else {
                                                        onFinish()
                                                    }
                                                }
                                            }
                                        } else {
                                            withAnimation(.spring()) {
                                                dragOffset = .zero
                                            }
                                        }
                                    }
                                }
                        )
                        .frame(width: 220, height: 180)
                }
            }
            .frame(width: 220, height: 180)
        }
    }
}

// Helper for a single polaroid card
struct PolaroidCard: View {
    let gifUrl: String
    let caption: String
    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: URL(string: gifUrl))
                .resizable()
                .indicator(.activity)
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 110)
                .clipped()
            Text(caption)
                .font(.custom("Poppins-Regular", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
        }
        .frame(width: 200, height: 160)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.13), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
        )
    }
}

// Add the shimmer view below
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.55), Color.white.opacity(0.15)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.plusLighter)
        .opacity(0.7)
        .mask(
            Rectangle()
                .fill(Color.white)
                .rotationEffect(.degrees(20))
                .offset(x: phase * 320 - 160)
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

//// GradientWideButton reusable component
//struct GradientWideButton<Label: View>: View {
//    let action: () -> Void
//    let label: () -> Label
//    @State private var animate = false
//    var body: some View {
//        Button(action: action) {
//            label()
//                .scaleEffect(animate ? 1.04 : 1.0)
//                .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: animate)
//        }
//        .onAppear { animate = true }
//    }
//}
