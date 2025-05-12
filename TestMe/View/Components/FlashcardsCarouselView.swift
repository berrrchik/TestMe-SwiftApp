import SwiftUI

struct FlashcardsCarouselView: View {
    var flashcards: [Flashcard]
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    
    @State private var currentIndex = 0
    @State private var showingDefinition = false
    
    var body: some View {
        VStack {
            if flashcards.isEmpty {
                emptyView
            } else {
                carouselView
            }
        }
        .navigationTitle("Просмотр карточек")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет карточек")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("В этой категории нет карточек для просмотра")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var carouselView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressView(value: Double(currentIndex + 1), total: Double(flashcards.count))
                    .padding(.horizontal)
                
                Text("\(currentIndex + 1) из \(flashcards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        VStack(spacing: 20) {
                            Text(showingDefinition ? "Определение" : "Термин")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(showingDefinition ? flashcards[currentIndex].definition : flashcards[currentIndex].term)
                                .font(showingDefinition ? .body : .title3)
                                .fontWeight(showingDefinition ? .regular : .bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.7)
                            
                            Button(action: { showingDefinition.toggle() }) {
                                Text(showingDefinition ? "Показать термин" : "Показать определение")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal)
                    .frame(minHeight: 200)
                    
                    // Индикатор состояния изучения
                    HStack {
//                        Button(action: {
//                            var updatedFlashcard = flashcards[currentIndex]
//                            updatedFlashcard.isLearned = true
//                            flashcardViewModel.updateFlashcard(updatedFlashcard)
//                        }) {
//                            HStack {
//                                Image(systemName: "checkmark.circle.fill")
//                                Text("Знаю")
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.green.opacity(0.1))
//                            .foregroundColor(.green)
//                            .cornerRadius(8)
//                        }
//                        
//                        Button(action: {
//                            var updatedFlashcard = flashcards[currentIndex]
//                            updatedFlashcard.isLearned = false
//                            flashcardViewModel.updateFlashcard(updatedFlashcard)
//                        }) {
//                            HStack {
//                                Image(systemName: "xmark.circle.fill")
//                                Text("Не знаю")
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.red.opacity(0.1))
//                            .foregroundColor(.red)
//                            .cornerRadius(8)
//                        }
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                showingDefinition = false
                            }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(currentIndex > 0 ? .blue : .gray)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .disabled(currentIndex <= 0)
                    
                    Spacer()
                    
                    Button(action: {
                            if currentIndex < flashcards.count - 1 {
                                currentIndex += 1
                                showingDefinition = false
                            }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(currentIndex < flashcards.count - 1 ? .blue : .gray)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .disabled(currentIndex >= flashcards.count - 1)
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    NavigationView {
        FlashcardsCarouselView(flashcards: [
            Flashcard(term: "Пример термина 1", definition: "Пример определения 1", categoryId: UUID()),
            Flashcard(term: "Пример термина 2", definition: "Пример определения 2", categoryId: UUID()),
            Flashcard(term: "Пример термина 3", definition: "Пример определения 3 с очень длинным описанием, которое может занимать несколько строк в интерфейсе приложения", categoryId: UUID())
        ])
    }
    .environmentObject(FlashcardViewModel())
} 
