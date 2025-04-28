import SwiftUI

struct CardFieldView: View {
    var title: String
    @Binding var content: String
    var isTitle: Bool
    var isEditing: Bool
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                
                if isEditing {
                    if isTitle {
                        TextField("Введите \(title.lowercased())", text: $content)
                            .font(isTitle ? .title3 : .body)
                            .fontWeight(isTitle ? .medium : .regular)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        TextEditor(text: $content)
                            .font(.body)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 200)
                    }
                } else {
                    Text(content)
                        .font(isTitle ? .title3 : .body)
                        .fontWeight(isTitle ? .medium : .regular)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct EditableCardFieldView: View {
    var title: String
    @Binding var content: String
    var isTitle: Bool
    
    var body: some View {
        CardFieldView(
            title: title, 
            content: $content, 
            isTitle: isTitle, 
            isEditing: true
        )
    }
}

#Preview {
    VStack {
        CardFieldView(
            title: "Термин",
            content: .constant("Пример текста для preview"),
            isTitle: true,
            isEditing: false
        )
        
        CardFieldView(
            title: "Определение",
            content: .constant("Это более длинный текст для preview компонента. Здесь показано, как компонент справляется с многострочным текстом и автоматически подстраивает свою высоту."),
            isTitle: false,
            isEditing: true
        )
    }
    .padding()
} 
