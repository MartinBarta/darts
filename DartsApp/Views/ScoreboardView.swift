import SwiftUI

/// Scoreboard screen for 301/501 dart games
struct ScoreboardView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image(systemName: "number")
                            .foregroundColor(.accent)
                            .font(.title)
                        Text("Počítadlo skóre")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    Text("Klasická hra 301 / 501")
                        .font(.system(size: 14))
                        .foregroundColor(.textDim)
                }

                if gameVM.gameState == nil {
                    GameSetupView(playerVM: playerVM, gameVM: gameVM)
                } else {
                    GameBoardView(playerVM: playerVM, gameVM: gameVM)
                }
            }
            .padding(16)
        }
        .background(Color.bgDark.ignoresSafeArea())
        .overlay(
            // Winner Modal
            Group {
                if gameVM.showWinner, let gs = gameVM.gameState, let winnerName = gs.winnerName {
                    WinnerModalView(
                        winnerName: winnerName,
                        stats: winnerStats(gs),
                        onNewGame: { gameVM.resetGame() },
                        onClose: { gameVM.showWinner = false }
                    )
                }
            }
        )
    }

    private func winnerStats(_ gs: GameState) -> String {
        guard let winner = gs.players.first(where: { $0.name == gs.winnerName }) else { return "" }
        let avg = gameVM.playerAverage(playerState: winner)
        return "Průměr za kolo: \(avg) | Celkem hodů: \(winner.darts)"
    }
}

// MARK: - Game Setup

struct GameSetupView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.accent)
                    Text("Nastavení hry")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                // Game type toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Typ hry")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textDim)

                    HStack(spacing: 8) {
                        ForEach(GameType.allCases, id: \.rawValue) { type in
                            Button(action: { gameVM.gameType = type }) {
                                Text("\(type.rawValue)")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(gameVM.gameType == type ? Color.accent : Color.bgDark)
                                    .foregroundColor(gameVM.gameType == type ? .white : .textDim)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(gameVM.gameType == type ? Color.accent : Color.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Player selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hráč 1")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textDim)
                    PlayerPicker(
                        selection: $gameVM.selectedPlayer1Name,
                        players: playerVM.selectedPlayers
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hráč 2")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textDim)
                    PlayerPicker(
                        selection: $gameVM.selectedPlayer2Name,
                        players: playerVM.selectedPlayers
                    )
                }

                // Start button
                PrimaryButton("Začít hru", icon: "play.fill") {
                    gameVM.startGame(players: playerVM.selectedPlayers)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct PlayerPicker: View {
    @Binding var selection: String
    let players: [Player]

    var body: some View {
        Menu {
            Button("-- Vyberte hráče --") { selection = "" }
            ForEach(players) { player in
                Button("\(player.country) \(player.name)") {
                    selection = player.name
                }
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? "-- Vyberte hráče --" : pickerLabel)
                    .foregroundColor(selection.isEmpty ? .textMuted : .textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.textMuted)
                    .font(.system(size: 12))
            }
            .padding(10)
            .background(Color.bgDark)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
    }

    private var pickerLabel: String {
        if let p = players.first(where: { $0.name == selection }) {
            return "\(p.country) \(p.name)"
        }
        return selection
    }
}

// MARK: - Game Board

struct GameBoardView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Game info bar
            HStack(spacing: 12) {
                Text("\(gameVM.gameState?.type.rawValue ?? 0)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(Color.accent)
                    .cornerRadius(20)

                Text("Kolo: ")
                    .font(.system(size: 14))
                    .foregroundColor(.textDim) +
                Text("\(gameVM.gameState?.round ?? 1)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)

                Spacer()

                OutlineButton("Nová hra", icon: "arrow.counterclockwise") {
                    gameVM.resetGame()
                }
            }

            // Player panels
            if let gs = gameVM.gameState {
                HStack(spacing: 12) {
                    PlayerPanelView(
                        playerState: gs.players[0],
                        playerData: playerVM.selectedPlayers.first(where: { $0.name == gs.players[0].name }),
                        isActive: gs.currentPlayer == 0,
                        average: gameVM.playerAverage(playerState: gs.players[0])
                    )

                    Text("VS")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.textMuted)

                    PlayerPanelView(
                        playerState: gs.players[1],
                        playerData: playerVM.selectedPlayers.first(where: { $0.name == gs.players[1].name }),
                        isActive: gs.currentPlayer == 1,
                        average: gameVM.playerAverage(playerState: gs.players[1])
                    )
                }

                // Scoring area
                ScoreInputArea(gameVM: gameVM)
            }
        }
    }
}

struct PlayerPanelView: View {
    let playerState: GamePlayerState
    let playerData: Player?
    let isActive: Bool
    let average: String

    var body: some View {
        VStack(spacing: 8) {
            PlayerAvatarView(
                name: playerState.name,
                imageURL: playerData?.imageURL,
                size: 50
            )

            Text(playerState.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isActive ? .accentLight : .textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(playerState.score)")
                .font(.system(size: 48, weight: .heavy))
                .foregroundColor(isActive ? .accent : .textPrimary)
                .minimumScaleFactor(0.5)

            Text("\(playerState.darts) hodů")
                .font(.system(size: 12))
                .foregroundColor(.textMuted)

            HStack(spacing: 4) {
                Text("Průměr:")
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
                Text(average)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.accent : Color.border, lineWidth: isActive ? 2 : 1)
                )
                .shadow(color: isActive ? Color.accent.opacity(0.2) : .clear, radius: 12)
        )
    }
}

struct ScoreInputArea: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        CardView {
            VStack(spacing: 16) {
                // Current turn label
                Text(gameVM.currentTurnLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textDim)

                // Dart indicators
                DartIndicatorsView(gameVM: gameVM)

                // Multiplier tabs
                MultiplierTabsView(gameVM: gameVM)

                // Number grid
                DartNumberGrid(gameVM: gameVM)

                // Bottom bar (undo + miss)
                HStack {
                    Button(action: { gameVM.undoDart() }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 18))
                            .foregroundColor(gameVM.canUndo ? .textDim : .textMuted.opacity(0.3))
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                    }
                    .disabled(!gameVM.canUndo)

                    Spacer()

                    Button(action: { gameVM.dartMiss() }) {
                        Text("VEDLE")
                            .font(.system(size: 18, weight: .heavy))
                            .tracking(2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.bgDark)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.border, lineWidth: 2)
                            )
                    }
                }
            }
        }
    }
}

