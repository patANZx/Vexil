//import SwiftUI
//import Vexil
//import Vexillographer
//
//struct BasicExampleOld: View {
//
//    var body: some View {
//        NavigationView {
//            Vexillographer()
//        }
//        .flagPole(
//            FlagPole(hoist: BasicExampleOldFlags.self, sources: [.basicExampleOldSource]),
//            editableSource: .basicExampleOldSource
//        )
//    }
//
//}
//
//private extension FlagValueSource where Self == FlagValueSourceCoordinator<UserDefaults> {
//
//    static var basicExampleOldSource: Self { Self(source: UserDefaults(suiteName: "com.example.basic")!) }
//
//}
//
//@FlagContainer
//private struct BasicExampleOldFlags {
//
//    @Flag("Whether experimental features are enabled")
//    var experimentalFeatures = false
//
//    @FlagGroup(description: "Flags used for debugging.", display: .section)
//    var debug: DebugFlags
//
//    @FlagGroup("Flags related to demo mode.")
//    var demo: DemoFlags
//
//}
//
//@FlagContainer
//private struct DebugFlags {
//
//    @Flag("Duration in seconds to artificially delay requests")
//    var simulatedDelay: Double?
//
//    @Flag("The logging level to use.")
//    var logLevel = LogLevel.default
//
//    enum LogLevel: String, CaseIterable, FlagValue {
//
//        case trace
//        case debug
//        case `default`
//    }
//
//}
//
//@FlagContainer
//private struct DemoFlags {
//
//    @Flag(
//        name: "Enable Demo Mode",
//        description: "Whether demo mode is enabled"
//    )
//    var isEnabled = false
//
//    @Flag(
//        name: "Demo Sever URL",
//        description: "The URL of the mock server used in demo mode"
//    )
//    var serverURL = "http://localhost:8080"
//
//}
//
//#Preview {
//    BasicExampleOld()
//}
