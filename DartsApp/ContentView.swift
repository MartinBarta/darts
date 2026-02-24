import SwiftUI

/// Main tab-based navigation
struct ContentView: View {
    @StateObject private var playerVM = PlayerViewModel()
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var bracketVM = BracketViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(playerVM: playerVM) { tab in
                    selectedTab = tab
                }
                .tag(0)

                PlayersView(playerVM: playerVM)
                    .tag(1)

                ScoreboardView(playerVM: playerVM, gameVM: gameVM)
                    .tag(2)

                BracketView(playerVM: playerVM, bracketVM: bracketVM)
                    .tag(3)
            }
            .tabViewStyle(.automatic)

            // Custom tab bar matching the dark theme
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .bottom) {
            // Toast messages
            Group {
                if let msg = playerVM.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 100)
                }
                if let msg = gameVM.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 100)
                }
                if let msg = bracketVM.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, 100)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: playerVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: gameVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: bracketVM.toastMessage)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Přehled"),
        ("person.2.fill", "Hráči"),
        ("number", "Skóre"),
        ("trophy.fill", "Pavouk"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.label)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == index ? .accentLight : .textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, safeAreaBottom > 0 ? 0 : 6)
        .background(
            Color.bgSidebar
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.border),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

#Preview {
    ContentView()
}