struct DartIndicatorsView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                let isActive = gameVM.gameState?.currentDart == i
                let isThrown = (gameVM.gameState?.currentDart ?? 0) > i
                let dartLabel = dartValueLabel(at: i)

                VStack(spacing: 4) {
                    Text("\(i + 1)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.textMuted)
                        .textCase(.uppercase)
                    Text(dartLabel)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(
                            isActive ? .accentLight :
                            isThrown ? .greenApp :
                            .textPrimary
                        )
                }
                .frame(minWidth: 56)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.bgDark)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isActive ? Color.accent :
                            isThrown ? Color.greenApp :
                            Color.border,
                            lineWidth: isActive ? 2 : 1
                        )
                )
                .opacity(isActive || isThrown ? 1.0 : 0.5)
                .shadow(color: isActive ? Color.accent.opacity(0.3) : .clear, radius: 8)
            }

            // Turn total
            VStack(spacing: 2) {
                Text("Součet")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.goldApp)
                    .textCase(.uppercase)
                    .tracking(1)
                Text("\(gameVM.turnTotal)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.goldApp)
            }
            .frame(minWidth: 60)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color.goldApp.opacity(0.08))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.goldApp, lineWidth: 2)
            )
        }
    }

    private func dartValueLabel(at index: Int) -> String {
        guard let gs = gameVM.gameState else { return "—" }
        if index < gs.turnDarts.count {
            return gs.turnDarts[index].label
        }
        return "—"
    }
}

struct MultiplierTabsView: View {
    @ObservedObject var gameVM: GameViewModel

    let tabs: [(label: String, sub: String?, multiplier: DartMultiplier?, action: (() -> Void)?)] = [
        ("Single", nil, .single, nil),
        ("Double", nil, .double_, nil),
        ("Treble", nil, .treble, nil),
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Single/Double/Treble
            ForEach(DartMultiplier.allCases, id: \.self) { mult in
                Button(action: { gameVM.currentMultiplier = mult }) {
                    Text(mult.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(
                            gameVM.currentMultiplier == mult ? .accentLight : .textDim
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            gameVM.currentMultiplier == mult
                                ? Color.accent.opacity(0.12)
                                : Color.bgDark
                        )
                }
                .buttonStyle(.plain)
            }

            // Bull 50
            Button(action: { gameVM.dartBull() }) {
                VStack(spacing: 2) {
                    Text("Bull")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textDim)
                    Text("50")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.bgDark)
            }
            .buttonStyle(.plain)

            // Outer 25
            Button(action: { gameVM.dartOuter() }) {
                VStack(spacing: 2) {
                    Text("Outer")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.textDim)
                    Text("25")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.bgDark)
            }
            .buttonStyle(.plain)
        }
        .background(Color.bgDark)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct DartNumberGrid: View {
    @ObservedObject var gameVM: GameViewModel

    let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(1...20, id: \.self) { num in
                Button(action: { gameVM.dartNumber(num) }) {
                    Text("\(num)")
                        .font(.system(size: 20, weight: .heavy, design: .default))
                        .italic()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.bgDark)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Winner Modal

struct WinnerModalView: View {
    let winnerName: String
    let stats: String
    let onNewGame: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.goldApp)
                    .shadow(color: Color.goldApp.opacity(0.5), radius: 20)

                Text("🏆 \(winnerName) vyhrává!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(stats)
                    .font(.system(size: 14))
                    .foregroundColor(.textDim)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    PrimaryButton("Nová hra", icon: "arrow.counterclockwise") {
                        onNewGame()
                    }
                    OutlineButton("Zavřít") {
                        onClose()
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 20)
            )
            .padding(20)
        }
    }
}
