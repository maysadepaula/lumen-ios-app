import Foundation
import SQLite

final class DBManager {
    static let shared = DBManager()
    private var db: Connection?

    // Tabela de Humor
    private let moodTable = Table("mood_entries")
    private let id = Expression<Int64>("id")
    private let date = Expression<String>("date")
    private let mood = Expression<String>("mood")
    private let moodScore = Expression<Int>("mood_score")
    private let note = Expression<String?>("note")
    
    // Tabela do Questionário
    private let answersTable = Table("questionnaire_answers")
    private let answerId = Expression<Int64>("id")
    private let submissionId = Expression<String>("submission_id")
    private let questionText = Expression<String>("question_text")
    private let answerValue = Expression<Int>("answer_value")
    private let submissionDate = Expression<String>("submission_date")

    private init() {
        do {
            let docs = try FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true
            )
            // Nome do banco adaptado para o novo app
            let dbURL = docs.appendingPathComponent("lumen.sqlite3")
            db = try Connection(dbURL.path)
            createTables()
            print("✅ Banco de dados conectado em: \(dbURL.path)")
        } catch {
            print("❌ Erro ao inicializar o banco: \(error.localizedDescription)")
            db = nil
        }
    }

    private func createTables() {
        guard let db = db else { return }
        do {
            // Tabela de Humor
            try db.run(moodTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(date)
                t.column(mood)
                t.column(moodScore)
                t.column(note)
            })
            
            // Tabela de Respostas do Questionário
            try db.run(answersTable.create(ifNotExists: true) { t in
                t.column(answerId, primaryKey: .autoincrement)
                t.column(submissionId)
                t.column(questionText)
                t.column(answerValue)
                t.column(submissionDate)
            })
            
        } catch {
            print("⚠️ Erro ao criar tabelas: \(error.localizedDescription)")
        }
    }

    // --- Funções para Humor ---
    
    func insert(moodEntry: MoodEntry) throws -> Int64 {
        guard let db = db else { throw NSError(domain: "DB", code: 0, userInfo: [NSLocalizedDescriptionKey: "Banco não inicializado"]) }
        let iso = ISO8601DateFormatter().string(from: moodEntry.date)
        let insert = moodTable.insert(
            date <- iso, mood <- moodEntry.mood,
            moodScore <- moodEntry.moodScore, note <- moodEntry.note
        )
        return try db.run(insert)
    }

    func fetchAllMoods() throws -> [MoodEntry] {
        guard let db = db else { return [] }
        var items: [MoodEntry] = []
        for row in try db.prepare(moodTable.order(date.desc)) {
            let d = ISO8601DateFormatter().date(from: row[date]) ?? Date()
            items.append(
                MoodEntry(
                    id: row[id], date: d,
                    mood: row[mood], moodScore: row[moodScore],
                    note: row[note]
                )
            )
        }
        return items
    }
    
    // --- Funções para Questionário ---

    func insert(submission: QuestionnaireSubmission) throws {
        guard let db = db else { throw NSError(domain: "DB", code: 0, userInfo: [NSLocalizedDescriptionKey: "Banco não inicializado"]) }
        
        let subId = submission.id.uuidString
        let subDate = ISO8601DateFormatter().string(from: submission.date)
        
        for answer in submission.answers {
            guard let answerVal = answer.answer else { continue }
            
            let insert = answersTable.insert(
                submissionId <- subId,
                questionText <- answer.text,
                answerValue <- answerVal,
                submissionDate <- subDate
            )
            try db.run(insert)
        }
    }
}
