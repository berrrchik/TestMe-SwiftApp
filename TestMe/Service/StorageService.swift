import Foundation

class StorageService {
    private enum Keys {
        static let categories = "categories"
        static let flashcards = "flashcards"
        static let quizResults = "quizResults"
    }
    
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Categories
    
    func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: Keys.categories)
        }
    }
    
    func getCategories() -> [Category] {
        guard let data = defaults.data(forKey: Keys.categories),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories
    }
    
    // MARK: - Flashcards
    
    func saveFlashcards(_ flashcards: [Flashcard]) {
        if let encoded = try? JSONEncoder().encode(flashcards) {
            defaults.set(encoded, forKey: Keys.flashcards)
        }
    }
    
    func getFlashcards() -> [Flashcard] {
        guard let data = defaults.data(forKey: Keys.flashcards),
              let flashcards = try? JSONDecoder().decode([Flashcard].self, from: data) else {
            return []
        }
        return flashcards
    }
    
    // MARK: - Quiz Results
    
    func saveQuizResults(_ results: [QuizResult]) {
        if let encoded = try? JSONEncoder().encode(results) {
            defaults.set(encoded, forKey: Keys.quizResults)
        }
    }
    
    func getQuizResults() -> [QuizResult] {
        guard let data = defaults.data(forKey: Keys.quizResults),
              let results = try? JSONDecoder().decode([QuizResult].self, from: data) else {
            return []
        }
        return results
    }
} 