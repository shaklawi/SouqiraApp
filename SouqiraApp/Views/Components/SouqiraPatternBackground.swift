import SwiftUI

struct SouqiraPatternBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.canvas,
                        DesignSystem.Colors.gray100,
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.08))
                    .frame(width: width * 0.9, height: width * 0.9)
                    .offset(x: -width * 0.5, y: -height * 0.1)

                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.1))
                    .frame(width: width * 0.7, height: width * 0.7)
                    .offset(x: width * 0.4, y: -height * 0.25)

                Circle()
                    .stroke(DesignSystem.Colors.primary.opacity(0.08), lineWidth: 1)
                    .frame(width: width * 0.6, height: width * 0.6)
                    .offset(x: width * 0.12, y: -height * 0.2)

                Path { path in
                    let y = height * 0.32
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: width, y: y + 8),
                        control1: CGPoint(x: width * 0.25, y: y - 24),
                        control2: CGPoint(x: width * 0.7, y: y + 30)
                    )
                }
                .stroke(DesignSystem.Colors.primary.opacity(0.12), lineWidth: 2)

                Path { path in
                    let y = height * 0.36
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: width, y: y + 6),
                        control1: CGPoint(x: width * 0.2, y: y + 18),
                        control2: CGPoint(x: width * 0.8, y: y - 16)
                    )
                }
                .stroke(DesignSystem.Colors.secondary.opacity(0.12), lineWidth: 1)
            }
        }
    }
}
