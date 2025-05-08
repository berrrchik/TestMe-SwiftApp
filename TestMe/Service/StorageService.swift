import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Categories
    
    func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: UserDefaultsKeys.categories)
        }
    }
    
    func getCategories() -> [Category] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.categories),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories
    }
    
    // MARK: - Flashcards
    
    func saveFlashcards(_ flashcards: [Flashcard]) {
        if let encoded = try? JSONEncoder().encode(flashcards) {
            defaults.set(encoded, forKey: UserDefaultsKeys.flashcards)
        }
    }
    
    func getFlashcards() -> [Flashcard] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.flashcards),
              let flashcards = try? JSONDecoder().decode([Flashcard].self, from: data) else {
            return []
        }
        return flashcards
    }
    
    // MARK: - Quiz Results
    
    func saveQuizResults(_ results: [QuizResult]) {
        if let encoded = try? JSONEncoder().encode(results) {
            defaults.set(encoded, forKey: UserDefaultsKeys.quizResults)
        }
    }
    
    func getQuizResults() -> [QuizResult] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.quizResults),
              let results = try? JSONDecoder().decode([QuizResult].self, from: data) else {
            return []
        }
        return results
    }
    
    // MARK: - Learning Settings
    
    func saveLearningSettings(_ settings: LearningSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: UserDefaultsKeys.learningSettings)
        }
    }
    
    func getLearningSettings() -> LearningSettings {
        guard let data = defaults.data(forKey: UserDefaultsKeys.learningSettings),
              let settings = try? JSONDecoder().decode(LearningSettings.self, from: data) else {
            return LearningSettings.default
        }
        return settings
    }
    
    // MARK: - Learning Session Tracking
    
    func saveLastLearningSessionDate(_ date: Date) {
        defaults.set(date, forKey: UserDefaultsKeys.lastLearningSessionDate)
    }
    
    func getLastLearningSessionDate() -> Date? {
        return defaults.object(forKey: UserDefaultsKeys.lastLearningSessionDate) as? Date
    }
    
    func saveDailyLearningStats(_ stats: TodayLearningStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            defaults.set(encoded, forKey: UserDefaultsKeys.dailyLearningStats)
        }
    }
    
    func getDailyLearningStats() -> TodayLearningStats? {
        guard let data = defaults.data(forKey: UserDefaultsKeys.dailyLearningStats),
              let stats = try? JSONDecoder().decode(TodayLearningStats.self, from: data) else {
            return nil
        }
        return stats
    }
} 