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
            HomeView(photoManager: photoManager)
                .environmentObject(photoManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    photoManager.fetchPhotos()
                }
        }
    }
} 
