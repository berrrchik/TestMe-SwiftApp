import SwiftUI

struct HomeView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    
                    if !categoryViewModel.categories.isEmpty {
                        recentCategoriesSection
                    }
                    
                    statsSection
                }
                .padding()
            }
            .navigationTitle("TestMe")
        }
    }
    
    var heroSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Ваш помощник в изучении")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Создавайте карточки и проходите тесты для эффективного запоминания информации")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    var recentCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Категории")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categoryViewModel.categories.prefix(5)) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryCardView(
                                category: category,
                                count: flashcardViewModel.getFlashcards(forCategoryId: category.id).count
                            )
                        }
                    }
                }
            }
        }
    }
    
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                statsCard(
                    count: categoryViewModel.categories.count,
                    title: "Категорий",
                    icon: "folder.fill",
                    color: .blue
                )
                
                statsCard(
                    count: flashcardViewModel.flashcards.count,
                    title: "Карточек",
                    icon: "rectangle.stack.fill",
                    color: .green
                )
            }
            
//            if let learnedCount = learnedFlashcardsCount {
//                HStack(spacing: 15) {
//                    statsCard(
//                        count: learnedCount,
//                        title: "Изучено",
//                        icon: "checkmark.circle.fill",
//                        color: .green
//                    )
//                    
//                    statsCard(
//                        count: flashcardViewModel.flashcards.count - learnedCount,
//                        title: "Не изучено",
//                        icon: "xmark.circle.fill",
//                        color: .orange
//                    )
//                }
//            }
        }
    }
    
//    var learnedFlashcardsCount: Int? {
//        guard !flashcardViewModel.flashcards.isEmpty else { return nil }
//        return flashcardViewModel.flashcards.filter { $0.isLearned }.count
//    }
    
    func statsCard(count: Int, title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(CategoryViewModel())
        .environmentObject(FlashcardViewModel())
} 
