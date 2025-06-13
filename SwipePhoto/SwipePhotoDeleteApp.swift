import SwiftUI

@main
struct SwipePhotoDeleteApp: App {
    @StateObject var photoManager = PhotoManager()
    
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
