import SwiftUI
import AVKit

struct OnboardingView: View {
    var onFinish: () -> Void
    @StateObject private var playerHolder = PlayerHolder()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                Text("Welcome to ColorClean!")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VideoPlayerView(player: playerHolder.player)
                    .frame(height: 340)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    .onAppear {
                        playerHolder.playAndLoop()
                    }

                Text("Swipe through your photos, keep the best, and delete the rest. Let's get started!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Button(action: {
                    // Stop video playback before dismissing
                    playerHolder.player.pause()
                    playerHolder.player.seek(to: .zero)
                    // Use async to ensure video cleanup happens before dismissal
                    DispatchQueue.main.async {
                        onFinish()
                    }
                }) {
                    Text("Get Started")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                }
                Spacer()
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
