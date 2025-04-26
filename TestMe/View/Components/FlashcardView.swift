import SwiftUI

struct FlashcardView: View {
    var flashcard: Flashcard
    var isShowingAnswer: Bool
    var onTap: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            ZStack {
                frontCard
                    .opacity(isShowingAnswer ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isShowingAnswer ? 90 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                backCard
                    .opacity(isShowingAnswer ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isShowingAnswer ? 0 : -90),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .frame(width: 320, height: 200)
            .offset(offset)
            .animation(.spring(), value: offset)
            .animation(.easeInOut(duration: 0.5), value: isShowingAnswer)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        onTap()
                    }
            )
        }
    }
    
    var frontCard: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .overlay(
                VStack {
                    Text(flashcard.term)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Нажмите, чтобы увидеть определение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            )
            .shadow(radius: 5)
    }
    
    var backCard: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 2)
            )
            .overlay(
                VStack {
                    Text(flashcard.definition)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Нажмите, чтобы увидеть термин")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            )
            .shadow(radius: 5)
    }
} 