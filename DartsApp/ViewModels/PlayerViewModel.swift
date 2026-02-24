import Foundation
import Combine

/// Manages the list of selected players (both pro and custom)
class PlayerViewModel: ObservableObject {
    @Published var selectedPlayers: [Player] = []
    @Published var searchText: String = ""
    @Published var toastMessage: String? = nil

    var proPlayers: [Player] {
        let lower = searchText.lowercased()
        if lower.isEmpty { return ProPlayerData.all }
        return ProPlayerData.all.filter { $0.name.lowercased().contains(lower) }
    }

    init() {
        selectedPlayers = Storage.shared.loadPlayers()
        // Migrate: update pro player images
        migrateProImages()
    }

    private func migrateProImages() {
        for i in selectedPlayers.indices {
            if !selectedPlayers[i].isCustom {
                if let pro = ProPlayerData.all.first(where: { $0.name == selectedPlayers[i].name }) {
                    selectedPlayers[i].imageURL = pro.imageURL
                }
            }
        }
        save()
    }

    private func save() {
        Storage.shared.savePlayers(selectedPlayers)
    }

    func isPlayerSelected(_ name: String) -> Bool {
        selectedPlayers.contains { $0.name == name }
    }

    func toggleProPlayer(_ pro: Player) {
        if let idx = selectedPlayers.firstIndex(where: { $0.name == pro.name }) {
            selectedPlayers.remove(at: idx)
        } else {
            selectedPlayers.append(
                Player(name: pro.name, country: pro.country, imageURL: pro.imageURL, isCustom: false)
            )
        }
        save()
    }

    func addCustomPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !selectedPlayers.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else {
            showToast("Hráč s tímto jménem již existuje!")
            return
        }
        selectedPlayers.append(Player(name: trimmed, country: "🎯", imageURL: nil, isCustom: true))
        save()
    }

    func removePlayer(_ player: Player) {
        selectedPlayers.removeAll { $0.name == player.name }
        save()
    }

    func clearAll() {
        selectedPlayers.removeAll()
        save()
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }

    static func playerInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first.map { String($0) } }.joined().uppercased()
    }
}
