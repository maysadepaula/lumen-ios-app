import Foundation

final class MoodRepository {
    private let db = DBManager.shared
    private let network = NetworkService.shared

    func saveMood(_ entry: MoodEntry, completion: @escaping (Result<Int64, Error>) -> Void) {
        // Esta função de salvar continua a mesma: salva localmente e depois tenta enviar para a nuvem.
        do {
            let newId = try db.insert(moodEntry: entry)
            print("💾 Humor salvo localmente com ID: \(newId)")
            
            network.postMoodEntry(entry) { result in
                switch result {
                case .success:
                    print("☁️ Humor enviado para a nuvem com sucesso.")
                case .failure(let err):
                    print("⚠️ Erro ao enviar humor para a nuvem: \(err.localizedDescription)")
                }
            }
            completion(.success(newId))
        } catch {
            print("❌ Falha crítica ao salvar humor localmente: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    func fetchMoods(completion: @escaping (Result<[MoodEntry], Error>) -> Void) {
        network.fetchMoodEntries(completion: completion)
    }
}
