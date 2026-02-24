import SwiftUI

/// Dashboard / Overview screen
struct DashboardView: View {
    @ObservedObject var playerVM: PlayerViewModel
    let onNavigate: (Int) -> Void  // 0=dashboard, 1=players, 2=scoreboard, 3=bracket

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.accent)
                            .font(.title)
                        Text("Přehled")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    Text("Vítejte v aplikaci pro šipkové turnaje!")
                        .font(.system(size: 14))
                        .foregroundColor(.textDim)
                }
                .padding(.bottom, 8)

                // Dashboard Cards
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    DashCard(
                        icon: "person.2.fill",
                        iconColor: .blueApp,
                        iconBg: Color.blueApp.opacity(0.15),
                        title: "HRÁČI",
                        stat: "\(playerVM.selectedPlayers.count)",
                        label: "registrovaných hráčů"
                    ) {
                        onNavigate(1)
                    }

                    DashCard(
                        icon: "number",
                        iconColor: .greenApp,
                        iconBg: Color.greenApp.opacity(0.15),
                        title: "POČÍTADLO",
                        stat: nil,
                        statIcon: "play.fill",
                        label: "Spustit hru"
                    ) {
                        onNavigate(2)
                    }

                    DashCard(
                        icon: "trophy.fill",
                        iconColor: .goldApp,
                        iconBg: Color.goldApp.opacity(0.15),
                        title: "TURNAJ",
                        stat: nil,
                        statIcon: "rectangle.connected.to.line.below",
                        label: "Vytvořit pavouka"
                    ) {
                        onNavigate(3)
                    }
                }

                // Quick Guide
                CardView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blueApp)
                            Text("Rychlý průvodce")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }

                        VStack(spacing: 12) {
                            GuideItem(number: "1", text: "Přidejte hráče v sekci **Hráči**")
                            GuideItem(number: "2", text: "Spusťte hru přes **Počítadlo** (301 / 501)")
                            GuideItem(number: "3", text: "Nebo vytvořte **Turnajový pavouk**")
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.bgDark.ignoresSafeArea())
    }
}

// MARK: - Sub-views

struct DashCard: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    var stat: String? = nil
    var statIcon: String? = nil
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textDim)
                    .tracking(1)

                if let stat = stat {
                    Text(stat)
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.textPrimary)
                } else if let statIcon = statIcon {
                    Image(systemName: statIcon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.textPrimary)
                }

                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct GuideItem: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accent)
                    .frame(width: 30, height: 30)
                Text(number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(.init(text))
                .font(.system(size: 14))
                .foregroundColor(.textDim)
                .lineSpacing(4)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.bgDark)
        )
    }
}
