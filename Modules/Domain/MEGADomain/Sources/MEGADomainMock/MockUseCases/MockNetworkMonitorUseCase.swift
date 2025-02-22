import MEGADomain

public struct MockNetworkMonitorUseCase: NetworkMonitorUseCaseProtocol {
    
    private let connected: Bool
    
    public init(connected: Bool = true) {
        self.connected = connected
    }
    
    public func networkPathChanged(completion: @escaping (Bool) -> Void) {
        completion(connected)
    }
    public func isConnected() -> Bool {
        connected
    }
}
