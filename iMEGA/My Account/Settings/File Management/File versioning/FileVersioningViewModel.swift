import MEGADomain
import MEGAPresentation

enum FileVersioningViewAction: ActionType {
    case onViewLoaded
    case enableFileVersions
    case disableFileVersions
    case deletePreviousVersions
}

protocol FileVersioningViewRouting: Routing {
    func showDisableAlert(completion: @escaping (Bool) -> Void)
    func showDeletePreviousVersionsAlert(completion: @escaping (Bool) -> Void)
}

final class FileVersioningViewModel: ViewModelType {
    
    private let fileVersionsUseCase: any FileVersionsUseCaseProtocol
    private let accountUseCase: any AccountUseCaseProtocol
    
    enum Command: CommandType, Equatable {
        case updateSwitch(Bool)
        case updateFileVersions(Int64)
        case updateFileVersionsSize(Int64)
    } 
    // MARK: - Private properties
    private let router: any FileVersioningViewRouting
    
    var invokeCommand: ((Command) -> Void)?
    
    // MARK: - Init
    init(router: some FileVersioningViewRouting,
         fileVersionsUseCase: any FileVersionsUseCaseProtocol,
         accountUseCase: any AccountUseCaseProtocol) {
        self.router = router
        self.fileVersionsUseCase = fileVersionsUseCase
        self.accountUseCase = accountUseCase
    }
    
    func dispatch(_ action: FileVersioningViewAction) {
        switch action {
        case .onViewLoaded:
            viewLoaded()
            
        case .enableFileVersions:
            enableFileVersions(true)
            
        case .disableFileVersions:
            disableFileVersions()
                        
        case .deletePreviousVersions:
            deletePreviousVersions()
        }
    }
    
    // MARK: - Private
    
    private func viewLoaded() {
        fileVersionsUseCase.isFileVersionsEnabled { [weak self] in
            switch $0 {
            case .success(let value):
                self?.invokeCommand?(.updateSwitch(value))
            case .failure(let error):
                if error == .optionNeverSet {
                    self?.invokeCommand?(.updateSwitch(true))
                }
            }
        }
#if MAIN_APP_TARGET
        self.invokeCommand?(.updateFileVersions(fileVersionsUseCase.rootNodeFileVersionCount()))
        self.invokeCommand?(.updateFileVersionsSize(fileVersionsUseCase.rootNodeFileVersionTotalSizeInBytes()))
#endif
    }
    
    private func disableFileVersions() {
        router.showDisableAlert { [weak self] disable in
            if disable {
                self?.enableFileVersions(false)
            } else {
                self?.invokeCommand?(.updateSwitch(true))
            }
        }
    }
    
    private func enableFileVersions(_ enable: Bool) {
        fileVersionsUseCase.enableFileVersions(enable) { [weak self] in
            switch $0 {
            case .success(let enabled):
                self?.invokeCommand?(.updateSwitch(enabled))
            case .failure: break
            }
        }
    }
    
    private func deletePreviousVersions() {
        router.showDeletePreviousVersionsAlert { [weak self] delete in
            guard delete else { return }
            self?.fileVersionsUseCase.deletePreviousFileVersions { [weak self] in
                switch $0 {
                case .success:
                    self?.updateFileVersion()
                case .failure: break
                }
            }
        }
    }
    
    private func updateFileVersion() {
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.accountUseCase.refreshCurrentAccountDetails()
    #if MAIN_APP_TARGET
                self.invokeCommand?(.updateFileVersions(self.fileVersionsUseCase.rootNodeFileVersionCount()))
    #endif
                self.invokeCommand?(.updateFileVersionsSize(self.fileVersionsUseCase.rootNodeFileVersionTotalSizeInBytes()))
            } catch {
                MEGALogError("[File versioning] Error loading account details. Error: \(error)")
            }
        }
    }
}
