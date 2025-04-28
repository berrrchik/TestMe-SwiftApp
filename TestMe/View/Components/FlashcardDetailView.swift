import SwiftUI

struct FlashcardDetailView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var flashcard: Flashcard
    
    @State private var isEditing = false
    @State private var editedTerm: String
    @State private var editedDefinition: String
    
    init(flashcard: Flashcard) {
        self.flashcard = flashcard
        _editedTerm = State(initialValue: flashcard.term)
        _editedDefinition = State(initialValue: flashcard.definition)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                CardFieldView(
                    title: "Термин",
                    content: isEditing ? $editedTerm : .constant(flashcard.term),
                    isTitle: true,
                    isEditing: isEditing
                )
                
                CardFieldView(
                    title: "Определение",
                    content: isEditing ? $editedDefinition : .constant(flashcard.definition),
                    isTitle: false, 
                    isEditing: isEditing
                )
                
                HStack {
                    Toggle(isOn: .init(
                        get: { flashcard.isLearned },
                        set: { isLearned in
                            var updatedFlashcard = flashcard
                            updatedFlashcard.isLearned = isLearned
                            flashcardViewModel.updateFlashcard(updatedFlashcard)
                        }
                    )) {
                        Text("Изучено")
                            .font(.headline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.top)
        }
        .navigationTitle(isEditing ? "Редактирование" : "Карточка")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        var updatedFlashcard = flashcard
                        updatedFlashcard.term = editedTerm
                        updatedFlashcard.definition = editedDefinition
                        flashcardViewModel.updateFlashcard(updatedFlashcard)
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Сохранить" : "Редактировать")
                }
                .disabled(isEditing && (editedTerm.isEmpty || editedDefinition.isEmpty))
            }
            
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        editedTerm = flashcard.term
                        editedDefinition = flashcard.definition
                        isEditing = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        FlashcardDetailView(flashcard: Flashcard(
            term: "Пример термина.",
            definition: "Это пример определения для просмотра. Это пример определения для просмотра. Это пример определения для просмотра. Это пример определения для просмотра",
            categoryId: UUID()
        ))
    }
    .environmentObject(FlashcardViewModel())
} 
