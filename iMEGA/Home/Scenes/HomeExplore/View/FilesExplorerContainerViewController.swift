import MEGADomain
import MEGAPermissions
import MEGASDKRepo
import MEGAUIKit

class FilesExplorerContainerViewController: UIViewController, TextFileEditable {
    // MARK: - Private variables
    
    enum ViewPreference {
        case list
        case grid
        case both
    }

    private let viewModel: FilesExplorerViewModel
    private var uploadViewModel: HomeUploadingViewModel?
    private let viewPreference: ViewPreference
    
    private var contextBarButtonItem = UIBarButtonItem()
    private var uploadAddBarButonItem = UIBarButtonItem()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = false
        return sc
    }()
    
    // MARK: - States

    lazy var currentState = states[FilesExplorerContainerListViewState.identifier]!
    lazy var states = [
        FilesExplorerContainerListViewState.identifier:
            FilesExplorerContainerListViewState(containerViewController: self,
                                                viewModel: viewModel),
        FilesExplorerContainerGridViewState.identifier:
            FilesExplorerContainerGridViewState(containerViewController: self,
                                                viewModel: viewModel)
    ]
    
    // MARK: -
    
    init(viewModel: FilesExplorerViewModel, viewPreference: ViewPreference) {
        self.viewModel = viewModel
        self.viewPreference = viewPreference
        super.init(nibName: nil, bundle: nil)
        if self.viewModel.getExplorerType() == .document, UserDefaults.standard.integer(forKey: MEGAExplorerViewModePreference) == ViewModePreference.thumbnail.rawValue, viewPreference != .list {
            currentState = states[FilesExplorerContainerGridViewState.identifier]!
        } else {
            currentState = states[FilesExplorerContainerListViewState.identifier]!
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentState.showContent()
        configureNavigationBarButtons()
        configureSearchBar()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AudioPlayerManager.shared.addDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioPlayerManager.shared.removeDelegate(self)
    }
    
    // MARK: - Bar Buttons    
    func updateTitle(_ title: String?) {
        self.title = title
    }
    
    func showCancelRightBarButton() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(
            title: Strings.Localizable.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelButtonPressed(_:)))]
    }
    
    func showSelectAllBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Images.NavigationBar.selectAll.image,
            style: .plain,
            target: self,
            action: #selector(selectAllButtonPressed(_:))
        )
    }
    
    func hideKeyboardIfRequired() {
        if searchController.isActive {
            searchController.searchBar.resignFirstResponder()
        }
    }
    
    func updateSearchResults() {
        updateSearchResults(for: searchController)
    }
    
    func configureNavigationBarToDefault() {
        configureNavigationBarButtons()
        navigationItem.leftBarButtonItem = nil
        updateTitle(currentState.title)
        navigationItem.backBarButtonItem = BackBarButtonItem(menuTitle: currentState.title ?? "")
    }
    
    func setViewModePreference(_ preference: ViewModePreference) {
        assert(preference != .perFolder, "Preference cannot be per folder")
        UserDefaults.standard.setValue(preference.rawValue, forKey: MEGAExplorerViewModePreference)
        viewModel.dispatch(.didChangeViewMode(preference.rawValue))
    }
    
    func showMoreButton(_ show: Bool) {
        contextBarButtonItem.isEnabled = show
        if viewModel.getExplorerType() == .document {
            uploadAddBarButonItem.isEnabled = show
        }
    }
    
    func showSelectButton(_ show: Bool) {
        if show {
            showSelectAllBarButton()
            showCancelRightBarButton()
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func configureNavigationBarButtons() {
        contextBarButtonItem.image = Asset.Images.Generic.moreList.image
        
        if viewModel.getExplorerType() == .document {
            uploadAddBarButonItem.image = Asset.Images.NavigationBar.add.image

            navigationItem.rightBarButtonItems = [contextBarButtonItem, uploadAddBarButonItem]
        } else {
            navigationItem.rightBarButtonItem = contextBarButtonItem
        }
    }
    
    func audioPlayer(hidden: Bool) {
        if AudioPlayerManager.shared.isPlayerAlive() {
            AudioPlayerManager.shared.playerHidden(hidden, presenter: self)
        }
    }
    
    func updateContextMenu(menu: UIMenu) {
        contextBarButtonItem.menu = menu
    }
    
    func updateUploadAddMenu(menu: UIMenu) {
        uploadAddBarButonItem.menu = menu
    }
    
    func updateCurrentState() {
        currentState.toggleState()
    }
    
    func didSelect(action: UploadAddActionEntity) {
        if uploadViewModel == nil {
            let uploadViewModel = HomeUploadingViewModel(
                uploadFilesUseCase: UploadPhotoAssetsUseCase(
                    uploadPhotoAssetsRepository: UploadPhotoAssetsRepository(store: MEGAStore.shareInstance())
                ),
                permissionHandler: DevicePermissionsHandler.makeHandler(),
                networkMonitorUseCase: NetworkMonitorUseCase(repo: NetworkMonitorRepository()),
                createContextMenuUseCase: CreateContextMenuUseCase(repo: CreateContextMenuRepository.newRepo),
                router: FileUploadingRouter(navigationController: navigationController, baseViewController: self)
            )
            self.uploadViewModel = uploadViewModel
        }
        
        switch action {
        case .newTextFile:
            uploadViewModel?.didTapUploadFromNewTextFile()
        case .scanDocument:
            uploadViewModel?.didTapUploadFromDocumentScan()
        case .importFrom:
            uploadViewModel?.didTapUploadFromImports()
        default: break
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonPressed(_ button: UIBarButtonItem) {
        currentState.endEditingMode()
    }
    
    @objc private func selectAllButtonPressed(_ button: UIBarButtonItem) {
        currentState.toggleSelectAllNodes()
    }
    
    func configureSearchBar() {
        if navigationItem.searchController == nil {
            navigationItem.searchController = searchController
        }
    }
}

// MARK: - UISearchResultsUpdating
extension FilesExplorerContainerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.trim else {
            currentState.updateSearchResults(for: nil)
            return
        }
        
        currentState.updateSearchResults(for: searchText)
    }
}

extension FilesExplorerContainerViewController: TraitEnviromentAware {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(to: traitCollection, from: previousTraitCollection)
    }
    
    func colorAppearanceDidChange(to currentTrait: UITraitCollection, from previousTrait: UITraitCollection?) {
        AppearanceManager.forceSearchBarUpdate(searchController.searchBar,
                                               traitCollection: traitCollection)
    }
}

// MARK: - AudioPlayer
extension FilesExplorerContainerViewController: AudioPlayerPresenterProtocol {
    func updateContentView(_ height: CGFloat) {
        currentState.updateContentView(height)
    }
}
