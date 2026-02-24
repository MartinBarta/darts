import SwiftUI

/// Tournament bracket screen
struct BracketView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var bracketVM: BracketViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.accent)
                            .font(.title)
                        Text("Turnajový pavouk")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    Text("Vytvořte eliminační turnaj")
                        .font(.system(size: 14))
                        .foregroundColor(.textDim)
                }

                if bracketVM.bracketState == nil {
                    BracketSetupView(playerVM: playerVM, bracketVM: bracketVM)
                } else {
                    BracketDisplayView(bracketVM: bracketVM)
                }
            }
            .padding(16)
        }
        .background(Color.bgDark.ignoresSafeArea())
        .sheet(isPresented: $bracketVM.showScoreModal) {
            BracketScoreModalView(bracketVM: bracketVM)
        }
        .overlay(
            Group {
                if bracketVM.showTournamentWinner {
                    TournamentWinnerModal(
                        winnerName: bracketVM.tournamentWinnerName,
                        onClose: { bracketVM.showTournamentWinner = false }
                    )
                }
            }
        )
    }
}

// MARK: - Setup

struct BracketSetupView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var bracketVM: BracketViewModel

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.accent)
                    Text("Nastavení turnaje")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                // Mode toggle
                HStack(spacing: 8) {
                    ForEach(BracketMode.allCases, id: \.self) { mode in
                        Button(action: { bracketVM.bracketMode = mode }) {
                            HStack(spacing: 6) {
                                Image(systemName: mode == .random ? "shuffle" : "hand.tap.fill")
                                    .font(.system(size: 14))
                                Text(mode.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                bracketVM.bracketMode == mode
                                    ? Color.accent.opacity(0.1)
                                    : Color.bgDark
                            )
                            .foregroundColor(
                                bracketVM.bracketMode == mode ? .accentLight : .textDim
                            )
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        bracketVM.bracketMode == mode ? Color.accent : Color.border,
                                        lineWidth: bracketVM.bracketMode == mode ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if bracketVM.bracketMode == .random {
                    RandomBracketSetup(playerVM: playerVM, bracketVM: bracketVM)
                } else {
                    CustomBracketSetup(playerVM: playerVM, bracketVM: bracketVM)
                }

                PrimaryButton("Vytvořit pavouka", icon: "rectangle.connected.to.line.below") {
                    bracketVM.generateBracket(from: playerVM.selectedPlayers)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct RandomBracketSetup: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var bracketVM: BracketViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vyberte hráče pro turnaj (min. 2):")
                .font(.system(size: 14))
                .foregroundColor(.textDim)

            if playerVM.selectedPlayers.isEmpty {
                Text("Nejdříve přidejte hráče v sekci Hráči")
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                // Select all / Deselect all
                HStack(spacing: 12) {
                    Button("Vybrat vše") {
                        bracketVM.selectAllPlayers(count: playerVM.selectedPlayers.count)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.blueApp)

                    Button("Odebrat vše") {
                        bracketVM.deselectAllPlayers()
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.accent)
                }

                ForEach(Array(playerVM.selectedPlayers.enumerated()), id: \.element.id) { index, player in
                    Button(action: {
                        bracketVM.togglePlayerSelection(index)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: bracketVM.selectedPlayerIndices.contains(index) ? "checkmark.square.fill" : "square")
                                .foregroundColor(bracketVM.selectedPlayerIndices.contains(index) ? .accent : .textMuted)

                            PlayerAvatarView(name: player.name, imageURL: player.imageURL, size: 24)

                            Text(player.name)
                                .font(.system(size: 13))
                                .foregroundColor(.textPrimary)

                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.bgDark)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Shuffle toggle
            Toggle(isOn: $bracketVM.shuffleEnabled) {
                Text("Náhodné pořadí")
                    .font(.system(size: 14))
                    .foregroundColor(.textDim)
            }
            .tint(.accent)
        }
    }
}

struct CustomBracketSetup: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var bracketVM: BracketViewModel
    @State private var selectedP1: String = ""
    @State private var selectedP2: String = ""

    var availablePlayers: [Player] {
        let assigned = bracketVM.assignedPlayerNames()
        return playerVM.selectedPlayers.filter { !assigned.contains($0.name) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sestavte zápasy ručně:")
                .font(.system(size: 14))
                .foregroundColor(.textDim)

            // Add matchup
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accent)
                    Text("Přidat zápas")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textDim)
                }

                VStack(spacing: 8) {
                    Menu {
                        Button("-- Vyberte hráče --") { selectedP1 = "" }
                        ForEach(availablePlayers) { p in
                            Button("\(p.country) \(p.name)") { selectedP1 = p.name }
                        }
                    } label: {
                        HStack {
                            Text(selectedP1.isEmpty ? "-- Vyberte hráče --" : selectedP1)
                                .foregroundColor(selectedP1.isEmpty ? .textMuted : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textMuted)
                                .font(.system(size: 12))
                        }
                        .padding(10)
                        .background(Color.bgDark)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))
                    }

                    Text("vs")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textMuted)
                        .frame(maxWidth: .infinity)

                    Menu {
                        Button("-- Vyberte hráče --") { selectedP2 = "" }
                        ForEach(availablePlayers) { p in
                            Button("\(p.country) \(p.name)") { selectedP2 = p.name }
                        }
                    } label: {
                        HStack {
                            Text(selectedP2.isEmpty ? "-- Vyberte hráče --" : selectedP2)
                                .foregroundColor(selectedP2.isEmpty ? .textMuted : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textMuted)
                                .font(.system(size: 12))
                        }
                        .padding(10)
                        .background(Color.bgDark)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))
                    }

                    PrimaryButton("Přidat", icon: "plus") {
                        bracketVM.addCustomMatchup(player1Name: selectedP1, player2Name: selectedP2)
                        selectedP1 = ""
                        selectedP2 = ""
                    }
                }
            }

            // Matchups list
            if bracketVM.customMatchups.isEmpty {
                Text("Zatím nejsou přidány žádné zápasy")
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                ForEach(Array(bracketVM.customMatchups.enumerated()), id: \.element.id) { index, matchup in
                    HStack {
                        Text(matchup.player1Name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)

                        Text("vs")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.accent)
                            .tracking(1)

                        Text(matchup.player2Name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Button(action: { bracketVM.removeCustomMatchup(at: index) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.accent)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.bgDark)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))
                    )
                }
            }
        }
    }
}

