import SwiftUI
import SDWebImageSwiftUI

struct FAQCard: Identifiable {
    let id = UUID()
    let memeUrl: String?
    let question: String
    let answer: String
}

struct SettingsFAQView: View {
    @Environment(\.presentationMode) var presentationMode
    let faqCards: [FAQCard] = [
        FAQCard(
            memeUrl: "https://media.giphy.com/media/3o7aTvhUAeRLAVx8vm/giphy.gif",
            question: "Who built this app?",
            answer: "Just a girl like you who loves Taylor Swift, pink, and sparkles ✨"
        ),
        FAQCard(
            memeUrl: "https://media.giphy.com/media/3o7aTvhUAeRLAVx8vm/giphy.gif",
            question: "Are my photos safe?",
            answer: "100% — they never leave your phone."
        ),
        FAQCard(
            memeUrl: "https://media.giphy.com/media/TydZAW0DVCbGE/giphy.gif",
            question: "Is it safe to use Swipe Photo?",
            answer: "Absolutely! We never upload your photos. All the magic happens on your device."
        ),
        FAQCard(
            memeUrl: "https://media.giphy.com/media/ydttw7Bg2tHVHecInE/giphy.gif",
            question: "How do I unsubscribe?",
            answer: "Tap 'Manage Subscription' below."
        )
    ]
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @GestureState private var dragState = CGSize.zero
    
    var body: some View {
        GeometryReader { geo in
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
                    Text("Swipe for FAQ")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.85), radius: 5, x: 0, y: 2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.bottom, 10)
                    SwipeableFAQStack(faqCards: faqCards, currentIndex: $currentIndex, offset: $offset, dragState: dragState)
                        .padding(.top, 4)
                    HStack(spacing: 32) {
                        Button(action: previousCard) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.13), radius: 8, x: 0, y: 4)
                        }
                        Button(action: nextCard) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red:1.0, green:0.0, blue:0.6), Color.yellow, Color(red:0.0, green:0.6, blue:1.0)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.13), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.top, 0)
                    Spacer()
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 0)
                .padding(.bottom, geo.safeAreaInsets.bottom)
            }
        }
    }
    
    private func previousCard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex = (currentIndex - 1 + faqCards.count) % faqCards.count
            offset = .zero
        }
    }
    
    private func nextCard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex = (currentIndex + 1) % faqCards.count
            offset = .zero
        }
    }
}

struct SwipeableFAQStack: View {
    let faqCards: [FAQCard]
    @Binding var currentIndex: Int
    @Binding var offset: CGSize
    @GestureState var dragState: CGSize
    
    var body: some View {
        let deviceWidth = UIScreen.main.bounds.width
        let cardWidth = min(deviceWidth * 0.85, 370)
        let cardHeight = cardWidth * 1.18
        VStack(spacing: 12) {
            ZStack {
                ForEach((currentIndex..<min(currentIndex+3, faqCards.count + 2)).reversed(), id: \.self) { idx in
                    let stackOffset = idx - currentIndex
                    FAQPolaroidCard(
                        card: faqCards[idx % faqCards.count],
                        baseRotation: Double(stackOffset) * 3.0,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight
                    )
                    .offset(
                        x: idx == currentIndex ? offset.width : CGFloat(stackOffset) * 8,
                        y: CGFloat(stackOffset) * 12
                    )
                    .rotationEffect(.degrees(idx == currentIndex ? Double(offset.width / 12) : Double(stackOffset) * 3.0))
                    .scaleEffect(idx == currentIndex ? 1.0 : 1.0 - CGFloat(stackOffset) * 0.05)
                    .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.5), value: offset)
                    .allowsHitTesting(idx == currentIndex)
                    .gesture(
                        idx == currentIndex ?
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                state = value.translation
                            }
                            .onChanged { gesture in
                                offset = gesture.translation
                            }
                            .onEnded { gesture in
                                let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                                let threshold: CGFloat = 100
                                if offset.width > threshold || velocity > 200 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset.width = UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        currentIndex = (currentIndex + 1) % faqCards.count
                                        offset = .zero
                                    }
                                } else if offset.width < -threshold || velocity < -200 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset.width = -UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        currentIndex = (currentIndex + 1) % faqCards.count
                                        offset = .zero
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        offset = .zero
                                    }
                                }
                            }
                        : nil
                    )
                }
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(height: cardHeight + max(44, cardWidth * 0.14) + 16)
        .padding(.horizontal, 8)
    }
}

struct FAQPolaroidCard: View {
    let card: FAQCard
    let baseRotation: Double
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    @State private var rotation: Double
    
    init(card: FAQCard, baseRotation: Double = 0, cardWidth: CGFloat = 370, cardHeight: CGFloat = 440) {
        self.card = card
        self.baseRotation = baseRotation
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        _rotation = State(initialValue: baseRotation + Double.random(in: -2...2))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let memeUrl = card.memeUrl {
                WebImage(url: URL(string: memeUrl))
                    .resizable()
                    .indicator(.activity)
                    .scaledToFit()
                    .frame(width: cardWidth * 0.86, height: cardHeight * 0.5)
                    .background(Color.white.opacity(0.12))
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
            } else {
                Spacer().frame(height: 32)
            }
            Text(card.question)
                .font(.system(size: max(20, cardWidth * 0.065), weight: .semibold))
                .foregroundColor(Color.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)
            Text(card.answer)
                .font(.system(size: max(16, cardWidth * 0.055), weight: .regular))
                .foregroundColor(Color.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 18)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: cardWidth * 0.032, style: .continuous)
                .fill(Color.white)
        )
        .cornerRadius(cardWidth * 0.032)
        .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 7)
        .rotationEffect(.degrees(rotation))
    }
} 
