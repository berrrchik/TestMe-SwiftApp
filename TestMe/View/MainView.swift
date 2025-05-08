import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Label("Категории", systemImage: "folder")
                }
                .tag(1)
            
            LearningView(flashcardViewModel: flashcardViewModel)
                .tabItem {
                    Label("Обучение", systemImage: "brain")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(FlashcardViewModel())
} 