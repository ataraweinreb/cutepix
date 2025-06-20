import SwiftUI

struct SettingsMainView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showFAQ = false
    @State private var showShareSheet = false
    var body: some View {
        NavigationView {
        ZStack {
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
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                                .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark))
                            .clipShape(Circle())
                            .shadow(radius: 2, y: 1)
                    }
                    .padding(.top, 18)
                    .padding(.leading, 18)
                    Spacer()
                }
                Text("Settings")
                        .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.85), radius: 5, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                VStack(spacing: 24) {
                    GradientWideButton(
                        title: "FAQ 🙋‍♀️",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) { showFAQ = true }
                    GradientWideButton(
                        title: "Leave us a review 🌟",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color(red:0.2, green:0.6, blue:1.0), Color(red:1.0, green:0.0, blue:0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) {
                        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }
                    GradientWideButton(
                        title: "Share this app ↗️",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) { showShareSheet = true }
                    GradientWideButton(
                        title: "Manage Subscription 👑",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 18)
                Spacer()
            }
            .sheet(isPresented: $showFAQ) {
                SettingsFAQView()
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!])
                }
            }
        }
    }
}

struct GradientWideButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.85), radius: 3, x: 0, y: 1)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 8)
                .background(gradient)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.13), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// UIKit share sheet wrapper
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
 
