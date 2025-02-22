import Foundation
import MEGADomain
import MEGASDKRepo

extension CustomModalAlertViewController {
    func configureForStorageEvent(_ event: MEGAEvent) {
        let imageName = event.number == StorageState.orange.rawValue ? Asset.Images.WarningStorageAlmostFull.storageAlmostFull.name : Asset.Images.WarningStorageAlmostFull.storageFull.name
        
        let title = event.number == StorageState.orange.rawValue ? Strings.Localizable.upgradeAccount : Strings.Localizable.Dialog.Storage.Odq.title
        
        let detailText = storageDetailForEvent(event, pricing: MEGAPurchase.sharedInstance().pricing)
        configureUpgradeAccountThreeButtons(title, detailText, nil, imageName)
        
        if MEGAPurchase.sharedInstance().pricing == nil {
            SVProgressHUD.show()
            let sdkDelegate = MEGAResultRequestDelegate { (result) in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let request):
                    let pricing = request.pricing ?? MEGAPricing()
                    let detailText = self.storageDetailForEvent(event, pricing: pricing)
                    self.configureUpgradeAccountDetailText(detailText)
                default:
                    return
                }
            }
            MEGASdkManager.sharedMEGASdk().getPricingWith(sdkDelegate)
        }
    }
    
    private func storageDetailForEvent(_ event: MEGAEvent, pricing: MEGAPricing?) -> String {
        let pricing = pricing ?? MEGAPricing()
        let productStorage = pricing.productStorageGB(ofAccountType: .proIII)
        
        // StorageGB can return 0 if there is no product or the given account type doesn't match on the product list.
        // Checking if it is greater than zero first to avoid negative TB storage.
        let maxTB = productStorage > 0 ? productStorage / 1024 : 0
        
        let maxStorage = String(format: "%ld", productStorage)
        let maxStorageTB = String(format: "%ld", maxTB)
        
        let detailText = event.number == StorageState.orange.rawValue ? Strings.Localizable.Dialog.Storage.AlmostFull.detail(maxStorageTB, maxStorage) : Strings.Localizable.Dialog.Storage.Odq.detail
        return detailText
    }
    
    func configureForStorageQuotaError(_ uploading: Bool) {
        var imageName: String?
        if let accountDetails = MEGASdkManager.sharedMEGASdk().mnz_accountDetails {
            imageName = accountDetails.storageMax.int64Value > accountDetails.storageUsed.int64Value ? Asset.Images.WarningStorageAlmostFull.storageAlmostFull.name : Asset.Images.WarningStorageAlmostFull.storageFull.name
        }
        
        let title = Strings.Localizable.upgradeAccount
        let detailText = uploading ? Strings.Localizable.yourUploadSCannotProceedBecauseYourAccountIsFull : Strings.Localizable.thisActionCanNotBeCompletedAsItWouldTakeYouOverYourCurrentStorageLimit
        
        configureUpgradeAccountThreeButtons(title, detailText, nil, imageName)
    }
    
    func configureForStorageDownloadQuotaError() {
        let imageName = Asset.Images.WarningTransferQuota.transferQuotaEmpty.name
        let title = Strings.Localizable.depletedTransferQuotaTitle
        let detailText = Strings.Localizable.depletedTransferQuotaMessage
        let base64Handle = MEGASdk.base64Handle(forUserHandle: MEGASdk.currentUserHandle()?.uint64Value ?? MEGAInvalidHandle)
        
        configureUpgradeAccountThreeButtons(title, detailText, base64Handle, imageName, hasBonusButton: false)
    }
    
    func configureForStorageQuotaWillExceed(for displayMode: CustomModalAlertView.Mode.StorageQuotaWillExceedDisplayMode) {
        
        let title: String
        let detailText: String
        let imageName: ImageAsset
        
        switch displayMode {
        case .albumLink:
            title = Strings.Localizable.AlbumLink.ImportFailed.StorageQuotaWillExceed.Alert.title
            detailText = Strings.Localizable.AlbumLink.ImportFailed.StorageQuotaWillExceed.Alert.detail
            imageName = Asset.Images.WarningStorageAlmostFull.storageFull
        }
        
        configureUpgradeAccountThreeButtons(
            title,
            detailText,
            nil,
            imageName.name,
            hasBonusButton: false,
            firstButtonTitle: Strings.Localizable.upgrade,
            dismissTitle: Strings.Localizable.cancel)
    }
}
