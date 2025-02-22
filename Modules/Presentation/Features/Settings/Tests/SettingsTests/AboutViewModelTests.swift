import MEGADomain
import MEGADomainMock
import XCTest

@testable import Settings

final class AboutViewModeTests: XCTestCase {
    private var preferenceUC: MockPreferenceUseCase!
    private var apiEnvironmentUC: MockAPIEnvironmentUseCase!
    private var manageLogsUC: MockManageLogsUseCase!
    private var changeSfuServerUC: MockChangeSfuServerUseCase!
    private var aboutModel: AboutSetting!
    private var aboutVM: AboutViewModel!
    private let toggleLogsEntity = LogTogglingAlert(enableTitle: "Enable title",
                                                    enableMessage: "Enable message",
                                                    disableTitle: "Disable title",
                                                    disableMessage: "Disable message",
                                                    mainActionTitle: "",
                                                    cancelActionTitle: "")
    
    private func configureViewModel(enableLogs: Bool) {
        preferenceUC = MockPreferenceUseCase(dict: [.logging: enableLogs])
        apiEnvironmentUC = MockAPIEnvironmentUseCase()
        manageLogsUC = MockManageLogsUseCase()
        changeSfuServerUC = MockChangeSfuServerUseCase()
        aboutModel = AboutSetting(appVersion: AppVersion(title: "", message: ""),
                                   sdkVersion: AppVersion(title: "", message: ""),
                                   chatSDKVersion: AppVersion(title: "", message: ""),
                                   viewSourceLink: SettingsLink(title: "", url: URL(fileURLWithPath: "")),
                                   acknowledgementsLink: SettingsLink(title: "", url: URL(fileURLWithPath: "")),
                                   apiEnvironment: APIEnvironmentChangingAlert(title: "",
                                                                message: "",
                                                                cancelActionTitle: "",
                                                                actions: []),
                                toggleLogs: LogTogglingAlert(enableTitle: "Enable title",
                                                            enableMessage: "Enable message",
                                                            disableTitle: "Disable title",
                                                            disableMessage: "Disable message",
                                                            mainActionTitle: "",
                                                             cancelActionTitle: ""),
                                  changeSfuServer: ChangeSfuServerAlert(title: "Change server title",
                                                                        message: "Change server message",
                                                                        placeholder: "Change server placeholder",
                                                                        cancelButton: "Change server cancel button",
                                                                        changeButton: "Change server change button"))
        
        aboutVM = AboutViewModel(preferenceUC: preferenceUC, apiEnvironmentUC: apiEnvironmentUC, manageLogsUC: manageLogsUC, changeSfuServerUC: changeSfuServerUC, aboutSetting: aboutModel)
    }
    
    func testShouldEnableLogs_toggleLogsAlertText() throws {
        configureViewModel(enableLogs: true)

        XCTAssertEqual("Disable title", aboutVM.titleForLogsAlert())
        XCTAssertEqual("Disable message", aboutVM.messageForLogsAlert())
    }
    
    func testShouldDisableLogs_toggleLogsAlertText() throws {
        configureViewModel(enableLogs: false)

        XCTAssertEqual("Enable title", aboutVM.titleForLogsAlert())
        XCTAssertEqual("Enable message", aboutVM.messageForLogsAlert())
    }
}
