import SwiftUI

/// Players management screen: add custom, browse pro, manage selected
struct PlayersView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @State private var customName: String = ""
    @State private var showClearConfirm: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.accent)
                            .font(.title)
                        Text("Správa hráčů")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    Text("Vyberte profesionální hráče nebo přidejte vlastní")
                        .font(.system(size: 14))
                        .foregroundColor(.textDim)
                }
                .padding(.bottom, 4)

                // Add Custom Player
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.accent)
                            Text("Přidat vlastního hráče")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }

                        HStack(spacing: 12) {
                            TextField("Jméno hráče...", text: $customName)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(Color.bgDark)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                                .foregroundColor(.textPrimary)
                                .onSubmit {
                                    addCustom()
                                }

                            PrimaryButton("Přidat", icon: "plus") {
                                addCustom()
                            }
                        }
                    }
                }

                // Pro Players
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.accent)
                            Text("Profesionální hráči")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }

                        // Search
                        TextField("Hledat hráče...", text: $playerVM.searchText)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(Color.bgDark)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                            .foregroundColor(.textPrimary)

                        // Player grid
                        LazyVStack(spacing: 8) {
                            ForEach(playerVM.proPlayers, id: \.name) { pro in
                                ProPlayerRow(
                                    player: pro,
                                    isSelected: playerVM.isPlayerSelected(pro.name)
                                ) {
                                    playerVM.toggleProPlayer(pro)
                                }
                            }
                        }
                    }
                }

                // Selected Players
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accent)
                            Text("Vybraní hráči")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("(\(playerVM.selectedPlayers.count))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textDim)
                        }

                        if playerVM.selectedPlayers.isEmpty {
                            Text("Zatím nejsou vybráni žádní hráči")
                                .font(.system(size: 13))
                                .foregroundColor(.textMuted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(playerVM.selectedPlayers) { player in
                                SelectedPlayerRow(player: player) {
                                    playerVM.removePlayer(player)
                                }
                            }
                        }

                        if !playerVM.selectedPlayers.isEmpty {
                            Button(action: {
                                showClearConfirm = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                    Text("Odebrat všechny")
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 13))
                                .foregroundColor(.accent)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accent, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.bgDark.ignoresSafeArea())
        .alert("Odebrat všechny hráče?", isPresented: $showClearConfirm) {
            Button("Zrušit", role: .cancel) {}
            Button("Odebrat", role: .destructive) {
                playerVM.clearAll()
            }
        } message: {
            Text("Opravdu chcete odebrat všechny hráče?")
        }
    }

    private func addCustom() {
        playerVM.addCustomPlayer(name: customName)
        customName = ""
    }
}

// MARK: - Sub-views

struct ProPlayerRow: View {
    let player: Player
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                PlayerAvatarView(
                    name: player.name,
                    imageURL: player.imageURL,
                    size: 44
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    Text(player.country)
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.greenApp)
                }
            }
            .padding(8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bgDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.greenApp : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectedPlayerRow: View {
    let player: Player
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            PlayerAvatarView(
                name: player.name,
                imageURL: player.imageURL,
                size: 34
            )

            Text(player.name)
                .font(.system(size: 14))
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            if player.isCustom {
                Text("(vlastní)")
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.accent)
                    .padding(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.bgDark)
        )
    }
}
