import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
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
            
            StatsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(FlashcardViewModel())
} 