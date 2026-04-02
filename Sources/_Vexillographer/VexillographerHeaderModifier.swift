import SwiftUI

public extension View {

    func vexillographerHeader<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        transformEnvironment(\.flagPoleContext) { [content = content()] in
            $0.header = AnyView(content)
        }
    }

}
