import Foundation

extension CustomModalAlertViewController {
    func configureUpgradeAccountThreeButtons(_ titleText: String, _ detailText: String, _ monospaceText: String?, _ imageName: String?, hasBonusButton: Bool = true, firstButtonTitle: String = Strings.Localizable.seePlans, dismissTitle: String = Strings.Localizable.dismiss) {
        if let imageName = imageName {
            image = UIImage(named: imageName)
        }
        viewTitle = titleText
        
        if monospaceText != nil {
            monospaceDetail = monospaceText
            detail = detailText + " (ID: " + monospaceDetail + ")"
        } else {
            detail = detailText
        }
        
        self.firstButtonTitle = firstButtonTitle
        if MEGASdkManager.sharedMEGASdk().isAchievementsEnabled && hasBonusButton {
            secondButtonTitle = Strings.Localizable.General.Button.getBonus
        }
        dismissButtonTitle = dismissTitle
        
        firstCompletion = { [weak self] in
            self?.dismiss(animated: true, completion: {
                UpgradeAccountRouter().presentUpgradeTVC()
            })
        }
        
        secondCompletion = { [weak self] in
            self?.dismiss(animated: true, completion: {
                guard let achievementsVC = UIStoryboard(name: "Achievements", bundle: nil).instantiateViewController(withIdentifier: "AchievementsViewControllerID") as? AchievementsViewController else {
                    fatalError("Could not instantiate AchievementsViewController")
                }
                achievementsVC.enableCloseBarButton = true
                
                let navigationVC = UINavigationController(rootViewController: achievementsVC)
                UIApplication.mnz_presentingViewController().present(navigationVC, animated: true, completion: nil)
            })
        }
        
        dismissCompletion = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func configureUpgradeAccountDetailText(_ detailText: String) {
        setDetailLabelText(detailText)
    }
}
