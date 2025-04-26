import Foundation

class QuizViewModel: ObservableObject {
    @Published var currentQuizFlashcards: [Flashcard] = []
    @Published var currentCardIndex: Int = 0
    @Published var showAnswer: Bool = false
    @Published var correctAnswers: Int = 0
    @Published var isQuizFinished: Bool = false
    
    private let storageService = StorageService.shared
    private var categoryId: UUID?
    
    var totalCards: Int { currentQuizFlashcards.count }
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentCardIndex) / Double(totalCards)
    }
    
    var currentFlashcard: Flashcard? {
        guard !currentQuizFlashcards.isEmpty, currentCardIndex < currentQuizFlashcards.count else {
            return nil
        }
        return currentQuizFlashcards[currentCardIndex]
    }
    
    func startQuiz(categoryId: UUID, flashcards: [Flashcard]) {
        guard !flashcards.isEmpty else { return }
        
        self.categoryId = categoryId
        self.currentQuizFlashcards = flashcards.shuffled()
        self.currentCardIndex = 0
        self.correctAnswers = 0
        self.showAnswer = false
        self.isQuizFinished = false
    }
    
    func nextCard() {
        if currentCardIndex < totalCards - 1 {
            currentCardIndex += 1
            showAnswer = false
        } else {
            finishQuiz()
        }
    }
    
    func toggleShowAnswer() {
        showAnswer.toggle()
    }
    
    func recordAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        nextCard()
    }
    
    private func finishQuiz() {
        isQuizFinished = true
        
        guard let categoryId = categoryId else { return }
        
        let result = QuizResult(
            categoryId: categoryId,
            correctAnswers: correctAnswers,
            totalQuestions: totalCards
        )
        
        var results = storageService.getQuizResults()
        results.append(result)
        storageService.saveQuizResults(results)
    }
    
    func resetQuiz() {
        currentCardIndex = 0
        correctAnswers = 0
        showAnswer = false
        isQuizFinished = false
    }
} 
