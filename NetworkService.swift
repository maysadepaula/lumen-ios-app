import Foundation
import FirebaseFirestore
import FirebaseAuth

enum NetworkError: Error {
    case noUserLoggedIn, serverError(Error?), invalidData
}

final class NetworkService {
    static let shared = NetworkService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func getUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // --- FUNÇÕES DE CHECK-IN DE HUMOR ---
    
    func postMoodEntry(_ entry: MoodEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = getUserID() else {
            completion(.failure(NetworkError.noUserLoggedIn))
            return
        }
        
        let data: [String: Any] = [
            "date": Timestamp(date: entry.date),
            "mood": entry.mood,
            "moodScore": entry.moodScore,
            "note": entry.note ?? NSNull()
        ]
        
        db.collection("users").document(userID).collection("moodEntries").addDocument(data: data) { error in
            if let error = error {
                print("❌ Erro ao salvar MoodEntry no Firestore: \(error.localizedDescription)")
                completion(.failure(NetworkError.serverError(error)))
            } else {
                print("☁️ MoodEntry salvo no Firestore com sucesso.")
                completion(.success(()))
            }
        }
    }
    
    func fetchMoodEntries(completion: @escaping (Result<[MoodEntry], Error>) -> Void) {
        guard let userID = getUserID() else {
            completion(.failure(NetworkError.noUserLoggedIn))
            return
        }
        
        db.collection("users").document(userID).collection("moodEntries").order(by: "date", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(NetworkError.serverError(error)))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let moodEntries = documents.compactMap { doc -> MoodEntry? in
                let data = doc.data()
                guard let timestamp = data["date"] as? Timestamp else { return nil }
                
                return MoodEntry(
                    id: nil, // ID do SQLite não é mais necessário aqui
                    date: timestamp.dateValue(),
                    mood: data["mood"] as? String ?? "",
                    moodScore: data["moodScore"] as? Int ?? 0,
                    note: data["note"] as? String
                )
            }
            
            completion(.success(moodEntries))
        }
    }

    // --- FUNÇÕES DE QUESTIONÁRIO ---

    func postQuestionnaire(_ submission: QuestionnaireSubmission, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = getUserID() else {
            completion(.failure(NetworkError.noUserLoggedIn))
            return
        }
        
        let answersData = submission.answers.map {
            ["question": $0.text, "answer": $0.answer ?? 0]
        }
        
        let submissionData: [String: Any] = [
            "date": Timestamp(date: submission.date),
            "answers": answersData
        ]
        
        db.collection("users").document(userID).collection("questionnaireSubmissions").addDocument(data: submissionData) { error in
            if let error = error {
                completion(.failure(NetworkError.serverError(error)))
            } else {
                print("☁️ Questionário salvo no Firestore com sucesso.")
                completion(.success(()))
            }
        }
    }
}
