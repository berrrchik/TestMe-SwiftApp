import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    var id: UUID
    var term: String
    var definition: String
    var categoryId: UUID
    var isLearned: Bool
    
    init(id: UUID = UUID(), term: String, definition: String, categoryId: UUID, isLearned: Bool = false) {
        self.id = id
        self.term = term
        self.definition = definition
        self.categoryId = categoryId
        self.isLearned = isLearned
    }
} 