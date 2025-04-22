import Foundation

struct QuizResult: Identifiable, Codable {
    var id: UUID
    var categoryId: UUID
    var date: Date
    var correctAnswers: Int
    var totalQuestions: Int
    
    var percentageCorrect: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    init(id: UUID = UUID(), categoryId: UUID, date: Date = Date(), correctAnswers: Int, totalQuestions: Int) {
        self.id = id
        self.categoryId = categoryId
        self.date = date
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
    }
} 