// MARK: - Bracket Display

struct BracketDisplayView: View {
    @ObservedObject var bracketVM: BracketViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Controls
            HStack(spacing: 12) {
                OutlineButton("Nový turnaj", icon: "arrow.counterclockwise") {
                    bracketVM.resetBracket()
                }

                let stats = bracketVM.matchStats()
                Text("Odehráno: \(stats.completed) / \(stats.total) zápasů")
                    .font(.system(size: 14))
                    .foregroundColor(.textDim)
            }

            // Bracket tree (horizontally scrollable)
            if let bs = bracketVM.bracketState {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 24) {
                        ForEach(Array(bs.rounds.enumerated()), id: \.offset) { roundIdx, round in
                            VStack(spacing: 14) {
                                // Round title
                                Text(bracketVM.roundName(roundIdx: roundIdx, totalRounds: bs.totalRounds))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.textDim)
                                    .textCase(.uppercase)
                                    .tracking(1)
                                    .padding(.bottom, 8)

                                ForEach(round, id: \.id) { match in
                                    BracketMatchView(match: match, bracketVM: bracketVM)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

struct BracketMatchView: View {
    let match: BracketMatch
    @ObservedObject var bracketVM: BracketViewModel

    var isBye: Bool { match.p1 == nil || match.p2 == nil }
    var isComplete: Bool { match.winner != nil }

    var body: some View {
        VStack(spacing: 0) {
            // Player 1
            playerRow(name: match.p1, isWinner: match.winner == match.p1, isLoser: match.winner != nil && match.winner != match.p1 && match.p1 != nil, playerIdx: 0)

            // Score badge
            if let score = match.score, score != "BYE" {
                Text(score)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.goldApp)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                    .background(Color.goldApp.opacity(0.1))
                    .tracking(1)
            }

            Divider().background(Color.border)

            // Player 2
            playerRow(name: match.p2, isWinner: match.winner == match.p2, isLoser: match.winner != nil && match.winner != match.p2 && match.p2 != nil, playerIdx: 1)
        }
        .frame(minWidth: 170)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isComplete ? Color.greenApp :
                            isBye ? Color.border.opacity(0.5) :
                            Color.border,
                            lineWidth: 1
                        )
                )
        )
        .opacity(isBye && match.p1 == nil && match.p2 == nil ? 0.4 : (isComplete ? 0.85 : 1.0))
    }

