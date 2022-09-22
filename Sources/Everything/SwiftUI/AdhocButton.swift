import SwiftUI

public extension Button {
    func adhocButtonStyle<StyledButton>(@ViewBuilder _ styler: @escaping (ButtonStyleConfiguration) -> StyledButton) -> some View where StyledButton: View {
        buttonStyle(AdhocButtonStyle { configuration -> StyledButton in
            styler(configuration)
        })
    }
}

public struct AdhocButtonStyle<Style>: ButtonStyle where Style: View {
    let styler: (ButtonStyleConfiguration) -> Style

    public init(styler: @escaping (ButtonStyleConfiguration) -> Style) {
        self.styler = styler
    }

    public func makeBody(configuration: Configuration) -> some View {
        styler(configuration)
    }
}
