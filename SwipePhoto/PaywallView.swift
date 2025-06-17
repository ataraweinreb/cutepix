import SwiftUI
import StoreKit
import SDWebImageSwiftUI
//import SettingsFAQView

struct PaywallView: View {
    var onUnlock: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @State private var products: [Product] = []
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @AppStorage("isPremium") private var isPremium: Bool = false
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @GestureState private var dragState = CGSize.zero
    
    // Coupon code state
    @State private var couponCode: String = ""
    @State private var couponError: String?

    // Use placeholder product IDs for now
    let weeklyProductID = "com.example.premium.weekly"
    let yearlyProductID = "com.example.premium.yearly"

    let gifUrls = [
        "https://media.giphy.com/media/3o7aTvhUAeRLAVx8vm/giphy.gif",
        "https://media.giphy.com/media/TydZAW0DVCbGE/giphy.gif",
        "https://media.giphy.com/media/ydttw7Bg2tHVHecInE/giphy.gif"
    ]
    
    let captions = [
        "Unlock unlimited swipes! ✨",
        "Keep your favorite memories 💖",
        "Clean up your camera roll 🧼"
    ]

    @State private var showFAQ = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 1.0, green: 0.74, blue: 0.83) // FFBCD3
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // GIF at the top (smaller)
                WebImage(url: URL(string: "https://media.giphy.com/media/XMmf6i3xuKZiPMvNZe/giphy.gif"))
                    .resizable()
                    .indicator(.activity)
                    .scaledToFit()
                    .frame(height: 110)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.13), radius: 8, y: 3)
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                // Title
                Text("Unlock Premium 👑")
                    .font(.custom("Poppins-Bold", size: 38))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 2)

                // Playful subtitle
                Text("Get unlimited swipes and deletes")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)

                // Cancel anytime row (replaces FAQ/data row)
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "arrow.2.circlepath")
                        .foregroundColor(Color.purple)
                        .font(.system(size: 18))
                    Text("Auto-renewable. Cancel anytime.")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)

                // Subscription Options with pulsing animation
                VStack(spacing: 20) {
                    PulsingButton(
                        title: "Try For Free",
                        subtitle: "3 days free, then " + (products.first(where: { $0.id == weeklyProductID })?.displayPrice ?? "$9.99/week"),
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.95, green: 0.2, blue: 0.7), Color(red: 1.0, green: 0.5, blue: 0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: { purchasePlan(weekly: true) },
                        disabled: isPurchasing || products.isEmpty
                    )
                    PulsingButton(
                        title: "Subscribe for " + (products.first(where: { $0.id == yearlyProductID })?.displayPrice ?? "$39.99/year"),
                        subtitle: "1 year, best value",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.5, blue: 0.9)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        action: { purchasePlan(weekly: false) },
                        disabled: isPurchasing || products.isEmpty
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                // Error
                if let error = purchaseError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                // Move up the 'What makes us different?' section
                VStack(alignment: .leading, spacing: 14) {
                    Text("What makes us different?")
                        .font(.custom("Poppins-Medium", size: 20))
                        .foregroundColor(.black)
                        .padding(.bottom, 2)
                    HStack(alignment: .top, spacing: 10) {
                        Text("💖")
                            .font(.system(size: 22))
                        Text("All photos and data stay on your device and are 100% private")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("💜")
                            .font(.system(size: 22))
                        Text("Significantly cheaper than most competitor apps")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("💙")
                            .font(.system(size: 22))
                        Text("Built for girls, by girls. Help support women in tech!")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 18)
                .padding(.bottom, 18)
            }
            // X button in the top corner, overlayed
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundColor(.black.opacity(0.7))
                    .padding(8)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(radius: 2, y: 1)
            }
            .padding(.top, 18)
            .padding(.leading, 18)

            // Restore, FAQ, Terms Of Use links at the bottom
            VStack {
                Spacer()
                HStack {
                    Button(action: restore) {
                        Text("Restore")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.black.opacity(0.35))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { showFAQ = true }) {
                        Text("FAQ")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.black.opacity(0.35))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { /* open terms */ }) {
                        Text("Terms Of Use")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.black.opacity(0.35))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showFAQ) {
            SettingsFAQView()
        }
        .task {
            await loadProducts()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [weeklyProductID, yearlyProductID])
        } catch {
            purchaseError = "Failed to load products."
        }
    }

    func purchasePlan(weekly: Bool) {
        let id = weekly ? weeklyProductID : yearlyProductID
        guard let product = products.first(where: { $0.id == id }) else { return }
        purchase(product: product)
    }

    func purchase(product: Product) {
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(_):
                        isPremium = true
                        if let onUnlock = onUnlock {
                            onUnlock()
                        } else {
                            dismiss()
                        }
                    case .unverified(_, let error):
                        purchaseError = "Purchase could not be verified: \(error.localizedDescription)"
                    }
                case .userCancelled:
                    break
                case .pending:
                    purchaseError = "Purchase is pending approval."
                @unknown default:
                    break
                }
            } catch {
                purchaseError = error.localizedDescription
            }
        }
    }

    func restore() {
        Task {
            do {
                try await AppStore.sync()
            } catch {
                purchaseError = "Failed to restore purchases."
            }
        }
    }
}

// Glassmorphism blur effect
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// PulsingButton reusable component
struct PulsingButton: View {
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    let action: () -> Void
    var disabled: Bool = false
    @State private var animate = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gradient)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.10), radius: 8, y: 4)
                Text(subtitle)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .scaleEffect(animate ? 1.04 : 1.0)
        .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
        .disabled(disabled)
    }
} 
