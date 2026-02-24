import Foundation

/// The type of dart game
enum GameType: Int, CaseIterable {
    case threeOhOne = 301
    case fiveOhOne = 501
}

/// Multiplier for a dart throw
enum DartMultiplier: String, CaseIterable {
    case single = "Single"
    case double_ = "Double"
    case treble = "Treble"

    var shortLabel: String {
        switch self {
        case .single: return "S"
        case .double_: return "D"
        case .treble: return "T"
        }
    }

    var multiplierValue: Int {
        switch self {
        case .single: return 1
        case .double_: return 2
        case .treble: return 3
        }
    }
}

/// A single dart throw
struct DartThrow: Identifiable, Equatable {
    let id = UUID()
    let value: Int      // Actual point value
    let label: String   // Display label like "T20", "BULL", "VEDLE"
}

/// Player state during a game
struct GamePlayerState: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var score: Int
    var darts: Int          // Total darts thrown
    var totalThrown: Int    // Total points scored (for averaging)
}

/// A snapshot for undo functionality
struct MoveHistoryEntry {
    var playerIdx: Int
    var dartIdx: Int
    var dartValue: Int
    var dartLabel: String
    var prevScore: Int
    var prevDarts: Int
    var prevTotal: Int
    var prevRound: Int
    var prevTurnDarts: [DartThrow]
    var prevTurnSnapshot: Int
}

/// State of the entire dart game
struct GameState {
    var type: GameType
    var players: [GamePlayerState]
    var currentPlayer: Int = 0
    var round: Int = 1
    var currentDart: Int = 0        // 0, 1, or 2
    var turnDarts: [DartThrow] = []
    var turnScoreSnapshot: Int
    var moveHistory: [MoveHistoryEntry] = []
    var isFinished: Bool = false
    var winnerName: String? = nil
}
