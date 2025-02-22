import MEGADomain
import MEGASdk

extension MEGASyncState {
    public func toSyncStateEntity() -> SyncStateEntity {
        switch self {
        case .notInitialized: return .notInitialized
        case .active: return .active
        case .failed: return .failed
        case .temporaryDisabled: return .temporaryDisabled
        case .disabled: return .disabled
        case .pauseUp: return .pauseUp
        case .pauseDown: return .pauseDown
        case .pauseFull: return .pauseFull
        case .deleted: return .deleted
        case .unknown: return .unknown
        @unknown default: return .unknown
        }
    }
}

extension SyncStateEntity {
    public func toMEGASyncState() -> MEGASyncState {
        switch self {
        case .notInitialized: return .notInitialized
        case .active: return .active
        case .failed: return .failed
        case .temporaryDisabled: return .temporaryDisabled
        case .disabled: return .disabled
        case .pauseUp: return .pauseUp
        case .pauseDown: return .pauseDown
        case .pauseFull: return .pauseFull
        case .deleted: return .deleted
        case .unknown: return .unknown
        }
    }
}
