import SwiftUI

struct CategoryCardView: View {
    var category: Category
    var count: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Text("\(count) карточек")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(category.color.color.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: category.color.color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
} 
