import SwiftUI

public extension View {

    func vexillographerFooter<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        transformEnvironment(\.flagPoleContext) { [content = content()] in
            $0.footer = AnyView(content)
        }
    }

}
