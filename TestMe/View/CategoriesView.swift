import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var newCategoryName = ""
    @State private var selectedColor: ColorOption = .blue
    @State private var editingCategory: Category?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(categoryViewModel.categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryCardView(
                                category: category,
                                count: flashcardViewModel.getFlashcards(forCategoryId: category.id).count
                            )
                            .contextMenu {
                                Button {
                                    editingCategory = category
                                    showingEditSheet = true
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    categoryViewModel.deleteCategory(withId: category.id)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Категории")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addCategoryView
            }
            .sheet(isPresented: $showingEditSheet) {
                editCategoryView
            }
        }
    }
    
    var addCategoryView: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали категории")) {
                    TextField("Название категории", text: $newCategoryName)
                    
                    Picker("Цвет", selection: $selectedColor) {
                        ForEach(ColorOption.allCases) { colorOption in
                            HStack {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 20, height: 20)
                                Text(colorOption.rawValue.capitalized)
                            }
                            .tag(colorOption)
                        }
                    }
                }
            }
            .navigationTitle("Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        newCategoryName = ""
                        showingAddSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !newCategoryName.isEmpty {
                            categoryViewModel.addCategory(name: newCategoryName, color: selectedColor)
                            newCategoryName = ""
                            showingAddSheet = false
                        }
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            }
        }
    }
    
    var editCategoryView: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали категории")) {
                    TextField("Название категории", text: $newCategoryName)
                    
                    Picker("Цвет", selection: $selectedColor) {
                        ForEach(ColorOption.allCases) { colorOption in
                            HStack {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 20, height: 20)
                                Text(colorOption.rawValue.capitalized)
                            }
                            .tag(colorOption)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        resetFields()
                        showingEditSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let category = editingCategory, !newCategoryName.isEmpty {
                            var updatedCategory = category
                            updatedCategory.name = newCategoryName
                            updatedCategory.color = selectedColor
                            categoryViewModel.updateCategory(updatedCategory)
                            resetFields()
                            showingEditSheet = false
                        }
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            }
            .onAppear {
                if let category = editingCategory {
                    newCategoryName = category.name
                    selectedColor = category.color
                }
            }
        }
    }
    
    private func resetFields() {
        newCategoryName = ""
        selectedColor = .blue
        editingCategory = nil
    }
}

#Preview {
    CategoriesView()
        .environmentObject(CategoryViewModel())
        .environmentObject(FlashcardViewModel())
} 
