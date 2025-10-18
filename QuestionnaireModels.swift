import Foundation

// Representa uma única resposta a uma pergunta
struct QuestionAnswer: Identifiable {
    let id: UUID
    let text: String
    var answer: Int? // 1 a 5
}

// Representa um envio completo do questionário
struct QuestionnaireSubmission {
    let id: UUID
    let date: Date
    let answers: [QuestionAnswer]
}
