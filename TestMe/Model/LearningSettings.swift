import Foundation

struct LearningSettings: Codable {
    var usePersonalizedLearning: Bool
    var spacedRepetitionEnabled: Bool
    var dailyNewCardsLimit: Int
    var dailyReviewCardsLimit: Int
    var showStartLearningReminder: Bool
    var reminderTime: Date?
    
    static var `default`: LearningSettings {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 9 
        components.minute = 0
        
        return LearningSettings(
            usePersonalizedLearning: true,
            spacedRepetitionEnabled: true,
            dailyNewCardsLimit: 10,
            dailyReviewCardsLimit: 20,
            showStartLearningReminder: false,
            reminderTime: calendar.date(from: components)
        )
    }
} 
