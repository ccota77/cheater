import Foundation
import MEGADomain

public extension ShareEntity {
    init(sharedUserEmail: String? = nil,
         nodeHandle: HandleEntity = 0,
         accessLevel: ShareAccessLevelEntity = .unknown,
         createdDate: Date = Date(),
         isPending: Bool = false,
         isVerified: Bool = false,
         isTesting: Bool = true) {
        self.init(sharedUserEmail: sharedUserEmail, nodeHandle: nodeHandle, accessLevel: accessLevel, createdDate: createdDate, isPending: isPending, isVerified: isVerified)
    }
}
