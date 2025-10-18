import Foundation

struct MoodEntry: Identifiable, Codable {
    var id: Int64? 
    let date: Date
    let mood: String
    let moodScore: Int
    let note: String?
}
