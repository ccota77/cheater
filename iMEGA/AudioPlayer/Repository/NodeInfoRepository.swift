import Foundation
import MEGADomain

protocol NodeInfoRepositoryProtocol {
    func path(fromHandle: HandleEntity) -> URL?
    func info(fromNodes: [MEGANode]?) -> [AudioPlayerItem]?
    func authInfo(fromNodes: [MEGANode]?) -> [AudioPlayerItem]?
    func childrenInfo(fromParentHandle: HandleEntity) -> [AudioPlayerItem]?
    func folderChildrenInfo(fromParentHandle: HandleEntity) -> [AudioPlayerItem]?
    func node(fromHandle: HandleEntity) -> MEGANode?
    func folderNode(fromHandle: HandleEntity) -> MEGANode?
    func folderAuthNode(fromNode: MEGANode) -> MEGANode?
    func publicNode(fromFileLink: String, completion: @escaping ((MEGANode?) -> Void))
    func loginToFolder(link: String)
    func folderLinkLogout()
}

final class NodeInfoRepository: NodeInfoRepositoryProtocol {
    private let sdk: MEGASdk
    private let folderSDK: MEGASdk
    private let megaStore: MEGAStore
    private var streamingInfoRepository = StreamingInfoRepository()
    private var offlineFileInfoRepository = OfflineInfoRepository()
   
    @PreferenceWrapper(key: .sortingPreference, defaultValue: .perFolder, useCase: PreferenceUseCase.default)
    private var sortingPreference: SortingPreference
    
    @PreferenceWrapper(key: .sortingPreferenceType, defaultValue: .defaultAsc, useCase: PreferenceUseCase.default)
    private var sortingType: MEGASortOrderType
    
    init(sdk: MEGASdk = MEGASdkManager.sharedMEGASdk(), folderSDK: MEGASdk = MEGASdkManager.sharedMEGASdkFolder(), megaStore: MEGAStore = MEGAStore.shareInstance()) {
        self.sdk = sdk
        self.folderSDK = folderSDK
        self.megaStore = megaStore
    }
    
    // MARK: - Private functions
    private func playableChildren(of parent: HandleEntity) -> [MEGANode]? {
        guard let parentNode = sdk.node(forHandle: parent) else { return nil }
        
        return sdk.children(forParent: parentNode, order: sortType(for: parent)).toNodeArray()
            .filter { $0.name?.fileExtensionGroup.isMultiMedia == true &&
                $0.name?.fileExtensionGroup.isVideo == false &&
                $0.mnz_isPlayable() }
    }
    
    private func folderPlayableChildren(of parent: HandleEntity) -> [MEGANode]? {
        guard let parentNode = folderNode(fromHandle: parent) else { return nil }
        
        return folderSDK.children(forParent: parentNode, order: sortType(for: parent)).toNodeArray()
            .filter { $0.name?.fileExtensionGroup.isMultiMedia == true &&
                $0.name?.fileExtensionGroup.isVideo == false &&
                $0.mnz_isPlayable() }
    }
    
    private func sortType(for parent: HandleEntity) -> Int {
        guard let context = megaStore.stack.newBackgroundContext() else { return MEGASortOrderType.defaultAsc.rawValue }
        
        var sortType: Int = MEGASortOrderType.defaultAsc.rawValue
        
        context.performAndWait {
            sortType = sortingPreference == .perFolder ?
            megaStore.fetchCloudAppearancePreference(handle: parent, context: context)?.sortType?.intValue ?? MEGASortOrderType.defaultAsc.rawValue :
                                                    sortingType.rawValue
        }
        
        return sortType
    }
    
    // MARK: - Public functions
    func node(fromHandle: HandleEntity) -> MEGANode? { sdk.node(forHandle: fromHandle) }
    func folderNode(fromHandle: HandleEntity) -> MEGANode? { folderSDK.node(forHandle: fromHandle) }
    func folderAuthNode(fromNode: MEGANode) -> MEGANode? { folderSDK.authorizeNode(fromNode) }
    
    func path(fromHandle: HandleEntity) -> URL? {
        guard let node = node(fromHandle: fromHandle) else { return nil }
        
        return offlineFileInfoRepository.localPath(fromNode: node) ?? streamingInfoRepository.path(fromNode: node)
    }
    
    func info(fromNodes: [MEGANode]?) -> [AudioPlayerItem]? {
        return fromNodes?.compactMap {
            guard let url = path(fromHandle: $0.handle),
                  let name = $0.name else { return nil }
            return AudioPlayerItem(name: name, url: url, node: $0, hasThumbnail: $0.hasThumbnail())
        }
    }
    
    func authInfo(fromNodes: [MEGANode]?) -> [AudioPlayerItem]? {
        return fromNodes?.compactMap {
            guard let node = folderAuthNode(fromNode: $0),
                  let name = node.name,
                  let url = streamingInfoRepository.path(fromNode: node) else { return nil }
            return AudioPlayerItem(name: name, url: url, node: node, hasThumbnail: $0.hasThumbnail())
        }
    }
    
    func childrenInfo(fromParentHandle: HandleEntity) -> [AudioPlayerItem]? {
        playableChildren(of: fromParentHandle).flatMap(info)
    }
    
    func folderChildrenInfo(fromParentHandle parent: HandleEntity) -> [AudioPlayerItem]? {
        folderPlayableChildren(of: parent).flatMap(authInfo)
    }
    
    func publicNode(fromFileLink: String, completion: @escaping ((MEGANode?) -> Void)) {
        sdk.publicNode(forMegaFileLink: fromFileLink, delegate: MEGAGetPublicNodeRequestDelegate(completion: { (request, error) in
            guard let error = error, error.type == .apiOk  else {
                completion(nil)
                return
            }
            completion(request?.publicNode)
        }))
    }
    
    func loginToFolder(link: String) {
        if folderSDK.isLoggedIn() == 0 {
            folderSDK.login(toFolderLink: link)
        }
    }
     
    func folderLinkLogout() {
        folderSDK.logout()
    }
}
