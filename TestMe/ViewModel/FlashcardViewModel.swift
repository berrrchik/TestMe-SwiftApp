import Foundation
import SwiftUI

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    
    private let storageService = StorageService.shared
    
    init() {
        loadFlashcards()
    }
    
    private func loadFlashcards() {
        flashcards = storageService.getFlashcards()
    }
    
    func saveFlashcards() {
        storageService.saveFlashcards(flashcards)
    }
    
    func addFlashcard(term: String, definition: String, categoryId: UUID) {
        let newFlashcard = Flashcard(term: term, definition: definition, categoryId: categoryId)
        flashcards.append(newFlashcard)
        saveFlashcards()
    }
    
    func updateFlashcard(_ flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
            saveFlashcards()
        }
    }
    
    func deleteFlashcard(at indexSet: IndexSet, in filteredCards: [Flashcard]) {
        let idsToDelete = indexSet.map { filteredCards[$0].id }
        flashcards.removeAll(where: { idsToDelete.contains($0.id) })
        saveFlashcards()
    }
    
    func deleteFlashcard(withId id: UUID) {
        flashcards.removeAll(where: { $0.id == id })
        saveFlashcards()
    }
    
    func deleteFlashcardsInCategory(categoryId: UUID) {
        flashcards.removeAll(where: { $0.categoryId == categoryId })
        saveFlashcards()
    }
    
    func getFlashcards(forCategoryId id: UUID) -> [Flashcard] {
        return flashcards.filter { $0.categoryId == id }
    }
    
    func toggleLearned(flashcard: Flashcard) {
        var updatedFlashcard = flashcard
        updatedFlashcard.isLearned.toggle()
        updateFlashcard(updatedFlashcard)
    }
} 
