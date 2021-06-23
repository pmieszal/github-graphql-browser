import Foundation

public let UITestsFlag = "UITESTS"

public var isRunningUITests: Bool {
    ProcessInfo.processInfo.arguments.contains(UITestsFlag)
}
