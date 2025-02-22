import Foundation
import MEGADomain
import MEGAPresentation
import PhoneNumberKit

enum VerificationCodeAction: ActionType {
    case onViewReady
    case resendCode
    case checkVerificationCode(String)
    case didCheckCodeSucceeded
}

protocol VerificationCodeViewRouting: Routing {
    func goBack()
    func goToOnboarding()
    func phoneNumberVerified()
}

struct VerificationCodeViewModel: ViewModelType {
    enum Command: CommandType, Equatable {
        case startLoading
        case finishLoading
        case configView(phoneNumber: String, screenTitle: String)
        case checkCodeError(message: String)
        case checkCodeSucceeded
    }
    
    // MARK: - Private properties
    private let checkSMSUseCase: any CheckSMSUseCaseProtocol
    private let authUseCase: any AuthUseCaseProtocol
    private let verificationType: SMSVerificationType
    private let router: any VerificationCodeViewRouting
    private let regionCode: RegionCode
    private let phoneNumber: String
    private var screenTitle: String {
        switch verificationType {
        case .addPhoneNumber:
            return Strings.Localizable.addPhoneNumber
        case .unblockAccount:
            return Strings.Localizable.verifyYourAccount
        }
    }
    
    // MARK: - Internel properties
    var invokeCommand: ((Command) -> Void)?
    
    // MARK: - Init
    init(router: some VerificationCodeViewRouting,
         checkSMSUseCase: any CheckSMSUseCaseProtocol,
         authUseCase: any AuthUseCaseProtocol,
         verificationType: SMSVerificationType,
         phoneNumber: String,
         regionCode: RegionCode) {
        self.router = router
        self.checkSMSUseCase = checkSMSUseCase
        self.authUseCase = authUseCase
        self.verificationType = verificationType
        self.phoneNumber = phoneNumber
        self.regionCode = regionCode
    }
    
    // MARK: - Dispatch action
    func dispatch(_ action: VerificationCodeAction) {
        switch action {
        case .onViewReady:
            invokeCommand?(.configView(phoneNumber: formatNumber(phoneNumber, withRegionCode: regionCode),
                                       screenTitle: screenTitle))
        case .checkVerificationCode(let code):
            checkVerificationCode(code)
        case .resendCode:
            router.goBack()
        case .didCheckCodeSucceeded:
            didCheckCodeSucceeded()
        }
    }
    
    private func formatNumber(_ number: String, withRegionCode regionCode: RegionCode) -> String {
        do {
            let numberKit = PhoneNumberKit()
            return numberKit.format(try numberKit.parse(number, withRegion: regionCode), toType: .international)
        } catch {
            return number
        }
    }
    
    // MARK: - Check code
    private func checkVerificationCode(_ code: String) {
        invokeCommand?(.startLoading)
        checkSMSUseCase.checkVerificationCode(code) {
            self.invokeCommand?(.finishLoading)
            switch $0 {
            case .success:
                self.invokeCommand?(.checkCodeSucceeded)
            case .failure(let error):
                var message: String
                switch error {
                case .reachedDailyLimit:
                    message = Strings.Localizable.youHaveReachedTheDailyLimit
                case .codeDoesNotMatch:
                    message = Strings.Localizable.theVerificationCodeDoesnTMatch
                case .alreadyVerifiedWithAnotherAccount:
                    message = Strings.Localizable.yourAccountIsAlreadyVerified
                default:
                    message = Strings.Localizable.unknownError
                }
                self.invokeCommand?(.checkCodeError(message: message))
            }
        }
    }
    
    private func didCheckCodeSucceeded() {
        router.phoneNumberVerified()

        guard verificationType == .unblockAccount else { return }
        
        guard let sessionId = authUseCase.sessionId() else {
            router.goToOnboarding()
            return
        }
        
        Task {
            try await authUseCase.login(sessionId: sessionId)
        }
    }
}
