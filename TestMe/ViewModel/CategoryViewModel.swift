import Foundation
import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    private let storageService = StorageService.shared
    
    init() {
        loadCategories()
    }
    
    private func loadCategories() {
        categories = storageService.getCategories()
        
        if categories.isEmpty {
            let defaultCategory = Category(name: "Основная категория")
            categories.append(defaultCategory)
            saveCategories()
        }
    }
    
    func saveCategories() {
        storageService.saveCategories(categories)
    }
    
    func addCategory(name: String, color: ColorOption) {
        let newCategory = Category(name: name, color: color)
        categories.append(newCategory)
        saveCategories()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(at indexSet: IndexSet) {
        categories.remove(atOffsets: indexSet)
        saveCategories()
    }
    
    func deleteCategory(withId id: UUID) {
        categories.removeAll(where: { $0.id == id })
        saveCategories()
    }
} 
