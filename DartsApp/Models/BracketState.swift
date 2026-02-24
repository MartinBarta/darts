import Foundation

/// A single match in the bracket
struct BracketMatch: Identifiable, Equatable {
    let id: String       // e.g. "r0-m0"
    var p1: String?      // Player 1 name (nil = TBD)
    var p2: String?      // Player 2 name
    var winner: String?
    var score: String?   // e.g. "3 : 1" or "BYE"
    var sourceMatch: [Int]? // indices of source matches in previous round
}

/// Custom matchup for manual bracket creation
struct CustomMatchup: Identifiable, Equatable {
    let id = UUID()
    var player1Name: String
    var player2Name: String
}

/// Bracket generation mode
enum BracketMode: String, CaseIterable {
    case random = "Náhodné nasazení"
    case custom = "Vlastní sestavení"
}

/// Full bracket tournament state
struct BracketState {
    var rounds: [[BracketMatch]]
    var totalRounds: Int
    var playerNames: [String]
}
