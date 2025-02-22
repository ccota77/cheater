import MEGADomain
import MEGAPermissions
import MEGAPresentation
import MEGASdk
import MEGASDKRepo
import SwiftUI
import UserNotifications

extension MEGALinkManager {
    @objc class func downloadFileLinkAfterLogin() {
        guard let linkUrl = URL(string: MEGALinkManager.linkSavedString) else { return }
        let transferViewEntity = CancellableTransfer(fileLinkURL: linkUrl, name: nil, appData: nil, priority: false, isFile: true, type: .downloadFileLink)
        CancellableTransferRouter(presenter: UIApplication.mnz_visibleViewController(), transfers: [transferViewEntity], transferType: .downloadFileLink).start()
    }
    
    @objc class func downloadFolderLinkAfterLogin() {
        guard let nodes = nodesFromLinkMutableArray as? [MEGANode] else {
            return
        }
        let transfers = nodes.map { CancellableTransfer(handle: $0.handle, name: nil, appData: nil, priority: false, isFile: $0.isFile(), type: .download) }
        CancellableTransferRouter(presenter: UIApplication.mnz_visibleViewController(), transfers: transfers, transferType: .download, isFolderLink: true).start()
    }
    
    @objc class func openBrowser(by urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    class func nodesFromLinkToDownloadAfterLogin(nodes: [NodeEntity]) {
        MEGALinkManager.nodesFromLinkMutableArray.addObjects(from: nodes.toMEGANodes(in: MEGASdkManager.sharedMEGASdkFolder()))
    }
    
    @objc class func showCollectionLinkView() {
        guard DIContainer.featureFlagProvider.isFeatureFlagEnabled(for: .albumShareLink) else { return }
        guard let publicLink = albumPublicLink() else {
            MEGALinkManager.showLinkNotValid()
            return
        }
        let userAlbumRepository = UserAlbumRepository.newRepo
        let shareAlbumRepository = ShareAlbumRepository(
            sdk: MEGASdk.shared,
            publicAlbumNodeProvider: PublicAlbumNodeProvider.shared)
        let importAlbumUseCase = ImportPublicAlbumUseCase(
            saveAlbumToFolderUseCase: SaveAlbumToFolderUseCase(
                nodeActionRepository: NodeActionRepository.newRepo,
             shareAlbumRepository: shareAlbumRepository),
            userAlbumRepository: userAlbumRepository)
        
        let vm = ImportAlbumViewModel(
            publicLink: publicLink,
            publicAlbumUseCase: PublicAlbumUseCase(
                shareAlbumRepository: shareAlbumRepository),
            albumNameUseCase: AlbumNameUseCase(
                userAlbumRepository: UserAlbumRepository.newRepo),
            accountStorageUseCase: AccountStorageUseCase(accountRepository: AccountRepository.newRepo),
            importPublicAlbumUseCase: importAlbumUseCase,
            accountUseCase: AccountUseCase(
                repository: AccountRepository.newRepo))
        
        let viewController = UIHostingController(rootView: ImportAlbumView(viewModel: vm))
        viewController.modalPresentationStyle = .fullScreen
        
        UIApplication.mnz_visibleViewController().present(viewController, animated: true)
    }
    
    class func albumPublicLink() -> URL? {
        guard let link = MEGALinkManager.linkURL else { return nil }
        guard link.scheme == "mega" else {
            return link
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mega.nz"
        var startingPath = ""
        if let host = link.host {
            startingPath = "/" + host
        }
        components.path = startingPath + link.path
        components.fragment = link.fragment
        return components.url
    }
    
    @objc
    class func continueWith(
        chatId: UInt64,
        chatTitle: String,
        chatLink: URL,
        shouldAskForNotificationsPermissions: Bool,
        permissionHandler: DevicePermissionsHandlerObjC
    ) {
        guard let identifier = MEGASdk.base64Handle(forHandle: chatId) else {
            // does it make sense to handle this error apart from early return?
            return
        }
        let notificationText = String(format: NSLocalizedString("You have joined %@", comment: "Text shown in a notification to let the user know that has joined a public chat room after login or account creation"), chatTitle)
        
        if shouldAskForNotificationsPermissions {
            SVProgressHUD.showSuccess(withStatus: notificationText)
            return
        }
        
        permissionHandler.notificationsPermission {granted in
            if !granted {
                SVProgressHUD.showSuccess(withStatus: notificationText)
            }
            
            MEGALinkManager.createChatAndShow(chatId, publicChatLink: chatLink)
            
            addNotficiation(
                notificationText: notificationText,
                chatId: chatId,
                identifier: identifier
            )
        }
    }
    
    static func addNotficiation(
        notificationText: String,
        chatId: UInt64,
        identifier: String
    ) {
        
        let content = UNMutableNotificationContent()
        content.body = notificationText
        content.sound = .default
        content.userInfo = ["chatId": chatId]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { _ in
            SVProgressHUD.showSuccess(withStatus: notificationText)
        }
    }
    
    @objc class func initFullScreenPlayer(node: MEGANode?, fileLink: String?, filePaths: [String]?, isFolderLink: Bool, presenter: UIViewController) {
        AudioPlayerManager.shared.initFullScreenPlayer(
            node: node,
            fileLink: fileLink,
            filePaths: filePaths,
            isFolderLink: isFolderLink,
            presenter: presenter,
            messageId: .invalid,
            chatId: .invalid
        )
    }
}