    @ViewBuilder
    private func playerRow(name: String?, isWinner: Bool, isLoser: Bool, playerIdx: Int) -> some View {
        Button(action: {
            if name != nil {
                bracketVM.bracketClickPlayer(matchId: match.id, playerIdx: playerIdx)
            }
        }) {
            HStack(spacing: 8) {
                if isWinner {
                    Rectangle()
                        .fill(Color.greenApp)
                        .frame(width: 3)
                }

                Text(name ?? "Čeká...")
                    .font(.system(size: 13, weight: isWinner ? .semibold : .regular))
                    .foregroundColor(
                        isWinner ? .textPrimary :
                        isLoser ? .textMuted :
                        name != nil ? .textPrimary :
                        .textMuted
                    )
                    .strikethrough(isLoser)
                    .lineLimit(1)

                Spacer()

                if isWinner {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12))
                        .foregroundColor(.greenApp)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isWinner ? Color.greenApp.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
        .opacity(isLoser ? 0.45 : 1.0)
    }
}

// MARK: - Score Modal

struct BracketScoreModalView: View {
    @ObservedObject var bracketVM: BracketViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.accent)
                    Text("Zadejte skóre zápasu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                HStack(spacing: 16) {
                    // Winner
                    VStack(spacing: 8) {
                        Text("VÍTĚZ")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textMuted)
                            .tracking(1)
                        Text(bracketVM.pendingWinnerName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        TextField("Skóre", text: $bracketVM.winnerScoreText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .frame(width: 80)
                            .background(Color.bgDark)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))
                            .foregroundColor(.textPrimary)
                    }

                    Text(":")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.textMuted)
                        .padding(.top, 30)

                    // Loser
                    VStack(spacing: 8) {
                        Text("PORAŽENÝ")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textMuted)
                            .tracking(1)
                        Text(bracketVM.pendingLoserName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        TextField("Skóre", text: $bracketVM.loserScoreText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .frame(width: 80)
                            .background(Color.bgDark)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border, lineWidth: 1))
                            .foregroundColor(.textPrimary)
                    }
                }

                HStack(spacing: 12) {
                    PrimaryButton("Potvrdit", icon: "checkmark") {
                        bracketVM.confirmBracketScore()
                    }
                    OutlineButton("Přeskočit") {
                        bracketVM.skipBracketScore()
                    }
                    OutlineButton("Zrušit") {
                        bracketVM.closeBracketScoreModal()
                    }
                }

                Spacer()
            }
            .padding(24)
            .background(Color.bgCard.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Tournament Winner

struct TournamentWinnerModal: View {
    let winnerName: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.goldApp)
                    .shadow(color: Color.goldApp.opacity(0.5), radius: 20)

                Text("Vítěz turnaje!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text("🏆 \(winnerName)")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.goldApp)
                    .shadow(color: Color.goldApp.opacity(0.3), radius: 10)

                PrimaryButton("Zavřít") {
                    onClose()
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
