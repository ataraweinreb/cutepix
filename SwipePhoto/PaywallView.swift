import SwiftUI
import StoreKit
import AVKit

struct PaywallView: View {
    var onUnlock: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @State private var products: [Product] = []
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @AppStorage("isPremium") private var isPremium: Bool = false
    @StateObject private var playerHolder = PlayerHolder()

    // Use placeholder product IDs for now
    let weeklyProductID = "com.example.premium.weekly"
    let yearlyProductID = "com.example.premium.yearly"

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 1.0, green: 0.82, blue: 0.72), Color.pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Dismiss button always visible at top left
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
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
                // Centered solid card
                HStack {
                    Spacer(minLength: 0)
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            VideoPlayerView(player: playerHolder.player)
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
                                .padding(.top, 8)
                                .padding(.bottom, 10)
                                .onAppear { playerHolder.playAndLoop() }
                            Text("Unlock Premium")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.black)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.horizontal, 8)
                                .padding(.top, 2)
                            Text("Get unlimited swipes, enhance your photos & more.")
                                .font(.title3)
                                .foregroundColor(.black.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 8)
                                .padding(.top, 2)
                            Button(action: { /* maybe link to FAQ */ }) {
                                Text("Cancel anytime.")
                                    .font(.body)
                                    .foregroundColor(Color.purple)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 2)
                        }
                        .padding(.bottom, 14)
                        // Two big buttons for plans
                        VStack(spacing: 16) {
                            Button(action: { purchasePlan(weekly: true) }) {
                                VStack(spacing: 2) {
                                    Text("Try For Free")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.orange)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.white)
                                        .cornerRadius(18)
                                        .shadow(color: Color.orange.opacity(0.10), radius: 6, y: 2)
                                    Text("3 days free, then " + (products.first(where: { $0.id == weeklyProductID })?.displayPrice ?? "$9.99/week"))
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .disabled(isPurchasing || products.isEmpty)
                            Button(action: { purchasePlan(weekly: false) }) {
                                VStack(spacing: 2) {
                                    Text("Subscribe for " + (products.first(where: { $0.id == yearlyProductID })?.displayPrice ?? "$39.99/year"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.orange)
                                        .cornerRadius(18)
                                        .shadow(color: Color.orange.opacity(0.13), radius: 6, y: 2)
                                    Text("1 year, best value")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .disabled(isPurchasing || products.isEmpty)
                        }
                        .padding(.top, 8)
                        // What's different
                        VStack(alignment: .leading, spacing: 12) {
                            Divider().background(Color.black.opacity(0.08))
                                .padding(.vertical, 8)
                            Text("What's different about this app?")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 2)
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "shield.checkerboard")
                                    .foregroundColor(.green)
                                Text("Your data is 100% safe and private, photos never leave your phone and they are not uploaded anywhere and only viewed by you.")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "nosign")
                                    .foregroundColor(.red)
                                Text("No ads ever")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                        // Error
                        if let error = purchaseError {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        // Restore/Terms
                        HStack {
                            Button(action: restore) {
                                Text("Restore")
                                    .font(.footnote)
                                    .underline()
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Button(action: { /* open terms */ }) {
                                Text("Terms Of Use")
                                    .font(.footnote)
                                    .underline()
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 28)
                    .background(Color.white.opacity(0.98))
                    .cornerRadius(32)
                    .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 8)
                    .frame(maxWidth: 420)
                    .frame(minHeight: 700)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 16) }
            .safeAreaInset(edge: .top) { Spacer().frame(height: 0) }
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
