import SwiftUI

struct LearningView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @StateObject var learningViewModel: LearningViewModel
    
    @State private var showSettings = false
    @State private var currentFlashcard: Flashcard?
    @State private var showAnswer = false
    @State private var isCompleted = false
    
    init(flashcardViewModel: FlashcardViewModel) {
        _learningViewModel = StateObject(wrappedValue: LearningViewModel(flashcardViewModel: flashcardViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isCompleted {
                    completedView
                } else if let flashcard = currentFlashcard {
                    learningCardView(flashcard: flashcard)
                } else if learningViewModel.todayStats.totalRemaining == 0 {
                    emptyStateView
                } else {
                    startLearningView
                }
            }
            .navigationTitle("Персонализированное обучение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                learningViewModel.updateCardsForToday()
            }
            .sheet(isPresented: $showSettings) {
                LearningSettingsView(settings: $learningViewModel.settings, onSave: {
                    learningViewModel.saveSettings()
                    learningViewModel.updateCardsForToday()
                })
            }
        }
    }
    
    private var startLearningView: some View {
        VStack(spacing: 25) {
            progressHeader
            Spacer()
            VStack(spacing: 15) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                Text("Готовы к обучению?")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Сегодня вас ждет \(learningViewModel.todayStats.totalRemaining) карточек")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: startLearning) {
                Text("Начать обучение")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Новые:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("\(learningViewModel.todayStats.remainingNew)")
                            .font(.headline)
                        Text("карточек")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("На повторение:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("\(learningViewModel.todayStats.remainingReviews)")
                            .font(.headline)
                        Text("карточек")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            if learningViewModel.todayStats.reviewedCards > 0 {
                HStack {
                    Text("Сегодня изучено: \(learningViewModel.todayStats.reviewedCards) карточек")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(learningViewModel.todayStats.percentCorrect))% правильно")
                        .font(.subheadline)
                        .foregroundColor(learningViewModel.todayStats.percentCorrect >= 70 ? .green : .orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func learningCardView(flashcard: Flashcard) -> some View {
        VStack(spacing: 20) {
            ScrollView {
                progressHeader
                FlashcardView(
                    flashcard: flashcard,
                    isShowingAnswer: showAnswer,
                    onTap: { showAnswer.toggle() }
                )
                .padding(.horizontal)
                .padding(.vertical, 10)

                if showAnswer {
                    VStack(spacing: 15) {
                        Text("Насколько хорошо вы знаете эту карточку?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 10) {
                            answerButton(text: "Снова", color: .red) { processAnswer(quality: .again) }
                            answerButton(text: "Трудно", color: .orange) { processAnswer(quality: .hard) }
                            answerButton(text: "Хорошо", color: .blue) { processAnswer(quality: .good) }
                            answerButton(text: "Легко", color: .green) { processAnswer(quality: .easy) }
                        }
                    }
                    .transition(.opacity)
                } else {
                    Button(action: { showAnswer = true }) {
                        Text("Показать ответ")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
            }
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)
            Text("Все карточки на сегодня изучены!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Вернитесь завтра для новых карточек")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if learningViewModel.todayStats.reviewedCards > 0 {
                Text("Сегодня вы изучили \(learningViewModel.todayStats.reviewedCards) карточек")
                    .font(.headline)
                    .padding(.top)
            }
        }
        .padding()
    }

    private var completedView: some View {
        VStack(spacing: 25) {
            Image(systemName: "star.fill")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
            Text("Отличная работа!")
                .font(.title)
                .fontWeight(.bold)
            Text("Вы завершили сегодняшнюю сессию")
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                statsRow(label: "Карточек изучено:", value: "\(learningViewModel.todayStats.reviewedCards)")
                statsRow(label: "Правильных ответов:", value: "\(learningViewModel.todayStats.correctAnswers)")
                statsRow(label: "Точность:", value: "\(Int(learningViewModel.todayStats.percentCorrect))%")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            Spacer()
            Button(action: {
                isCompleted = false
                learningViewModel.resetSession()
                
                if let nextCard = learningViewModel.getNextCardForSession() {
                    currentFlashcard = nextCard
                } else {
                    currentFlashcard = nil
                }
            }) {
                Text("Вернуться")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func statsRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }

    private func answerButton(text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(color.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    private func startLearning() {
        learningViewModel.resetSession()
        isCompleted = false
        
        if let nextCard = learningViewModel.getNextCardForSession() {
            currentFlashcard = nextCard
        } else {
            isCompleted = true
        }
    }

    private func processAnswer(quality: AnswerQuality) {
        guard let flashcard = currentFlashcard else { return }
        learningViewModel.processAnswer(for: flashcard, quality: quality)
        
        if learningViewModel.isSessionFinished() {
            isCompleted = true
            currentFlashcard = nil
        } else {
            advanceToNextValidCard()
        }
        showAnswer = false
    }

    private func advanceToNextValidCard() {
        if learningViewModel.sessionCards.isEmpty {
            learningViewModel.resetSession()
        }
        
        if learningViewModel.isSessionFinished() {
            currentFlashcard = nil
            isCompleted = true
            return
        }
        
        var next = learningViewModel.getNextCardForSession()
        
        if next == nil && !learningViewModel.isSessionFinished() {
            learningViewModel.resetSession()
            next = learningViewModel.getNextCardForSession()
        }
        
        while let card = next,
              let nextDate = card.nextReviewDate,
              nextDate > Date() {
            learningViewModel.skipCurrentCard()
            next = learningViewModel.getNextCardForSession()
            
            if learningViewModel.isSessionFinished() {
                currentFlashcard = nil
                isCompleted = true
                return
            }
        }
        
        if let valid = next {
            currentFlashcard = valid
            isCompleted = false
        } else {
            currentFlashcard = nil
            isCompleted = true
        }
    }
}

struct LearningSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var settings: LearningSettings
    var onSave: () -> Void
    
    @State private var showingTimePicker = false
    @State private var tempSettings: LearningSettings
    
    init(settings: Binding<LearningSettings>, onSave: @escaping () -> Void) {
        self._settings = settings
        self.onSave = onSave
        self._tempSettings = State(initialValue: settings.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
//                Section(header: Text("Основные настройки")) {
//                    Toggle("Персонализированное обучение", isOn: $tempSettings.usePersonalizedLearning)
//                    
//                    Toggle("Интервальные повторения", isOn: $tempSettings.spacedRepetitionEnabled)
//                        .disabled(!tempSettings.usePersonalizedLearning)
//                }
                
                Section(header: Text("Ежедневные лимиты")) {
                    Stepper("Новых карточек: \(tempSettings.dailyNewCardsLimit)", value: $tempSettings.dailyNewCardsLimit, in: 5...50, step: 5)
                    
                    Stepper("Карточек на повторение: \(tempSettings.dailyReviewCardsLimit)", value: $tempSettings.dailyReviewCardsLimit, in: 10...100, step: 10)
                }
                
//                Section(header: Text("Напоминания")) {
//                    Toggle("Напоминать об обучении", isOn: $tempSettings.showStartLearningReminder)
//                    
//                    if tempSettings.showStartLearningReminder {
//                        Button(action: {
//                            showingTimePicker.toggle()
//                        }) {
//                            HStack {
//                                Text("Время напоминания")
//                                Spacer()
//                                if let reminderTime = tempSettings.reminderTime {
//                                    Text(reminderTimeFormatted(reminderTime))
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//                        }
//                    }
//                }
            }
            .navigationTitle("Настройки обучения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        settings = tempSettings
                        onSave()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTimePicker) {
                reminderTimePicker
            }
        }
    }
    
    var reminderTimePicker: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Выберите время",
                    selection: Binding(
                        get: { tempSettings.reminderTime ?? Date() },
                        set: { tempSettings.reminderTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
            }
            .navigationTitle("Время напоминания")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        showingTimePicker = false
                    }
                }
            }
            .padding()
        }
    }
    
    private func reminderTimeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    LearningView(flashcardViewModel: FlashcardViewModel())
        .environmentObject(CategoryViewModel())
        .environmentObject(FlashcardViewModel())
}
