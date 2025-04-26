import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    
    var body: some View {
        MainView()
            .environmentObject(categoryViewModel)
            .environmentObject(flashcardViewModel)
    }
}

#Preview {
    ContentView()
}
