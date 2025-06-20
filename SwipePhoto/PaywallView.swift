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
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [Color(red:0.13, green:0.09, blue:0.23), Color(red:0.18, green:0.13, blue:0.32), Color(red:0.22, green:0.09, blue:0.32), Color(red:0.13, green:0.13, blue:0.23), Color.purple.opacity(0.7), Color.blue.opacity(0.7), Color.pink.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 12) {
                        Text("Unlock Premium 👑")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 5, x: 0, y: 2)
                            .multilineTextAlignment(.center)
                            .padding(.top, 54)
                        Text("Get unlimited swipes and deletes")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "arrow.2.circlepath")
                            .foregroundColor(Color.purple)
                            .font(.system(size: 18))
                        Text("Auto-renewable. Cancel anytime.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 8)
                    VStack(spacing: 24) {
                        PulsingButton(
                            title: "Try For Free",
                            subtitle: "3 days free, then $1.99/week",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { purchasePlan(weekly: true) },
                            disabled: isPurchasing || products.isEmpty
                        )
                        PulsingButton(
                            title: "Subscribe for $9.99/year",
                            subtitle: "1 year, best value",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red:0.2, green:0.6, blue:1.0), Color(red:1.0, green:0.0, blue:0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { purchasePlan(weekly: false) },
                            disabled: isPurchasing || products.isEmpty
                        )
                        // Debug bypass paywall button
                        Button(action: {
                            isPremium = true
                            onUnlock?()
                        }) {
                            Text("Bypass Paywall")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 0)
                    if let error = purchaseError {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .padding(.horizontal, 8)
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        Text("What makes us different?")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 4, x: 0, y: 1)
                        HStack(alignment: .top, spacing: 10) {
                            Text("💖")
                                .font(.system(size: 22))
                            Text("Your photos are 100% private and stay on your device only")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                        HStack(alignment: .top, spacing: 10) {
                            Text("💜")
                                .font(.system(size: 22))
                            Text("Affordable pricing")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                        HStack(alignment: .top, spacing: 10) {
                            Text("💙")
                                .font(.system(size: 22))
                            Text("Built by an all-women team!")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: restore) {
                        Text("Restore")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { showFAQ = true }) {
                        Text("FAQ")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Button(action: { /* open terms */ }) {
                        Text("Terms Of Use")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .underline()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 10)
                .background(Color.clear)
            }
            // Overlay the X button in the top-left, respecting safe area
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
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
                Spacer()
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
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(1.0), radius: 6, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.18), radius: 8, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(gradient)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.13), radius: 10, y: 5)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
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
