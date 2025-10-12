import SwiftUI

public struct LogoView: View {
    public enum Size {
        case large
    }
    
    public enum Style {
        case full
    }
    
    private let size: Size
    private let style: Style
    
    public init(size: Size, style: Style) {
        self.size = size
        self.style = style
    }
    
    public var body: some View {
        Group {
            switch style {
            case .full:
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(.pink)
                    Text("Manounou")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Manounou logo")
    }
}

#Preview {
    LogoView(size: .large, style: .full)
}
