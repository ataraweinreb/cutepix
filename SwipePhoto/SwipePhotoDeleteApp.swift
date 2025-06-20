import SwiftUI

@main
struct SwipePhotoDeleteApp: App {
    @StateObject var photoManager = PhotoManager()
    
    init() {
        // Force dark mode for the entire app
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(photoManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    photoManager.checkPermission()
                }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    showOnboarding = false
                    // Check permissions after onboarding
                    photoManager.checkPermission()
                }
            } else {
                HomeView()
            }
        }
    }
} 
