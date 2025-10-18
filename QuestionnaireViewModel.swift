import Foundation
import Combine 

final class QuestionnaireViewModel: ObservableObject {
    @Published var questions: [QuestionAnswer] = [
        QuestionAnswer(id: UUID(), text: "Você sente que tem apoio no trabalho?", answer: nil),
        QuestionAnswer(id: UUID(), text: "Você sente sobrecarga de tarefas?", answer: nil),
        QuestionAnswer(id: UUID(), text: "Você consegue equilibrar vida pessoal e profissional?", answer: nil)
    ]
    
    @Published var submissionMessage: String = ""
    @Published var isSubmitted: Bool = false
    @Published var showAlert: Bool = false
    
    private let repository = QuestionnaireRepository()
    
    func submitAnswers() {
        // Verifica se todas as perguntas foram respondidas
        guard questions.allSatisfy({ $0.answer != nil }) else {
            self.submissionMessage = "⚠️ Por favor, responda todas as perguntas."
            self.showAlert = true
            return
        }
        
        let submission = QuestionnaireSubmission(
            id: UUID(),
            date: Date(),
            answers: questions
        )
        
        repository.saveSubmission(submission) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.submissionMessage = "✔️ Avaliação enviada com sucesso!"
                    self?.isSubmitted = true
                case .failure(let error):
                    self?.submissionMessage = "❌ Erro ao salvar: \(error.localizedDescription)"
                    self?.isSubmitted = false
                }
                self?.showAlert = true
            }
        }
    }
}
