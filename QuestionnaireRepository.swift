import Foundation

final class QuestionnaireRepository {
    private let db = DBManager.shared
    private let network = NetworkService.shared

    func saveSubmission(_ submission: QuestionnaireSubmission, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // 1. Salva no banco de dados local.
            try db.insert(submission: submission)
            print("💾 Questionário salvo localmente.")

            // 2. Tenta enviar para a "nuvem".
            network.postQuestionnaire(submission) { result in
                switch result {
                case .success:
                    print("☁️ Questionário enviado para a nuvem com sucesso.")
                case .failure(let error):
                    print("⚠️ Erro ao enviar questionário para a nuvem: \(error.localizedDescription)")
                }
            }
            completion(.success(()))
        } catch {
            print("❌ Falha crítica ao salvar questionário localmente: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
