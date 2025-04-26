import SwiftUI

struct StatsView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    private let storageService = StorageService.shared
    
    @State private var quizResults: [QuizResult] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if quizResults.isEmpty {
                        emptyStateView
                    } else {
                        summaryStatsSection
                        recentResultsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Статистика")
            .onAppear {
                loadQuizResults()
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Нет данных о квизах")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Пройдите хотя бы один квиз, чтобы увидеть статистику")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    var summaryStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Общая статистика")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                statsCard(
                    value: "\(quizResults.count)",
                    title: "Квизов пройдено",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                statsCard(
                    value: "\(averagePercentage)%",
                    title: "Средний результат",
                    icon: "chart.bar.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: 15) {
                statsCard(
                    value: "\(totalCorrectAnswers)",
                    title: "Правильных ответов",
                    icon: "hand.thumbsup.fill",
                    color: .green
                )
                
                statsCard(
                    value: "\(totalQuestions - totalCorrectAnswers)",
                    title: "Неправильных ответов",
                    icon: "hand.thumbsdown.fill",
                    color: .red
                )
            }
        }
    }
    
    var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Недавние результаты")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(quizResults.sorted(by: { $0.date > $1.date }).prefix(5)) { result in
                recentResultCard(result: result)
            }
        }
    }
    
    func recentResultCard(result: QuizResult) -> some View {
        let categoryName = categoryViewModel.categories.first(where: { $0.id == result.categoryId })?.name ?? "Неизвестно"
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(categoryName)
                        .font(.headline)
                    
                    Text(result.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(result.correctAnswers) из \(result.totalQuestions)")
                        .font(.headline)
                    
                    Text("\(Int(result.percentageCorrect))%")
                        .font(.subheadline)
                        .foregroundColor(result.percentageCorrect > 70 ? .green : .orange)
                }
            }
            
            ProgressView(value: Double(result.correctAnswers), total: Double(result.totalQuestions))
                .progressViewStyle(LinearProgressViewStyle())
                .tint(result.percentageCorrect > 70 ? .green : .orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    func statsCard(value: String, title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                Text(value)
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
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func loadQuizResults() {
        quizResults = storageService.getQuizResults()
    }
    
    private var totalQuestions: Int {
        quizResults.reduce(0) { $0 + $1.totalQuestions }
    }
    
    private var totalCorrectAnswers: Int {
        quizResults.reduce(0) { $0 + $1.correctAnswers }
    }
    
    private var averagePercentage: Int {
        guard !quizResults.isEmpty else { return 0 }
        let totalPercentage = quizResults.reduce(0.0) { $0 + $1.percentageCorrect }
        return Int(totalPercentage / Double(quizResults.count))
    }
}

#Preview {
    StatsView()
        .environmentObject(CategoryViewModel())
} 