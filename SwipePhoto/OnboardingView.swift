import SwiftUI
import SDWebImageSwiftUI
import AVKit

struct OnboardingView: View {
    var onFinish: () -> Void
    @StateObject private var playerHolder = PlayerHolder()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.74, blue: 0.83) // FFBCD3
                .ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Text("Welcome to Color Clean! ✨")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Text("The playful, girly way to clean your camera roll 💖")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                // Only show the polaroid stack, no main GIF
                SwipeablePolaroidStack(
                    gifUrls: [
                        "https://media.giphy.com/media/3o7aTvhUAeRLAVx8vm/giphy.gif",
                        "https://media.giphy.com/media/TydZAW0DVCbGE/giphy.gif",
                        "https://media.giphy.com/media/ydttw7Bg2tHVHecInE/giphy.gif"
                    ],
                    captions: [
                        "Swipe to clean! ✨",
                        "Keep your faves 💖",
                        "Delete the rest 🧼"
                    ],
                    cardSize: CGSize(width: 200, height: 240)
                )
                .frame(height: 260)
                Text("Swipe through your photos, keep the best, and delete the rest. Let's get started!")
                    .font(.custom("Poppins-Medium", size: 20))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                PulsingGradientButton(
                    title: "Get Started",
                    gradient: LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    // Stop video playback before dismissing
                    playerHolder.player.pause()
                    playerHolder.player.seek(to: .zero)
                    DispatchQueue.main.async {
                        onFinish()
                    }
                }
                .padding(.bottom, 32)
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
