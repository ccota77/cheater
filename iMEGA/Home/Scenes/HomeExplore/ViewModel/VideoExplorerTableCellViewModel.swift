import Foundation
import MEGADomain
import MEGASDKRepo

final class VideoExplorerTableCellViewModel {
    private let node: MEGANode
    typealias MoreButtonTapHandler = (MEGANode, UIView) -> Void
    private let moreButtonTapHandler: MoreButtonTapHandler
    private lazy var thumbnailUseCase: any ThumbnailUseCaseProtocol = {
        return ThumbnailUseCase(repository: ThumbnailRepository.newRepo)
    }()
    
    var title: String {
        return node.name ?? ""
    }
    
    var duration: String? {
        return node.duration >= 0 ? TimeInterval(node.duration).timeString : nil
    }
    
    var parentFolderName: String {
        return node.parent.name ?? ""
    }
    
    var hasThumbnail: Bool {
        return node.hasThumbnail()
    }
    
    var nodeHandle: UInt64 {
        return node.handle
    }
    
    init(node: MEGANode, moreButtonTapHandler: @escaping MoreButtonTapHandler) {
        self.node = node
        self.moreButtonTapHandler = moreButtonTapHandler
    }
    
    func loadThumbnail(completionBlock: @escaping (UIImage?, UInt64) -> Void) {
        let nodeEntity = node.toNodeEntity()
        if let cachedThumbnail = thumbnailUseCase.cachedThumbnail(for: nodeEntity, type: .thumbnail) {
            let image = UIImage(contentsOfFile: cachedThumbnail.url.path)
            completionBlock(image, self.node.handle)
        } else {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let thumbnail = try await thumbnailUseCase.loadThumbnail(for: nodeEntity, type: .thumbnail)
                    let image = UIImage(contentsOfFile: thumbnail.url.path)
                    completionBlock(image, self.node.handle)
                } catch {
                    MEGALogError("Error loading video cover thumbnail: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func moreButtonTapped(cell: UIView) {
        moreButtonTapHandler(node, cell)
    }
    
    func createAttributedTitle() -> NSAttributedString? {
        let attributedTitle = NSMutableAttributedString(string: title)
        
        // Check if there is label for the video
        if node.label != .unknown,
           let labelName = MEGANode.string(for: node.label)?.appending("Small"),
           let labelImage = UIImage(named: labelName),
           let label = createImageAttachmentWithPadding(by: labelImage) {
            attributedTitle.append(label)
        }
        
        if node.isFavourite,
           let favouriteIcon = createImageAttachmentWithPadding(by: Asset.Images.Labels.favouriteSmall.image) {
            attributedTitle.append(favouriteIcon)
        }
        
        return attributedTitle.copy() as? NSAttributedString
    }
    
    // MARK: - Private
    
    private func createImageAttachmentWithPadding(by image: UIImage, leadingPadding: Double = 4) -> NSAttributedString? {
        let attchmentString = NSMutableAttributedString()
        if leadingPadding > 0 {
            let space = createSpace(leadingPadding)
            attchmentString.append(space)
        }
        let imageAttachment = createImageAttachment(by: image)
        attchmentString.append(imageAttachment)
        return attchmentString.copy() as? NSAttributedString
    }
    
    private func createSpace(_ width: Double = 4) -> NSAttributedString {
        let spaceAttachment = NSTextAttachment()
        spaceAttachment.bounds = CGRect(x: 0, y: 0, width: width, height: 0)
        let space = NSAttributedString(attachment: spaceAttachment)
        return space
    }
    
    private func createImageAttachment(by image: UIImage) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        let attchmentString = NSAttributedString(attachment: imageAttachment)
        return attchmentString
    }
}
