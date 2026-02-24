import Foundation
import Combine

/// Manages 301/501 dart game logic
class GameViewModel: ObservableObject {
    @Published var gameType: GameType = .threeOhOne
    @Published var selectedPlayer1Name: String = ""
    @Published var selectedPlayer2Name: String = ""
    @Published var gameState: GameState? = nil
    @Published var currentMultiplier: DartMultiplier = .single
    @Published var toastMessage: String? = nil
    @Published var showWinner: Bool = false

    var isGameActive: Bool { gameState != nil && !(gameState?.isFinished ?? true) }

    // MARK: - Game Setup

    func startGame(players: [Player]) {
        guard !selectedPlayer1Name.isEmpty, !selectedPlayer2Name.isEmpty else {
            showToast("Vyberte oba hráče!")
            return
        }
        guard selectedPlayer1Name != selectedPlayer2Name else {
            showToast("Vyberte dva různé hráče!")
            return
        }

        let startScore = gameType.rawValue
        gameState = GameState(
            type: gameType,
            players: [
                GamePlayerState(name: selectedPlayer1Name, score: startScore, darts: 0, totalThrown: 0),
                GamePlayerState(name: selectedPlayer2Name, score: startScore, darts: 0, totalThrown: 0)
            ],
            turnScoreSnapshot: startScore
        )
        currentMultiplier = .single
    }

    func resetGame() {
        gameState = nil
        showWinner = false
    }

    // MARK: - Dart Input

    func dartNumber(_ num: Int) {
        guard var gs = gameState, gs.currentDart < 3, !gs.isFinished else { return }
        let value = num * currentMultiplier.multiplierValue
        let label = "\(currentMultiplier.shortLabel)\(num)"
        applyDart(value: value, label: label)
    }

    func dartBull() {
        applyDart(value: 50, label: "BULL")
    }

    func dartOuter() {
        applyDart(value: 25, label: "OUT25")
    }

    func dartMiss() {
        applyDart(value: 0, label: "VEDLE")
    }

    func undoDart() {
        guard var gs = gameState, !gs.moveHistory.isEmpty else { return }
        let last = gs.moveHistory.removeLast()
        gs.players[last.playerIdx].score = last.prevScore
        gs.players[last.playerIdx].darts = last.prevDarts
        gs.players[last.playerIdx].totalThrown = last.prevTotal
        gs.currentPlayer = last.playerIdx
        gs.currentDart = last.dartIdx
        gs.round = last.prevRound
        gs.turnDarts = last.prevTurnDarts
        gs.turnScoreSnapshot = last.prevTurnSnapshot
        gs.isFinished = false
        gs.winnerName = nil
        showWinner = false
        gameState = gs
    }

    // MARK: - Core Dart Logic

    private func applyDart(value: Int, label: String) {
        guard var gs = gameState, gs.currentDart < 3, !gs.isFinished else { return }
        let playerIdx = gs.currentPlayer
        var player = gs.players[playerIdx]

        // Save undo history
        gs.moveHistory.append(MoveHistoryEntry(
            playerIdx: playerIdx,
            dartIdx: gs.currentDart,
            dartValue: value,
            dartLabel: label,
            prevScore: player.score,
            prevDarts: player.darts,
            prevTotal: player.totalThrown,
            prevRound: gs.round,
            prevTurnDarts: gs.turnDarts,
            prevTurnSnapshot: gs.turnScoreSnapshot
        ))

        let newScore = player.score - value

        // Bust: score below 0 or equals 1
        if newScore < 0 || newScore == 1 {
            showToast("Přehoz! Skóre se vrací na \(gs.turnScoreSnapshot)")
            player.score = gs.turnScoreSnapshot
            let dartsAlreadyCounted = gs.currentDart
            player.darts += (3 - dartsAlreadyCounted)
            player.totalThrown -= gs.turnDarts.reduce(0) { $0 + $1.value }
            gs.players[playerIdx] = player

            gs.turnDarts = []
            gs.currentDart = 0
            gs.currentPlayer = gs.currentPlayer == 0 ? 1 : 0
            gs.turnScoreSnapshot = gs.players[gs.currentPlayer].score
            if gs.currentPlayer == 0 { gs.round += 1 }
            gameState = gs
            currentMultiplier = .single
            return
        }

        // Checkout
        if newScore == 0 {
            player.score = 0
            player.darts += 1
            player.totalThrown += value
            gs.players[playerIdx] = player
            gs.turnDarts.append(DartThrow(value: value, label: label))
            gs.currentDart += 1
            gs.isFinished = true
            gs.winnerName = player.name
            gameState = gs
            showWinner = true
            return
        }

        // Normal dart
        player.score = newScore
        player.darts += 1
        player.totalThrown += value
        gs.players[playerIdx] = player
        gs.turnDarts.append(DartThrow(value: value, label: label))
        gs.currentDart += 1

        // If 3 darts thrown, end turn
        if gs.currentDart >= 3 {
            gs.turnDarts = []
            gs.currentDart = 0
            gs.currentPlayer = gs.currentPlayer == 0 ? 1 : 0
            gs.turnScoreSnapshot = gs.players[gs.currentPlayer].score
            if gs.currentPlayer == 0 { gs.round += 1 }
        }

        gameState = gs
        currentMultiplier = .single
    }

    // MARK: - Computed Properties

    func playerAverage(playerState: GamePlayerState) -> String {
        guard playerState.darts > 0 else { return "0.00" }
        let avg = Double(playerState.totalThrown) / (Double(playerState.darts) / 3.0)
        return String(format: "%.2f", avg)
    }

    var turnTotal: Int {
        gameState?.turnDarts.reduce(0) { $0 + $1.value } ?? 0
    }

    var currentTurnLabel: String {
        guard let gs = gameState else { return "" }
        return "Na řadě: \(gs.players[gs.currentPlayer].name)"
    }

    var canUndo: Bool {
        !(gameState?.moveHistory.isEmpty ?? true)
    }

    // MARK: - Toast

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }
}
