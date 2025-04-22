import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var color: ColorOption
    
    init(id: UUID = UUID(), name: String, color: ColorOption = .blue) {
        self.id = id
        self.name = name
        self.color = color
    }
}

enum ColorOption: String, Codable, CaseIterable, Identifiable {
    case red
    case green
    case blue
    case yellow
    case purple
    case orange
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        }
    }
} 