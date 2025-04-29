import SwiftUI

struct FlashcardView: View {
    var flashcard: Flashcard
    var isShowingAnswer: Bool
    var onTap: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var cardHeight: CGFloat = 200
    
    var body: some View {
        VStack {
            ZStack {
                frontCard
                    .opacity(isShowingAnswer ? 0 : 1)
                    .frame(height: isShowingAnswer ? 0 : nil)
                
                backCard
                    .opacity(isShowingAnswer ? 1 : 0)
                    .frame(height: isShowingAnswer ? nil : 0)
            }
            .frame(maxWidth: 320)
            .frame(minHeight: 200)
            .offset(offset)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        onTap()
                    }
            )
        }
    }
    
    var frontCard: some View {
        VStack {
            Text(flashcard.term)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Нажмите, чтобы увидеть определение")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: 320)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
                .shadow(radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    var backCard: some View {
        VStack {
            Text(flashcard.definition)
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Нажмите, чтобы увидеть термин")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: 320)
        .frame(minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.2))
                .shadow(radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
        )
    }
} 
