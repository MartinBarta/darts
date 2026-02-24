import SwiftUI

/// Displays a player avatar (async image or initials fallback)
struct PlayerAvatarView: View {
    let name: String
    let imageURL: String?
    let size: CGFloat

    init(name: String, imageURL: String?, size: CGFloat = 42) {
        self.name = name
        self.imageURL = imageURL
        self.size = size
    }

    var body: some View {
        Group {
            if let urlStr = imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipped()
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .background(Circle().fill(Color.bgDark))
    }

    private var initialsView: some View {
        ZStack {
            LinearGradient(
                colors: [.accent, Color(red: 192/255, green: 57/255, blue: 43/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(PlayerViewModel.playerInitials(name))
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

/// Toast notification overlay
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accent, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

/// Card-style container used throughout the app
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.border, lineWidth: 1)
                    )
            )
    }
}

/// Primary red button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.accent.opacity(0.3), radius: 8)
        }
    }
}

/// Outline button
struct OutlineButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.clear)
            .foregroundColor(.textPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.border, lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}
