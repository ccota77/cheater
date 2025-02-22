import MEGADomain
import SwiftUI

final class PhotoLibraryModeAllCollectionViewModel: PhotoLibraryModeAllViewModel {
    let contentMode: PhotoLibraryContentMode
    
    override init(libraryViewModel: PhotoLibraryContentViewModel) {
        self.contentMode = libraryViewModel.contentMode
        super.init(libraryViewModel: libraryViewModel)
        zoomState = PhotoLibraryZoomState(
            scaleFactor: libraryViewModel.configuration?.scaleFactor ?? zoomState.scaleFactor,
            maximumScaleFactor: .thirteen
        )
        
        subscribeToLibraryChange()
        subscribeToZoomStateChange()
    }
    
    // MARK: Private
    private func subscribeToLibraryChange() {
        libraryViewModel
            .$library
            .dropFirst()
            .map { [weak self] in
                $0.photoDateSections(for: self?.zoomState.scaleFactor ?? PhotoLibraryZoomState.defaultScaleFactor)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$photoCategoryList)
    }
    
    private func subscribeToZoomStateChange() {
        $zoomState
            .dropFirst()
            .sink { [weak self] in
                guard let self else { return }
                
                if $0.isSingleColumn || self.zoomState.isSingleColumn == true {
                    self.photoCategoryList = self.libraryViewModel.library.photoDateSections(for: $0.scaleFactor)
                }
            }
            .store(in: &subscriptions)
    }
}
