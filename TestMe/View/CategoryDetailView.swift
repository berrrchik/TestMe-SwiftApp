import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    var category: Category
    
    @State private var showingAddSheet = false
    @State private var newTerm = ""
    @State private var newDefinition = ""
    @State private var editMode = EditMode.inactive
    @State private var showingQuizView = false
    @State private var showingCarouselView = false
    
    var flashcards: [Flashcard] {
        flashcardViewModel.getFlashcards(forCategoryId: category.id)
    }
    
    var body: some View {
        VStack {
            if flashcards.isEmpty {
                emptyStateView
            } else {
                flashcardListView
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                    
                    if !flashcards.isEmpty {
                        Button(action: { showingCarouselView = true }) {
                            Image(systemName: "rectangle.stack")
                        }
                        
                        Button(action: { showingQuizView = true }) {
                            Image(systemName: "play.fill")
                        }
                    }
                    
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            addFlashcardView
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingQuizView) {
            QuizView(category: category, flashcards: flashcards)
        }
        .sheet(isPresented: $showingCarouselView) {
            NavigationView {
                FlashcardsCarouselView(flashcards: flashcards)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Закрыть") {
                                showingCarouselView = false
                            }
                        }
                    }
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(category.color.color)
            
            Text("Нет карточек")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Добавьте карточки, чтобы начать изучение")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddSheet = true }) {
                Text("Добавить карточку")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(category.color.color)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
    
    var flashcardListView: some View {
        List {
            ForEach(flashcards) { flashcard in
                NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(flashcard.term)
                                .font(.headline)
                                .lineLimit(1)
                            
                            if flashcard.isLearned {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.footnote)
                            }
                        }
                        
                        Text(flashcard.definition)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        flashcardViewModel.deleteFlashcard(withId: flashcard.id)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        var modifiedFlashcard = flashcard
                        modifiedFlashcard.isLearned.toggle()
                        flashcardViewModel.updateFlashcard(modifiedFlashcard)
                    } label: {
                        Label(
                            flashcard.isLearned ? "Не изучено" : "Изучено",
                            systemImage: flashcard.isLearned ? "xmark.circle" : "checkmark.circle"
                        )
                    }
                    .tint(flashcard.isLearned ? .orange : .green)
                }
            }
            .onDelete { indexSet in
                flashcardViewModel.deleteFlashcard(at: indexSet, in: flashcards)
            }
        }
    }
    
    var addFlashcardView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    EditableCardFieldView(title: "Термин", content: $newTerm, isTitle: true)
                    
                    EditableCardFieldView(title: "Определение", content: $newDefinition, isTitle: false)
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("Новая карточка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        resetFields()
                        showingAddSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !newTerm.isEmpty && !newDefinition.isEmpty {
                            flashcardViewModel.addFlashcard(
                                term: newTerm,
                                definition: newDefinition,
                                categoryId: category.id
                            )
                            resetFields()
                            showingAddSheet = false
                        }
                    }
                    .disabled(newTerm.isEmpty || newDefinition.isEmpty)
                }
            }
        }
    }
    
    private func resetFields() {
        newTerm = ""
        newDefinition = ""
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(category: Category(name: "Тестовая категория"))
    }
    .environmentObject(FlashcardViewModel())
} 