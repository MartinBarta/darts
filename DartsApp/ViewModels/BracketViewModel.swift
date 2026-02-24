import Foundation
import Combine

/// Manages tournament bracket logic
class BracketViewModel: ObservableObject {
    @Published var bracketMode: BracketMode = .random
    @Published var shuffleEnabled: Bool = true
    @Published var selectedPlayerIndices: Set<Int> = []
    @Published var customMatchups: [CustomMatchup] = []
    @Published var bracketState: BracketState? = nil
    @Published var toastMessage: String? = nil
    @Published var showTournamentWinner: Bool = false
    @Published var tournamentWinnerName: String = ""

    // For score entry modal
    @Published var showScoreModal: Bool = false
    @Published var pendingMatchId: String = ""
    @Published var pendingPlayerIdx: Int = 0
    @Published var pendingWinnerName: String = ""
    @Published var pendingLoserName: String = ""
    @Published var winnerScoreText: String = ""
    @Published var loserScoreText: String = ""

    var isBracketActive: Bool { bracketState != nil }

    // MARK: - Bracket Setup

    func togglePlayerSelection(_ index: Int) {
        if selectedPlayerIndices.contains(index) {
            selectedPlayerIndices.remove(index)
        } else {
            selectedPlayerIndices.insert(index)
        }
    }

    func selectAllPlayers(count: Int) {
        selectedPlayerIndices = Set(0..<count)
    }

    func deselectAllPlayers() {
        selectedPlayerIndices.removeAll()
    }

    func addCustomMatchup(player1Name: String, player2Name: String) {
        guard !player1Name.isEmpty, !player2Name.isEmpty else {
            showToast("Vyberte oba hráče!")
            return
        }
        guard player1Name != player2Name else {
            showToast("Vyberte dva různé hráče!")
            return
        }
        customMatchups.append(CustomMatchup(player1Name: player1Name, player2Name: player2Name))
    }

    func removeCustomMatchup(at index: Int) {
        customMatchups.remove(at: index)
    }

    func assignedPlayerNames() -> Set<String> {
        var names = Set<String>()
        for m in customMatchups {
            names.insert(m.player1Name)
            names.insert(m.player2Name)
        }
        return names
    }

    // MARK: - Generate Bracket

    func generateBracket(from players: [Player]) {
        if bracketMode == .custom {
            generateCustomBracket()
        } else {
            generateRandomBracket(from: players)
        }
    }

    private func generateRandomBracket(from allPlayers: [Player]) {
        let indices = Array(selectedPlayerIndices).sorted()
        guard indices.count >= 2 else {
            showToast("Vyberte alespoň 2 hráče!")
            return
        }

        var playerNames = indices.map { allPlayers[$0].name }

        if shuffleEnabled {
            playerNames.shuffle()
        }

        buildBracket(from: playerNames)
    }

    private func generateCustomBracket() {
        guard !customMatchups.isEmpty else {
            showToast("Přidejte alespoň 1 zápas!")
            return
        }

        var playerNames: [String] = []
        for m in customMatchups {
            playerNames.append(m.player1Name)
            playerNames.append(m.player2Name)
        }

        guard playerNames.count >= 2 else {
            showToast("Potřebujete alespoň 2 hráče!")
            return
        }

        buildBracket(from: playerNames)
    }

    private func buildBracket(from playerNames: [String]) {
        var names: [String?] = playerNames
        let size = nextPow2(names.count)
        while names.count < size {
            names.append(nil)
        }

        let totalRounds = Int(log2(Double(size)))
        var rounds: [[BracketMatch]] = []

        // First round
        var firstRound: [BracketMatch] = []
        for i in stride(from: 0, to: names.count, by: 2) {
            var match = BracketMatch(
                id: "r0-m\(i/2)",
                p1: names[i],
                p2: names[i+1],
                winner: nil,
                score: nil
            )
            if match.p2 == nil { match.winner = match.p1; match.score = "BYE" }
            else if match.p1 == nil { match.winner = match.p2; match.score = "BYE" }
            firstRound.append(match)
        }
        rounds.append(firstRound)

        // Subsequent rounds
        for r in 1..<totalRounds {
            let prev = rounds[r-1]
            var thisRound: [BracketMatch] = []
            for i in stride(from: 0, to: prev.count, by: 2) {
                let p1 = prev[i].winner
                let p2 = i+1 < prev.count ? prev[i+1].winner : nil
                thisRound.append(BracketMatch(
                    id: "r\(r)-m\(i/2)",
                    p1: p1,
                    p2: p2,
                    winner: nil,
                    score: nil,
                    sourceMatch: [i, i+1]
                ))
            }
            rounds.append(thisRound)
        }

        bracketState = BracketState(
            rounds: rounds,
            totalRounds: totalRounds,
            playerNames: playerNames.compactMap { $0 }
        )
    }

