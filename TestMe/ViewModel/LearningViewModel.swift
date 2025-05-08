import Foundation
import SwiftUI

class LearningViewModel: ObservableObject {
    @Published var settings: LearningSettings
    @Published var cardsToReview: [Flashcard] = []
    @Published var newCardsForToday: [Flashcard] = []
    @Published var todayStats: TodayLearningStats
    
    @Published private(set) var sessionCards: [Flashcard] = []
    private var currentSessionIndex: Int = 0
    
    private let storageService = StorageService.shared
    private let flashcardViewModel: FlashcardViewModel
    
    init(flashcardViewModel: FlashcardViewModel) {
        self.flashcardViewModel = flashcardViewModel
        self.settings = storageService.getLearningSettings()
        
        if let savedStats = storageService.getDailyLearningStats(),
           LearningViewModel.isToday(storageService.getLastLearningSessionDate()) {
            self.todayStats = savedStats
        } else {
            self.todayStats = TodayLearningStats()
        }
        
        updateCardsForToday()
    }
    
    func updateCardsForToday() {
        let now = Date()
        let allFlashcards = flashcardViewModel.flashcards
        
        let dueCards = allFlashcards.filter { flashcard in
            if let nextReview = flashcard.nextReviewDate, 
               flashcard.learningState != .new && flashcard.learningState != .mastered {
                return nextReview <= now
            }
            return false
        }.sorted { $0.easeFactor < $1.easeFactor }
        
        cardsToReview = Array(dueCards.prefix(settings.dailyReviewCardsLimit))
        
        let newCards = allFlashcards.filter { $0.learningState == .new }
            .sorted { ($0.term + $0.definition).count < ($1.term + $1.definition).count }
        
        newCardsForToday = Array(newCards.prefix(settings.dailyNewCardsLimit))
        
        updateTodayStats()
        
        storageService.saveLastLearningSessionDate(Date())
        storageService.saveDailyLearningStats(todayStats)
    }
    
    func prepareSessionCards() {
        sessionCards = []
        currentSessionIndex = 0
        sessionCards.append(contentsOf: cardsToReview)
        sessionCards.append(contentsOf: newCardsForToday)
    }
    
    func getNextCardForSession() -> Flashcard? {
        guard !sessionCards.isEmpty, currentSessionIndex < sessionCards.count else {
            return nil
        }
        let card = sessionCards[currentSessionIndex]
        return card
    }
    
    func processAnswer(for flashcard: Flashcard, quality: AnswerQuality) {
        var updatedFlashcard = flashcard
        
        updatedFlashcard.lastReviewed = Date()
        
        let newEaseFactor = calculateNewEaseFactor(current: flashcard.easeFactor, quality: quality)
        updatedFlashcard.easeFactor = max(1.3, newEaseFactor)
        
        updatedFlashcard.repetitionCount += 1
        
        switch (updatedFlashcard.learningState, quality) {
        case (.new, .easy), (.new, .good):
            updatedFlashcard.learningState = .learning
        case (.learning, .easy):
            updatedFlashcard.learningState = .reviewing
        case (.reviewing, .easy) where updatedFlashcard.repetitionCount >= 4:
            updatedFlashcard.learningState = .mastered
            updatedFlashcard.isLearned = true
        case (.reviewing, .hard) where updatedFlashcard.repetitionCount >= 7:
            updatedFlashcard.learningState = .mastered
            updatedFlashcard.isLearned = true
        case (.mastered, .again):
            updatedFlashcard.learningState = .reviewing
            updatedFlashcard.repetitionCount = max(2, updatedFlashcard.repetitionCount - 2)
            updatedFlashcard.isLearned = false
        default:
            break
        }
        
        if updatedFlashcard.learningState != .mastered {
            let interval = calculateNextInterval(for: updatedFlashcard, quality: quality)
            updatedFlashcard.nextReviewDate = Calendar.current.date(byAdding: .second, value: interval, to: Date())
        } else {
            updatedFlashcard.nextReviewDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())
        }
        
        flashcardViewModel.updateFlashcard(updatedFlashcard)
        
        todayStats.reviewedCards += 1
        if quality != .again {
            todayStats.correctAnswers += 1
        }
        
        storageService.saveDailyLearningStats(todayStats)
        
        currentSessionIndex += 1
    }
    
    func resetSession() {
        prepareSessionCards()
    }
    
    var isSessionCompleted: Bool {
        return sessionCards.isEmpty || currentSessionIndex >= sessionCards.count
    }
    
    private func updateTodayStats() {
        todayStats.remainingNew = newCardsForToday.count
        todayStats.remainingReviews = cardsToReview.count
        
        storageService.saveDailyLearningStats(todayStats)
    }
    
    func saveSettings() {
        storageService.saveLearningSettings(settings)
        updateCardsForToday()
    }
    
    private static func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    private func calculateNewEaseFactor(current: Double, quality: AnswerQuality) -> Double {
        let qualityValue = quality.rawValue
        return current + (0.1 - (5 - Double(qualityValue)) * (0.08 + (5 - Double(qualityValue)) * 0.02))
    }
    
    private func calculateNextInterval(for flashcard: Flashcard, quality: AnswerQuality) -> Int {
        let qualityValue = quality.rawValue
        
        switch (flashcard.learningState, flashcard.repetitionCount) {
        case (.new, _):
            return qualityValue == 0 ? 60 : 600
            
        case (.learning, 1):
            return qualityValue <= 1 ? 600 : 86400
            
        case (.learning, _):
            return qualityValue <= 1 ? 1800 : 432000
            
        case (.reviewing, _):
            let interval = calculateSpacedRepetitionInterval(for: flashcard, quality: quality)
            return interval
            
        default:
            return 86400
        }
    }
    
    private func calculateSpacedRepetitionInterval(for flashcard: Flashcard, quality: AnswerQuality) -> Int {
        let qualityValue = quality.rawValue
        
        if qualityValue <= 1 {
            return 86400
        }
        
        let repetition = flashcard.repetitionCount
        let easeFactor = flashcard.easeFactor
        
        var interval: Double
        
        switch repetition {
        case 0, 1:
            interval = 1
        case 2:
            interval = 6
        default:
            let lastInterval = Double(Calendar.current.dateComponents([.second], from: flashcard.lastReviewed ?? Date(timeIntervalSinceNow: -86400), to: Date()).second ?? 86400) / 86400.0
            interval = lastInterval * easeFactor
        }
        
        return Int(interval * 86400)
    }
}

struct TodayLearningStats: Codable {
    var reviewedCards: Int = 0
    var correctAnswers: Int = 0
    var remainingNew: Int = 0
    var remainingReviews: Int = 0
    
    var totalRemaining: Int {
        return remainingNew + remainingReviews
    }
    
    var percentCorrect: Double {
        guard reviewedCards > 0 else { return 0 }
        return Double(correctAnswers) / Double(reviewedCards) * 100
    }
}

enum AnswerQuality: Int, Codable {
    case again = 0
    case hard = 3
    case good = 4
    case easy = 5 
} 
