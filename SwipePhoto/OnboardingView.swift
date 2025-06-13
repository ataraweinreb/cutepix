//import SwiftUI
//import AVKit
//
//struct OnboardingView: View {
//    var onFinish: () -> Void
//
//    // Replace "onboarding" with your video file name (without extension)
//    private var player: AVPlayer? {
//        if let url = Bundle.main.url(forResource: "onboarding", withExtension: "MP4") {
//            return AVPlayer(url: url)
//        }
//        return nil
//    }
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [Color.orange, Color.pink]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 32) {
//                Spacer()
//                Text("Welcome to SwipeWipe!")
//                    .font(.system(size: 40, weight: .bold, design: .serif))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 24)
//
//                if let player = player {
//                    VideoPlayer(player: player)
//                        .frame(height: 240)
//                        .cornerRadius(20)
//                        .padding(.horizontal, 24)
//                        .onAppear { player.play() }
//                } else {
//                    Text("Video not found.")
//                        .foregroundColor(.white)
//                }
//
//                Text("Swipe through your photos, keep the best, and delete the rest. Let's get started!")
//                    .font(.title2)
//                    .foregroundColor(.white.opacity(0.9))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 32)
//
//                Spacer()
//
//                Button(action: onFinish) {
//                    Text("Get Started")
//                        .font(.title2.bold())
//                        .foregroundColor(.orange)
//                        .padding(.vertical, 16)
//                        .padding(.horizontal, 48)
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(radius: 8)
//                }
//                Spacer()
//            }
//        }
//    }
//}

import SwiftUI
import AVKit

struct OnboardingView: View {
    var onFinish: () -> Void
    @StateObject private var playerHolder = PlayerHolder()

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

                Button(action: onFinish) {
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
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
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