    // MARK: - Bracket Interaction

    func bracketClickPlayer(matchId: String, playerIdx: Int) {
        guard var bs = bracketState else { return }
        guard let (roundIdx, matchIdx, match) = findMatch(matchId, in: bs) else { return }

        let winner = playerIdx == 0 ? match.p1 : match.p2
        guard let winnerName = winner, match.p1 != nil, match.p2 != nil else { return }

        let loserName = (winnerName == match.p1 ? match.p2 : match.p1) ?? ""

        pendingMatchId = matchId
        pendingPlayerIdx = playerIdx
        pendingWinnerName = winnerName
        pendingLoserName = loserName
        winnerScoreText = ""
        loserScoreText = ""
        showScoreModal = true
    }

    func confirmBracketScore() {
        guard !winnerScoreText.isEmpty, !loserScoreText.isEmpty else {
            showToast("Zadejte skóre obou hráčů!")
            return
        }
        showScoreModal = false
        selectWinner(matchId: pendingMatchId, playerIdx: pendingPlayerIdx, scoreStr: "\(winnerScoreText) : \(loserScoreText)")
    }

    func skipBracketScore() {
        showScoreModal = false
        selectWinner(matchId: pendingMatchId, playerIdx: pendingPlayerIdx, scoreStr: nil)
    }

    func closeBracketScoreModal() {
        showScoreModal = false
    }

    private func selectWinner(matchId: String, playerIdx: Int, scoreStr: String?) {
        guard var bs = bracketState else { return }
        guard let (roundIdx, matchIdx, match) = findMatch(matchId, in: bs) else { return }

        let winner = playerIdx == 0 ? match.p1 : match.p2
        guard let winnerName = winner, match.p1 != nil, match.p2 != nil else { return }

        // Clear forward results if re-selecting
        if bs.rounds[roundIdx][matchIdx].winner != nil {
            clearForwardResults(fromRound: roundIdx, fromMatch: matchIdx, in: &bs)
        }

        bs.rounds[roundIdx][matchIdx].winner = winnerName
        bs.rounds[roundIdx][matchIdx].score = scoreStr

        // Propagate to next round
        if roundIdx + 1 < bs.totalRounds {
            let nmi = matchIdx / 2
            if matchIdx % 2 == 0 {
                bs.rounds[roundIdx + 1][nmi].p1 = winnerName
            } else {
                bs.rounds[roundIdx + 1][nmi].p2 = winnerName
            }
        }

        bracketState = bs

        // Check if final is decided
        let finalMatch = bs.rounds[bs.totalRounds - 1][0]
        if let finalWinner = finalMatch.winner {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.tournamentWinnerName = finalWinner
                self?.showTournamentWinner = true
            }
        }
    }

    private func clearForwardResults(fromRound: Int, fromMatch: Int, in bs: inout BracketState) {
        bs.rounds[fromRound][fromMatch].winner = nil
        bs.rounds[fromRound][fromMatch].score = nil
        if fromRound + 1 < bs.totalRounds {
            let nmi = fromMatch / 2
            if fromMatch % 2 == 0 {
                bs.rounds[fromRound + 1][nmi].p1 = nil
            } else {
                bs.rounds[fromRound + 1][nmi].p2 = nil
            }
            if bs.rounds[fromRound + 1][nmi].winner != nil {
                clearForwardResults(fromRound: fromRound + 1, fromMatch: nmi, in: &bs)
            }
        }
    }

    func resetBracket() {
        bracketState = nil
        customMatchups = []
        showTournamentWinner = false
        bracketMode = .random
    }

    // MARK: - Helpers

    private func findMatch(_ matchId: String, in bs: BracketState) -> (Int, Int, BracketMatch)? {
        for r in 0..<bs.rounds.count {
            for m in 0..<bs.rounds[r].count {
                if bs.rounds[r][m].id == matchId {
                    return (r, m, bs.rounds[r][m])
                }
            }
        }
        return nil
    }

    func nextPow2(_ n: Int) -> Int {
        var p = 1
        while p < n { p *= 2 }
        return p
    }

    func roundName(roundIdx: Int, totalRounds: Int) -> String {
        let f = totalRounds - 1 - roundIdx
        switch f {
        case 0: return "Finále"
        case 1: return "Semifinále"
        case 2: return "Čtvrtfinále"
        default: return "Kolo \(roundIdx + 1)"
        }
    }

    func matchStats() -> (total: Int, completed: Int) {
        guard let bs = bracketState else { return (0, 0) }
        var total = 0, completed = 0
        for round in bs.rounds {
            for m in round {
                if m.p1 != nil || m.p2 != nil { total += 1 }
                if m.winner != nil { completed += 1 }
            }
        }
        return (total, completed)
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }
}
