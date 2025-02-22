import Foundation

public enum SyncStateEntity: Sendable {
    case notInitialized
    case active
    case failed
    case temporaryDisabled
    case disabled
    case pauseUp
    case pauseDown
    case pauseFull
    case deleted
    case unknown
    
    public func isPaused() -> Bool {
        self == .pauseUp || self == .pauseDown || self == .pauseFull
    }
}
