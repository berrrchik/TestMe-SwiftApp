import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    var id: UUID
    var term: String
    var definition: String
    var categoryId: UUID
    var isLearned: Bool
    
    var learningState: LearningState
    var lastReviewed: Date?
    var nextReviewDate: Date?
    var repetitionCount: Int
    var easeFactor: Double
    
    init(id: UUID = UUID(), term: String, definition: String, categoryId: UUID, isLearned: Bool = false) {
        self.id = id
        self.term = term
        self.definition = definition
        self.categoryId = categoryId
        self.isLearned = isLearned
        
        self.learningState = .new
        self.lastReviewed = nil
        self.nextReviewDate = nil
        self.repetitionCount = 0
        self.easeFactor = 2.5
    }
}

enum LearningState: String, Codable {
    case new
    case learning
    case reviewing
    case mastered 
} 
