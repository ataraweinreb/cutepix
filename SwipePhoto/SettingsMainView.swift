import SwiftUI

struct SettingsMainView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showFAQ = false
    @State private var showShareSheet = false
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.74, blue: 0.83).ignoresSafeArea()
            VStack(spacing: 32) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("Poppins-Bold", size: 22))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(8)
                            .background(Color.white.opacity(0.85))
                            .clipShape(Circle())
                            .shadow(radius: 2, y: 1)
                    }
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.leading, 18)
                Spacer(minLength: 0)
                Text("Settings ")
                    .font(.custom("Poppins-Bold", size: 36))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                VStack(spacing: 24) {
                    PulsingGradientButton(
                        title: "FAQ",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.0, blue: 0.6), Color(red: 1.0, green: 0.4, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        showFAQ = true
                    }
                    PulsingGradientButton(
                        title: "Leave us a review",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.0, blue: 1.0), Color(red: 0.0, green: 0.4, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }
                    PulsingGradientButton(
                        title: "Share this app",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.8, blue: 1.0), Color(red: 0.0, green: 0.2, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        showShareSheet = true
                    }
                    PulsingGradientButton(
                        title: "Manage Subscription",
                        gradient: LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.0, blue: 0.5), Color(red: 0.6, green: 0.0, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
            .frame(maxWidth: 500)
            .padding(.bottom, 32)
            .sheet(isPresented: $showFAQ) {
                SettingsFAQView()
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!])
            }
        }
    }
}

struct PulsingGradientButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    @State private var animate = false
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.22), radius: 2, x: 0, y: 2)
                .padding(.vertical, 20)
                .padding(.horizontal, 48)
                .background(gradient)
                .cornerRadius(24)
                .scaleEffect(animate ? 1.08 : 1.0)
                .shadow(color: Color.pink.opacity(0.18), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
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
