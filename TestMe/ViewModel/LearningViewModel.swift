import Foundation
import SwiftUI

class LearningViewModel: ObservableObject {
    @Published var settings: LearningSettings
    @Published var cardsToReview: [Flashcard] = []
    @Published var newCardsForToday: [Flashcard] = []
    @Published var todayStats: TodayLearningStats

    @Published public var sessionCards: [Flashcard] = []
    public var currentSessionIndex: Int = 0

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

        let dueCards = allFlashcards.filter { card in
            if let next = card.nextReviewDate,
               card.learningState != .new && card.learningState != .mastered {
                return next <= now
            }
            return false
        }
        .sorted { $0.nextReviewDate! < $1.nextReviewDate! }

        cardsToReview = Array(dueCards.prefix(settings.dailyReviewCardsLimit))

        let newCardsToShow = max(0, settings.dailyNewCardsLimit - todayStats.reviewedCards + todayStats.remainingNew)
        
        let newCards = allFlashcards.filter { $0.learningState == .new }
            .sorted { ($0.term + $0.definition).count < ($1.term + $1.definition).count }
        newCardsForToday = Array(newCards.prefix(newCardsToShow))

        updateTodayStats()
        storageService.saveLastLearningSessionDate(now)
        storageService.saveDailyLearningStats(todayStats)
    }

    func prepareSessionCards() {
        let now = Date()
        
        let filteredReviewCards = cardsToReview.filter { card in
            if let nextDate = card.nextReviewDate {
                return nextDate <= now
            }
            return true
        }

        var mixed: [Flashcard] = []
        let newCount = newCardsForToday.count
        let reviewCount = filteredReviewCards.count
        
        if newCount == 0 {
            mixed = filteredReviewCards
        } else if reviewCount == 0 {
            mixed = newCardsForToday
        } else {
            let newPerReview = max(1, newCount / max(1, reviewCount))
            var newIndex = 0
            var reviewIndex = 0
            
            while newIndex < newCount || reviewIndex < reviewCount {
                for _ in 0..<min(3, reviewCount - reviewIndex) {
                    if reviewIndex < reviewCount {
                        mixed.append(filteredReviewCards[reviewIndex])
                        reviewIndex += 1
                    }
                }
                
                for _ in 0..<min(newPerReview, newCount - newIndex) {
                    if newIndex < newCount {
                        mixed.append(newCardsForToday[newIndex])
                        newIndex += 1
                    }
                }
            }
        }
        
        sessionCards = mixed
        currentSessionIndex = 0
        
        if sessionCards.isEmpty {
            sessionCards = newCardsForToday
        }
    }

    func getNextCardForSession() -> Flashcard? {
        guard currentSessionIndex < sessionCards.count else { return nil }
        return sessionCards[currentSessionIndex]
    }

    func processAnswer(for card: Flashcard, quality: AnswerQuality) {
        var updated = card
        let now = Date()
        let q = quality.rawValue
        
        let startOfToday = Calendar.current.startOfDay(for: now)

        if updated.learningState == .new {
            updated.learningState = .learning

            let tomorrow = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: startOfToday
            )!
            updated.nextReviewDate = tomorrow

            flashcardViewModel.updateFlashcard(updated)

            todayStats.reviewedCards += 1
            if q >= 3 { todayStats.correctAnswers += 1 }
            storageService.saveDailyLearningStats(todayStats)

            currentSessionIndex += 1
            return
        }

        let oldLast = card.lastReviewed
        let oldNext = card.nextReviewDate
        let oldReps = card.repetitionCount

        updated.lastReviewed = now

        if q < 3 {
            updated.repetitionCount = 0
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
            updated.nextReviewDate = tomorrow
            updated.learningState = .learning

        } else {
            let rawEF = updated.easeFactor
                + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02))
            updated.easeFactor = max(1.3, rawEF)

            updated.repetitionCount += 1

            let intervalDays = calculateSM2Interval(
                oldReps: oldReps,
                oldLast: oldLast,
                oldNext: oldNext,
                newEF: updated.easeFactor
            )
            
            updated.nextReviewDate = Calendar.current
                .date(byAdding: .day, value: intervalDays, to: startOfToday)

            if updated.repetitionCount >= 3 {
                updated.learningState = .reviewing
            }
            if updated.repetitionCount >= 5 {
                updated.learningState = .mastered
                updated.isLearned = true
            }
        }

        flashcardViewModel.updateFlashcard(updated)

        todayStats.reviewedCards += 1
        if q >= 3 { todayStats.correctAnswers += 1 }
        storageService.saveDailyLearningStats(todayStats)

        currentSessionIndex += 1
    }

    /// SM-2: 1-й повтор → 1 день, 2-й → 6 дней, далее: prevInterval * EF
    private func calculateSM2Interval(
        oldReps: Int,
        oldLast: Date?,
        oldNext: Date?,
        newEF: Double
    ) -> Int {
        switch oldReps {
        case 0: return 1
        case 1: return 6
        default:
            if let last = oldLast, let next = oldNext {
                let prevInterval = next.timeIntervalSince(last) / 86400.0
                let newInterval = prevInterval * newEF
                return max(1, Int(round(newInterval)))
            } else {
                return Int(round(newEF))
            }
        }
    }

    func isSessionFinished() -> Bool {
        return currentSessionIndex >= sessionCards.count || sessionCards.isEmpty
    }
    
    func hasAvailableCardsForToday() -> Bool {
        let now = Date()
        return sessionCards.contains { card in
            if let nextDate = card.nextReviewDate {
                return nextDate <= now
            }
            return true
        }
    }

    var isSessionCompleted: Bool {
        isSessionFinished()
    }

    func resetSession() {
        updateCardsForToday()
        prepareSessionCards()
    }

    private func updateTodayStats() {
        todayStats.remainingNew = newCardsForToday.count
        todayStats.remainingReviews = cardsToReview.count
    }

    func saveSettings() {
        storageService.saveLearningSettings(settings)
        updateCardsForToday()
    }

    private static func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
}

extension LearningViewModel {
    func skipCurrentCard() {
        currentSessionIndex += 1
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
