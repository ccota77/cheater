import MEGADomain
import MEGAPermissions
import MEGASDKRepo

@objc final class SaveMediaToPhotosUseCaseOCWrapper: NSObject {
    @objc func saveToPhotos(node: MEGANode, isFolderLink: Bool = false) {
        let saveMediaUseCase = SaveMediaToPhotosUseCase(downloadFileRepository: DownloadFileRepository(sdk: MEGASdkManager.sharedMEGASdk(), sharedFolderSdk: isFolderLink ? MEGASdkManager.sharedMEGASdkFolder() : nil), fileCacheRepository: FileCacheRepository.newRepo, nodeRepository: NodeRepository.newRepo)
        let permissionHandler = DevicePermissionsHandler.makeHandler()
        
        permissionHandler.photosPermissionWithCompletionHandler { granted in
            if granted {
                TransfersWidgetViewController.sharedTransfer().bringProgressToFrontKeyWindowIfNeeded()
                Task { @MainActor in
                    do {
                        try await saveMediaUseCase.saveToPhotos(nodes: [node.toNodeEntity()])
                    } catch {
                        if let errorEntity = error as? SaveMediaToPhotosErrorEntity, errorEntity != .cancelled {
                            await SVProgressHUD.dismiss()
                            SVProgressHUD.show(
                                Asset.Images.NodeActions.saveToPhotos.image,
                                status: error.localizedDescription
                            )
                        }
                    }
                }
            } else {
                PermissionAlertRouter
                    .makeRouter(deviceHandler: permissionHandler)
                    .alertPhotosPermission()
            }
        }
    }
}
