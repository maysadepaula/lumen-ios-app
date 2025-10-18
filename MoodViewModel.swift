import Foundation
import Combine

final class MoodViewModel: ObservableObject {
  
    @Published var selectedMood = "🙂"
    @Published var moodScore = 3
    @Published var note = ""
    @Published var lastSavedMessage = ""
    @Published var showAlert = false

    private let repo = MoodRepository()

    func saveCheckIn() {
        let entry = MoodEntry(
            date: Date(),
            mood: selectedMood,
            moodScore: moodScore,
            note: note.isEmpty ? nil : note
        )

        repo.saveMood(entry) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.lastSavedMessage = "✔️ Check-in salvo com sucesso!"
                 
                    self?.note = ""
                case .failure(let err):
                    self?.lastSavedMessage = "❌ Erro ao salvar: \(err.localizedDescription)"
                }
               
                self?.showAlert = true
            }
        }
    }
}
