import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var quizViewModel = QuizViewModel()
    
    var category: Category
    var flashcards: [Flashcard]
    
    init(category: Category, flashcards: [Flashcard]) {
        self.category = category
        self.flashcards = flashcards
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if quizViewModel.isQuizFinished {
                    quizResultView
                } else if let currentFlashcard = quizViewModel.currentFlashcard {
                    quizContentView(flashcard: currentFlashcard)
                } else {
                    Text("Не удалось загрузить флэш-карточки")
                        .font(.headline)
                }
            }
            .navigationTitle("Квиз: \(category.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                quizViewModel.startQuiz(categoryId: category.id, flashcards: flashcards)
            }
        }
    }
    
    func quizContentView(flashcard: Flashcard) -> some View {
        VStack(spacing: 20) {
            // Progress bar
            ProgressView(value: quizViewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            
            Text("Карточка \(quizViewModel.currentCardIndex + 1) из \(quizViewModel.totalCards)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Flashcard
            FlashcardView(
                flashcard: flashcard,
                isShowingAnswer: quizViewModel.showAnswer,
                onTap: {
                    quizViewModel.toggleShowAnswer()
                }
            )
            
            Spacer()
            
            // Answer buttons
            if quizViewModel.showAnswer {
                HStack(spacing: 20) {
                    Button {
                        quizViewModel.recordAnswer(isCorrect: false)
                    } label: {
                        Text("Не знаю")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        quizViewModel.recordAnswer(isCorrect: true)
                    } label: {
                        Text("Знаю")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                Button {
                    quizViewModel.toggleShowAnswer()
                } label: {
                    Text("Показать ответ")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(category.color.color.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding()
    }
    
    var quizResultView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Квиз завершен!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("Ваш результат:")
                    .font(.headline)
                
                Text("\(quizViewModel.correctAnswers) из \(quizViewModel.totalCards)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("(\(Int(Double(quizViewModel.correctAnswers) / Double(quizViewModel.totalCards) * 100))%)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    quizViewModel.resetQuiz()
                    quizViewModel.startQuiz(categoryId: category.id, flashcards: flashcards)
                } label: {
                    Text("Повторить")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Закончить")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    QuizView(
        category: Category(name: "Тестовая категория"),
        flashcards: [
            Flashcard(term: "Термин 1", definition: "Определение 1", categoryId: UUID()),
            Flashcard(term: "Термин 2", definition: "Определение 2", categoryId: UUID())
        ]
    )
} 