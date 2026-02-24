import Foundation

/// Persistence helper using UserDefaults / JSON file
class Storage {
    static let shared = Storage()
    private let playersKey = "dartPlayers"

    func savePlayers(_ players: [Player]) {
        if let data = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(data, forKey: playersKey)
        }
    }

    func loadPlayers() -> [Player] {
        guard let data = UserDefaults.standard.data(forKey: playersKey),
              let players = try? JSONDecoder().decode([Player].self, from: data) else {
            return []
        }
        return players
    }
}
