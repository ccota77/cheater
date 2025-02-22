// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Colors {
  internal enum Background {
    internal enum Regular {
      internal static let primaryElevated = ColorAsset(name: "primaryElevated")
    }
  }
  internal enum Banner {
    internal static let warningBannerBackground = ColorAsset(name: "warningBannerBackground")
    internal static let warningTextColor = ColorAsset(name: "warningTextColor")
  }
  internal enum CallScene {
    internal static let avatarBackground = ColorAsset(name: "avatarBackground")
    internal static let avatarBackgroundGradient = ColorAsset(name: "avatarBackgroundGradient")
  }
  internal enum Chat {
    internal enum Avatar {
      internal static let background = ColorAsset(name: "background")
    }
    internal enum Listing {
      internal static let archiveSwipeActionBackground = ColorAsset(name: "archiveSwipeActionBackground")
      internal static let meetingTimeTextColor = ColorAsset(name: "meetingTimeTextColor")
      internal static let moreSwipeActionBackground = ColorAsset(name: "moreSwipeActionBackground")
      internal static let sectionBackground = ColorAsset(name: "sectionBackground")
      internal static let sectionBottomDividerBackground = ColorAsset(name: "sectionBottomDividerBackground")
      internal static let sectionTitle = ColorAsset(name: "sectionTitle")
      internal static let subtitleText = ColorAsset(name: "subtitleText")
    }
    internal enum Meeting {
      internal static let frequencySelectionTickMark = ColorAsset(name: "FrequencySelectionTickMark")
    }
    internal enum ReactionBubble {
      internal static let border = ColorAsset(name: "border")
      internal static let selectedDark = ColorAsset(name: "selectedDark")
      internal static let selectedLight = ColorAsset(name: "selectedLight")
      internal static let unselectedDefault = ColorAsset(name: "unselectedDefault")
    }
    internal enum Status {
      internal static let away = ColorAsset(name: "away")
      internal static let busy = ColorAsset(name: "busy")
      internal static let offline = ColorAsset(name: "offline")
      internal static let online = ColorAsset(name: "online")
    }
    internal enum Tabs {
      internal static let chatTabNormalBackground = ColorAsset(name: "chatTabNormalBackground")
      internal static let chatTabNormalText = ColorAsset(name: "chatTabNormalText")
      internal static let chatTabSelectedBackground = ColorAsset(name: "chatTabSelectedBackground")
      internal static let chatTabSelectedText = ColorAsset(name: "chatTabSelectedText")
    }
  }
  internal enum General {
    internal enum Background {
      internal static let cellColor = ColorAsset(name: "cellColor")
    }
    internal enum Black {
      internal static let _000000 = ColorAsset(name: "000000")
      internal static let _00000075 = ColorAsset(name: "000000_75")
      internal static let _161616 = ColorAsset(name: "161616")
      internal static let _1c1c1e = ColorAsset(name: "1c1c1e")
      internal static let _252525 = ColorAsset(name: "252525")
      internal static let _2c2c2e = ColorAsset(name: "2c2c2e")
    }
    internal enum Blue {
      internal static let _007Aff = ColorAsset(name: "007AFF")
      internal static let _0089C7 = ColorAsset(name: "0089C7")
      internal static let _009Ae0 = ColorAsset(name: "009AE0")
      internal static let _059De2 = ColorAsset(name: "059DE2")
      internal static let _38C1Ff = ColorAsset(name: "38C1FF")
    }
    internal enum Brown {
      internal static let _544b27 = ColorAsset(name: "544b27")
    }
    internal enum Gray {
      internal static let _04040F = ColorAsset(name: "04040F")
      internal static let _1D1D1D = ColorAsset(name: "1D1D1D")
      internal static let _333333 = ColorAsset(name: "333333")
      internal static let _363638 = ColorAsset(name: "363638")
      internal static let _3A3A3C = ColorAsset(name: "3A3A3C")
      internal static let _3C3C43 = ColorAsset(name: "3C3C43")
      internal static let _3D3D3D = ColorAsset(name: "3D3D3D")
      internal static let _3F3F42 = ColorAsset(name: "3F3F42")
      internal static let _474747 = ColorAsset(name: "474747")
      internal static let _515151 = ColorAsset(name: "515151")
      internal static let _535356 = ColorAsset(name: "535356")
      internal static let _545457 = ColorAsset(name: "545457")
      internal static let _545458 = ColorAsset(name: "545458")
      internal static let _676767 = ColorAsset(name: "676767")
      internal static let _848484 = ColorAsset(name: "848484")
      internal static let _8E8E93 = ColorAsset(name: "8E8E93")
      internal static let _949494 = ColorAsset(name: "949494")
      internal static let b5B5B5 = ColorAsset(name: "B5B5B5")
      internal static let bababc = ColorAsset(name: "BABABC")
      internal static let bbbbbb = ColorAsset(name: "BBBBBB")
      internal static let c9C9C9 = ColorAsset(name: "C9C9C9")
      internal static let d1D1D1 = ColorAsset(name: "D1D1D1")
      internal static let e2E2E2 = ColorAsset(name: "E2E2E2")
      internal static let e5E5E5 = ColorAsset(name: "E5E5E5")
      internal static let e6E6E6 = ColorAsset(name: "E6E6E6")
      internal static let ebebeb = ColorAsset(name: "EBEBEB")
      internal static let ebebf5 = ColorAsset(name: "EBEBF5")
      internal static let f4F4F4 = ColorAsset(name: "F4F4F4")
      internal static let navigationBgColor = ColorAsset(name: "navigationBgColor")
    }
    internal enum Green {
      internal static let _007B62 = ColorAsset(name: "007B62")
      internal static let _009476 = ColorAsset(name: "009476")
      internal static let _00A382 = ColorAsset(name: "00A382")
      internal static let _00A886 = ColorAsset(name: "00A886")
      internal static let _00C29A = ColorAsset(name: "00C29A")
      internal static let _00E9B9 = ColorAsset(name: "00E9B9")
      internal static let _347467 = ColorAsset(name: "347467")
      internal static let _34C759 = ColorAsset(name: "34C759")
    }
    internal enum Orange {
      internal static let ff9500 = ColorAsset(name: "FF9500")
    }
    internal enum Red {
      internal static let ce0A11 = ColorAsset(name: "CE0A11")
      internal static let f30C14 = ColorAsset(name: "F30C14")
      internal static let f7363D = ColorAsset(name: "F7363D")
      internal static let f95C61 = ColorAsset(name: "F95C61")
      internal static let ff3B30 = ColorAsset(name: "FF3B30")
      internal static let ff453A = ColorAsset(name: "FF453A")
    }
    internal enum Shadow {
      internal static let blackAlpha10 = ColorAsset(name: "blackAlpha10")
      internal static let blackAlpha20 = ColorAsset(name: "blackAlpha20")
    }
    internal enum View {
      internal static let cellBackground = ColorAsset(name: "cellBackground")
      internal static let textForeground = ColorAsset(name: "textForeground")
    }
    internal enum White {
      internal static let eeeeee = ColorAsset(name: "EEEEEE")
      internal static let efefef = ColorAsset(name: "EFEFEF")
      internal static let f2F2F2 = ColorAsset(name: "F2F2F2")
      internal static let f7F7F7 = ColorAsset(name: "F7F7F7")
      internal static let fcfcfc = ColorAsset(name: "FCFCFC")
      internal static let ffffff = ColorAsset(name: "FFFFFF")
    }
    internal enum Yellow {
      internal static let _9D8319 = ColorAsset(name: "9D8319")
      internal static let f8D552 = ColorAsset(name: "F8D552")
      internal static let fed429 = ColorAsset(name: "FED429")
    }
  }
  internal enum MediaConsumption {
    internal static let decryptTitleDisabled = ColorAsset(name: "decryptTitleDisabled")
    internal static let decryptTitleEnabled = ColorAsset(name: "decryptTitleEnabled")
    internal static let photoNumbersBackground = ColorAsset(name: "photoNumbersBackground")
    internal static let timelineYMDATabs = ColorAsset(name: "timelineYMDATabs")
    internal static let timelineYMDATabsSelected = ColorAsset(name: "timelineYMDATabsSelected")
  }
  internal enum MediaDiscovery {
    internal static let exitButtonTint = ColorAsset(name: "exitButtonTint")
  }
  internal enum PROAccount {
    internal static let proLITE = ColorAsset(name: "proLITE")
    internal static let redProI = ColorAsset(name: "redProI")
    internal static let redProII = ColorAsset(name: "redProII")
    internal static let redProIII = ColorAsset(name: "redProIII")
  }
  internal enum Psa {
    internal static let imageBackground = ColorAsset(name: "imageBackground")
  }
  internal enum Photos {
    internal static let filterBackground = ColorAsset(name: "filterBackground")
    internal static let filterLocationItemBackground = ColorAsset(name: "filterLocationItemBackground")
    internal static let filterLocationItemForeground = ColorAsset(name: "filterLocationItemForeground")
    internal static let filterLocationItemTickForeground = ColorAsset(name: "filterLocationItemTickForeground")
    internal static let filterNormalTextForeground = ColorAsset(name: "filterNormalTextForeground")
    internal static let filterTextForeground = ColorAsset(name: "filterTextForeground")
    internal static let filterTypeNormalBackground = ColorAsset(name: "filterTypeNormalBackground")
    internal static let filterTypeSelectionBackground = ColorAsset(name: "filterTypeSelectionBackground")
    internal static let filterTypeSelectionForeground = ColorAsset(name: "filterTypeSelectionForeground")
    internal static let pageTabForeground = ColorAsset(name: "pageTabForeground")
    internal static let photoSeletionBorder = ColorAsset(name: "photoSeletionBorder")
    internal static let rightBarButtonForeground = ColorAsset(name: "rightBarButtonForeground")
    internal static let zoomButtonForeground = ColorAsset(name: "zoomButtonForeground")
  }
  internal enum SharedItems {
    internal enum Tabs {
      internal static let sharedItemsTabNormalBackground = ColorAsset(name: "sharedItemsTabNormalBackground")
      internal static let sharedItemsTabNormalIconTint = ColorAsset(name: "sharedItemsTabNormalIconTint")
      internal static let sharedItemsTabNormalText = ColorAsset(name: "sharedItemsTabNormalText")
      internal static let sharedItemsTabSelectedBackground = ColorAsset(name: "sharedItemsTabSelectedBackground")
      internal static let sharedItemsTabSelectedIconTint = ColorAsset(name: "sharedItemsTabSelectedIconTint")
      internal static let sharedItemsTabSelectedText = ColorAsset(name: "sharedItemsTabSelectedText")
    }
  }
  internal enum SharedViews {
    internal enum Explorer {
      internal enum Gradient {
        internal static let darkBlue = ColorAsset(name: "darkBlue")
        internal static let lightBlue = ColorAsset(name: "lightBlue")
        internal static let pink = ColorAsset(name: "pink")
        internal static let red = ColorAsset(name: "red")
      }
      internal static let audioFirstGradient = ColorAsset(name: "audioFirstGradient")
      internal static let audioSecondGradient = ColorAsset(name: "audioSecondGradient")
      internal static let documentsFirstGradient = ColorAsset(name: "documentsFirstGradient")
      internal static let documentsSecondGradient = ColorAsset(name: "documentsSecondGradient")
      internal static let foregroundDark = ColorAsset(name: "foregroundDark")
    }
    internal enum VerifyEmail {
      internal static let firstGradient = ColorAsset(name: "firstGradient")
      internal static let secondGradient = ColorAsset(name: "secondGradient")
    }
    internal static let pasteImageBorder = ColorAsset(name: "pasteImageBorder")
  }
  internal enum UpgradeAccount {
    internal enum Plan {
      internal static let bodyBackground = ColorAsset(name: "bodyBackground")
      internal static let borderTint = ColorAsset(name: "borderTint")
      internal static let currentPlan = ColorAsset(name: "currentPlan")
      internal static let headerBackground = ColorAsset(name: "headerBackground")
      internal static let recommended = ColorAsset(name: "recommended")
      internal static let unselectedTint = ColorAsset(name: "unselectedTint")
    }
    internal static let primaryGrayText = ColorAsset(name: "primaryGrayText")
    internal static let primaryText = ColorAsset(name: "primaryText")
    internal static let secondaryText = ColorAsset(name: "secondaryText")
    internal static let subMessageBackground = ColorAsset(name: "subMessageBackground")
  }
  internal enum Views {
    internal static let turquoise = ColorAsset(name: "turquoise")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
