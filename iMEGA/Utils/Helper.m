#import "Helper.h"

#import <CoreSpotlight/CoreSpotlight.h>
#import "LTHPasscodeViewController.h"
#import "SAMKeychain.h"
#import "SVProgressHUD.h"

#import "NSFileManager+MNZCategory.h"
#import "NSDate+MNZCategory.h"
#import "NSString+MNZCategory.h"
#import "UIApplication+MNZCategory.h"
#import "UIImageView+MNZCategory.h"

#import "MEGACopyRequestDelegate.h"
#import "MEGACreateFolderRequestDelegate.h"
#import "MEGAGenericRequestDelegate.h"
#import "MEGANode+MNZCategory.h"
#import "MEGANodeList+MNZCategory.h"
#import "MEGAProcessAsset.h"
#import "MEGALogger.h"
#import "MEGASdkManager.h"
#import "MEGASdk+MNZCategory.h"
#import "MEGAStore.h"
#import "MEGAUser+MNZCategory.h"

#ifdef MNZ_SHARE_EXTENSION
#import "MEGAShare-Swift.h"
#else
#import "MEGA-Swift.h"
#endif

#import "NodeTableViewCell.h"
#import "PhotoCollectionViewCell.h"

@implementation Helper

#pragma mark - Paths

+ (NSString *)pathForOffline {
    static NSString *pathString = nil;
    
    if (pathString == nil) {
        pathString = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        pathString = [pathString stringByAppendingString:@"/"];
    }
    
    return pathString;
}

+ (NSString *)pathRelativeToOfflineDirectory:(NSString *)totalPath {
    NSRange rangeOfSubstring = [totalPath rangeOfString:[Helper pathForOffline]];
    NSString *relativePath = [totalPath substringFromIndex:rangeOfSubstring.length];
    return relativePath;
}

+ (NSString *)pathForNode:(MEGANode *)node searchPath:(NSSearchPathDirectory)path directory:(NSString *)directory {
    
    NSString *destinationPath = NSSearchPathForDirectoriesInDomains(path, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [node base64Handle];
    NSString *destinationFilePath = nil;
    destinationFilePath = [directory isEqualToString:@""] ? [destinationPath stringByAppendingPathComponent:fileName]
    :[[destinationPath stringByAppendingPathComponent:directory] stringByAppendingPathComponent:fileName];
    
    return destinationFilePath;
}

+ (NSString *)pathForNode:(MEGANode *)node inSharedSandboxCacheDirectory:(NSString *)directory {
    return [self pathForHandle:node.base64Handle inSharedSandboxCacheDirectory:directory];
}

+ (NSString *)pathWithOriginalNameForNode:(MEGANode *)node inSharedSandboxCacheDirectory:(NSString *)directory {
    NSString *folderParentPath = [self pathForHandle:node.base64Handle inSharedSandboxCacheDirectory:directory];
    if (![NSFileManager.defaultManager fileExistsAtPath:folderParentPath isDirectory:nil]) {
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtPath:folderParentPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            MEGALogError(@"Create directory at path failed with error: %@", error);
        }
    }

    return [folderParentPath stringByAppendingPathComponent:node.name];
}

+ (NSString *)pathForHandle:(NSString *)base64Handle inSharedSandboxCacheDirectory:(NSString *)directory {
    NSString *destinationPath = [Helper pathForSharedSandboxCacheDirectory:directory];
    return [destinationPath stringByAppendingPathComponent:base64Handle];
}

+ (NSString *)pathForSharedSandboxCacheDirectory:(NSString *)directory {
    return [[self urlForSharedSandboxCacheDirectory:directory] path];
}

+ (NSURL *)urlForSharedSandboxCacheDirectory:(NSString *)directory {
    NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:MEGAGroupIdentifier];
    NSURL *destinationURL = [[containerURL URLByAppendingPathComponent:MEGAExtensionCacheFolder isDirectory:YES] URLByAppendingPathComponent:directory isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:destinationURL withIntermediateDirectories:YES attributes:nil error:nil];
    return destinationURL;
}

#pragma mark - Utils for transfers

+ (BOOL)isFreeSpaceEnoughToDownloadNode:(MEGANode *)node isFolderLink:(BOOL)isFolderLink {
    NSNumber *nodeSizeNumber;
    
    if ([node type] == MEGANodeTypeFile) {
        nodeSizeNumber = [node size];
    } else if ([node type] == MEGANodeTypeFolder) {
        if (isFolderLink) {
            nodeSizeNumber = [[MEGASdkManager sharedMEGASdkFolder] sizeForNode:node];
        } else {
            nodeSizeNumber = [[MEGASdkManager sharedMEGASdk] sizeForNode:node];
        }
    }
    
    NSError *error;
    uint64_t freeSpace = [NSFileManager.defaultManager mnz_fileSystemFreeSizeWithError:error];
    if (error) {
        return YES;
    }
    
    if (freeSpace < [nodeSizeNumber longLongValue]) {
#ifdef MAIN_APP_TARGET
        dispatch_async(dispatch_get_main_queue(), ^{
            StorageFullModalAlertViewController *warningVC = StorageFullModalAlertViewController.alloc.init;
            [warningVC showWithRequiredStorage:nodeSizeNumber.longLongValue];
        });
#endif
        return NO;
    }
    return YES;
}

+ (void)copyNode:(MEGANode *)node from:(NSString *)itemPath to:(NSString *)relativeFilePath api:(MEGASdk *)api {
    NSRange replaceRange = [relativeFilePath rangeOfString:@"Documents/"];
    if (replaceRange.location != NSNotFound) {
        NSString *result = [relativeFilePath stringByReplacingCharactersInRange:replaceRange withString:@""];
        NSError *error;
        if ([[NSFileManager defaultManager] copyItemAtPath:itemPath toPath:[NSHomeDirectory() stringByAppendingPathComponent:relativeFilePath] error:&error]) {
            [[MEGAStore shareInstance] insertOfflineNode:node api:api path:result.decomposedStringWithCanonicalMapping];
        } else {
            MEGALogError(@"Failed to copy from %@ to %@ with error: %@", itemPath, relativeFilePath, error);
        }
    }
}

+ (void)moveNode:(MEGANode *)node from:(NSString *)itemPath to:(NSString *)relativeFilePath api:(MEGASdk *)api {
    NSRange replaceRange = [relativeFilePath rangeOfString:@"Documents/"];
    if (replaceRange.location != NSNotFound) {
        NSString *result = [relativeFilePath stringByReplacingCharactersInRange:replaceRange withString:@""];
        NSError *error;
        if ([[NSFileManager defaultManager] moveItemAtPath:itemPath toPath:[NSHomeDirectory() stringByAppendingPathComponent:relativeFilePath] error:&error]) {
            [[MEGAStore shareInstance] insertOfflineNode:node api:api path:result.decomposedStringWithCanonicalMapping];
        } else {
            MEGALogError(@"Failed to move from %@ to %@ with error: %@", itemPath, relativeFilePath, error);
        }
    }
}

+ (NSMutableArray *)uploadingNodes {
    static NSMutableArray *uploadingNodes = nil;
    if (!uploadingNodes) {
        uploadingNodes = [[NSMutableArray alloc] init];
    }
    
    return uploadingNodes;
}

+ (void)startUploadTransferWithTransferRecordDTO:(TransferRecordDTO *)transferRecordDTO {
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[transferRecordDTO.localIdentifier]
                                                      options:nil].firstObject;
    
    MEGANode *parentNode = [[MEGASdkManager sharedMEGASdk] nodeForHandle:transferRecordDTO.parentNodeHandle.unsignedLongLongValue];
    
    MEGAProcessAsset *processAsset = [[MEGAProcessAsset alloc] initWithAsset:asset filePath:^(NSString *filePath) {
        NSString *name = [FileExtensionOCWrapper fileNameWithLowercaseExtensionFrom:filePath.lastPathComponent];
        NSString *newName = [name mnz_sequentialFileNameInParentNode:parentNode];
        
        NSString *appData = [NSString new];
        
        appData = [appData mnz_appDataToSaveCoordinates:[filePath mnz_coordinatesOfPhotoOrVideo]];
        appData = [appData mnz_appDataToLocalIdentifier:transferRecordDTO.localIdentifier];
        
        if (![name isEqualToString:newName]) {
            NSString *newFilePath = [[NSFileManager defaultManager].uploadsDirectory stringByAppendingPathComponent:newName];
            
            NSError *error = nil;
            NSString *absoluteFilePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
            if (![[NSFileManager defaultManager] moveItemAtPath:absoluteFilePath toPath:newFilePath error:&error]) {
                MEGALogError(@"Move item at path failed with error: %@", error);
            }
            [MEGASdkManager.sharedMEGASdk startUploadWithLocalPath:newFilePath.mnz_relativeLocalPath parent:parentNode fileName:nil appData:appData isSourceTemporary:YES startFirst:NO cancelToken:nil];
        } else {
            [MEGASdkManager.sharedMEGASdk startUploadWithLocalPath:filePath.mnz_relativeLocalPath parent:parentNode fileName:nil appData:appData isSourceTemporary:YES startFirst:NO cancelToken:nil];
        }
        
        if (transferRecordDTO.localIdentifier) {
            [[Helper uploadingNodes] addObject:transferRecordDTO.localIdentifier];
        }
        [[MEGAStore shareInstance] deleteUploadTransferWithLocalIdentifier:transferRecordDTO.localIdentifier];
    } error:^(NSError *error) {
        [SVProgressHUD showImage:[UIImage imageNamed:@"hudError"] status:[NSString stringWithFormat:@"%@ %@ \r %@", NSLocalizedString(@"Transfer failed:", nil), asset.localIdentifier, error.localizedDescription]];
        [[MEGAStore shareInstance] deleteUploadTransferWithLocalIdentifier:transferRecordDTO.localIdentifier];
        [Helper startPendingUploadTransferIfNeeded];
    }];
    
    [processAsset prepare];
}

+ (void)startPendingUploadTransferIfNeeded {
    BOOL allUploadTransfersPaused = YES;
    
    MEGATransferList *transferList = [[MEGASdkManager sharedMEGASdk] uploadTransfers];
    
    for (int i = 0; i < transferList.size.intValue; i++) {
        MEGATransfer *transfer = [transferList transferAtIndex:i];
        
        if (transfer.state == MEGATransferStateActive) {
            allUploadTransfersPaused = NO;
            break;
        }
    }
    
    if (allUploadTransfersPaused) {
        TransferRecordDTO *transferRecordDTO = [MEGAStore.shareInstance fetchUploadTransfers].firstObject;
        if (transferRecordDTO != nil) {
            [self startUploadTransferWithTransferRecordDTO:transferRecordDTO];
        }
    }
}

#pragma mark - Utils

+ (void)saveSortOrder:(MEGASortOrderType)selectedSortOrderType for:(_Nullable id)object {
    SortingPreference sortingPreference = [NSUserDefaults.standardUserDefaults integerForKey:MEGASortingPreference];

    if (object && sortingPreference == SortingPreferencePerFolder) {
        MEGASortOrderType currentSortOrderType = [Helper sortTypeFor:object];
        
        if (currentSortOrderType == selectedSortOrderType) {
            return;
        }
        
        if ([object isKindOfClass:MEGANode.class]) {
            MEGANode *node = (MEGANode *)object;
            [MEGAStore.shareInstance insertOrUpdateCloudSortTypeWithHandle:node.handle sortType:selectedSortOrderType];
        } else if ([object isKindOfClass:NSString.class]) {
            NSString *relativeOfflinePath = [self pathRelativeToOfflineDirectory:(NSString *)object];
            if ([relativeOfflinePath length] == 0) {
                relativeOfflinePath = @"Documents";
            }
            [MEGAStore.shareInstance insertOrUpdateOfflineSortTypeWithPath:relativeOfflinePath sortType:selectedSortOrderType];
        }
                
        [NSNotificationCenter.defaultCenter postNotificationName:MEGASortingPreference object:self userInfo:@{MEGASortingPreference : @(sortingPreference), MEGASortingPreferenceType : @(selectedSortOrderType)}];
    } else {
        [NSUserDefaults.standardUserDefaults setInteger:SortingPreferenceSameForAll forKey:MEGASortingPreference];
        [NSUserDefaults.standardUserDefaults setInteger:selectedSortOrderType forKey:MEGASortingPreferenceType];
        
        [NSNotificationCenter.defaultCenter postNotificationName:MEGASortingPreference object:self userInfo:@{MEGASortingPreference : @(SortingPreferenceSameForAll), MEGASortingPreferenceType : @(selectedSortOrderType)}];
    }
}

+ (MEGASortOrderType)sortTypeFor:(_Nullable id)object {
    MEGASortOrderType sortType;
    SortingPreference sortingPreference = [NSUserDefaults.standardUserDefaults integerForKey:MEGASortingPreference];
    if (object) {
        if (sortingPreference == SortingPreferencePerFolder) {
            if ([object isKindOfClass:MEGANode.class]) {
                MEGANode *node = (MEGANode *)object;
                CloudAppearancePreference *cloudAppearancePreference = [MEGAStore.shareInstance fetchCloudAppearancePreferenceWithHandle:node.handle];
                sortType = cloudAppearancePreference ? cloudAppearancePreference.sortType.integerValue : MEGASortOrderTypeDefaultAsc;
            } else if ([object isKindOfClass:NSString.class]) {
                NSString *relativeOfflinePath = [self pathRelativeToOfflineDirectory:(NSString *)object];
                if ([relativeOfflinePath length] == 0) {
                    relativeOfflinePath = @"Documents";
                }
                OfflineAppearancePreference *offlineAppearancePreference = [MEGAStore.shareInstance fetchOfflineAppearancePreferenceWithPath: relativeOfflinePath];
                sortType = offlineAppearancePreference ? offlineAppearancePreference.sortType.integerValue : MEGASortOrderTypeDefaultAsc;
            } else {
                sortType = MEGASortOrderTypeDefaultAsc;
            }
        } else {
            MEGASortOrderType currentSortType = [NSUserDefaults.standardUserDefaults integerForKey:MEGASortingPreferenceType];
            sortType = currentSortType ? currentSortType : Helper.defaultSortType;
        }
    } else {
        MEGASortOrderType currentSortType = [NSUserDefaults.standardUserDefaults integerForKey:MEGASortingPreferenceType];
        sortType = currentSortType ? currentSortType : Helper.defaultSortType;
    }
    
    return sortType;
}

+ (MEGASortOrderType)defaultSortType {
    [NSUserDefaults.standardUserDefaults setInteger:MEGASortOrderTypeDefaultAsc forKey:MEGASortingPreferenceType];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    return MEGASortOrderTypeDefaultAsc;
}

+ (void)changeApiURL {
    NSString *alertTitle = NSLocalizedString(@"Change to a test server?", @"title of the alert dialog when the user is changing the API URL to staging");
    NSString *alertMessage = NSLocalizedString(@"Are you sure you want to change to a test server? Your account may suffer irrecoverable problems", @"text of the alert dialog when the user is changing the API URL to staging");
    
    UIAlertController *changeApiServerAlertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [changeApiServerAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Button title to cancel something") style:UIAlertActionStyleCancel handler:nil]];
    
    [changeApiServerAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Production", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Helper setApiURL:MEGAAPIEnvProduction];
        [Helper apiURLChanged];
    }]];
    
    [changeApiServerAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"staging", @"Button title to cancel something") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Helper setApiURL:MEGAAPIEnvStaging];
        [Helper apiURLChanged];
    }]];
    
    [changeApiServerAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Staging:444", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Helper setApiURL:MEGAAPIEnvStaging444];
        [Helper apiURLChanged];
    }]];
    
    [changeApiServerAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Sandbox3", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Helper setApiURL:MEGAAPIEnvSandbox3];
        [Helper apiURLChanged];
    }]];
    
    [UIApplication.mnz_visibleViewController presentViewController:changeApiServerAlertController animated:YES completion:nil];
}

+ (void)setApiURL:(MEGAAPIEnv)envType {
    switch (envType) {
        case MEGAAPIEnvProduction:
            [[MEGASdkManager sharedMEGASdk] changeApiUrl:@"https://g.api.mega.co.nz/" disablepkp:NO];
            [[MEGASdkManager sharedMEGASdkFolder] changeApiUrl:@"https://g.api.mega.co.nz/" disablepkp:NO];
            break;
        case MEGAAPIEnvStaging:
            [[MEGASdkManager sharedMEGASdk] changeApiUrl:@"https://staging.api.mega.co.nz/" disablepkp:NO];
            [[MEGASdkManager sharedMEGASdkFolder] changeApiUrl:@"https://staging.api.mega.co.nz/" disablepkp:NO];
            break;
        case MEGAAPIEnvStaging444:
            [MEGASdkManager.sharedMEGASdk changeApiUrl:@"https://staging.api.mega.co.nz:444/" disablepkp:YES];
            [MEGASdkManager.sharedMEGASdkFolder changeApiUrl:@"https://staging.api.mega.co.nz:444/" disablepkp:YES];
            break;
        case MEGAAPIEnvSandbox3:
            [MEGASdkManager.sharedMEGASdk changeApiUrl:@"https://api-sandbox3.developers.mega.co.nz/" disablepkp:YES];
            [MEGASdkManager.sharedMEGASdkFolder changeApiUrl:@"https://api-sandbox3.developers.mega.co.nz/" disablepkp:YES];
            break;
            
        default:
            break;
    }
    [NSUserDefaults.standardUserDefaults setInteger:envType forKey:@"MEGAAPIEnv"];
}

+ (void)apiURLChanged {
    [SVProgressHUD showSuccessWithStatus:@"API URL changed"];
    
    if ([SAMKeychain passwordForService:@"MEGA" account:@"sessionV3"]) {
        [[MEGASdkManager sharedMEGASdk] fastLoginWithSession:[SAMKeychain passwordForService:@"MEGA" account:@"sessionV3"]];
        [[MEGASdkManager sharedMEGAChatSdk] refreshUrls];
    }
}

+ (void)restoreAPISetting {
    MEGAAPIEnv APItype = [NSUserDefaults.standardUserDefaults integerForKey:@"MEGAAPIEnv"];
    [Helper setApiURL:APItype];
}

+ (void)cannotPlayContentDuringACallAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"It is not possible to play content while there is a call in progress", @"Message shown when there is an ongoing call and the user tries to play an audio or video") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [UIApplication.mnz_presentingViewController presentViewController:alertController animated:YES completion:nil];
}

+ (UIAlertController *)removeUserContactFromSender:(UIView *)sender withConfirmAction:(void (^)(void))confirmAction {

    UIAlertController *removeContactAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [removeContactAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    [removeContactAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"removeUserTitle", @"Alert title shown when you want to remove one or more contacts") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        confirmAction();
    }]];

    removeContactAlertController.popoverPresentationController.sourceView = sender;
    removeContactAlertController.popoverPresentationController.sourceRect = sender.bounds;
    
    return removeContactAlertController;
}

#pragma mark - Utils for nodes

+ (void)thumbnailForNode:(MEGANode *)node api:(MEGASdk *)api cell:(id)cell {
    NSString *thumbnailFilePath = [Helper pathForNode:node inSharedSandboxCacheDirectory:@"thumbnailsV3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath]) {
        [Helper setThumbnailForNode:node api:api cell:cell];
    } else {
        [api getThumbnailNode:node destinationFilePath:thumbnailFilePath];
        if ([cell isKindOfClass:[NodeTableViewCell class]]) {
            NodeTableViewCell *nodeTableViewCell = cell;
            [nodeTableViewCell.thumbnailImageView setImage:[NodeAssetsManager.shared iconFor:node]];
        } else if ([cell isKindOfClass:[PhotoCollectionViewCell class]]) {
            PhotoCollectionViewCell *photoCollectionViewCell = cell;
            [photoCollectionViewCell.thumbnailImageView setImage:[NodeAssetsManager.shared iconFor:node]];
        }
    }
}

+ (void)setThumbnailForNode:(MEGANode *)node api:(MEGASdk *)api cell:(id)cell {
    NSString *thumbnailFilePath = [Helper pathForNode:node inSharedSandboxCacheDirectory:@"thumbnailsV3"];
    if ([cell isKindOfClass:[NodeTableViewCell class]]) {
        NodeTableViewCell *nodeTableViewCell = cell;
        [nodeTableViewCell.thumbnailImageView setImage:[UIImage imageWithContentsOfFile:thumbnailFilePath]];
        nodeTableViewCell.thumbnailPlayImageView.hidden = ![FileExtensionGroupOCWrapper verifyIsVideo:node.name];
    } else if ([cell isKindOfClass:[PhotoCollectionViewCell class]]) {
        PhotoCollectionViewCell *photoCollectionViewCell = cell;
        [photoCollectionViewCell.thumbnailImageView setImage:[UIImage imageWithContentsOfFile:thumbnailFilePath]];
    }
}

+ (NSString *)sizeAndCreationHourAndMininuteForNode:(MEGANode *)node api:(MEGASdk *)api {
    return [NSString stringWithFormat:@"%@ • %@", [self sizeForNode:node api:api], node.creationTime.mnz_formattedHourAndMinutes];
}

+ (NSString *)sizeAndCreationDateForNode:(MEGANode *)node api:(MEGASdk *)api {
    return [NSString stringWithFormat:@"%@ • %@", [self sizeForNode:node api:api], node.creationTime.mnz_formattedDateMediumTimeShortStyle];
}

+ (NSString *)sizeAndModicationDateForNode:(MEGANode *)node api:(MEGASdk *)api {
    return [NSString stringWithFormat:@"%@ • %@", [self sizeForNode:node api:api], node.modificationTime.mnz_formattedDateMediumTimeShortStyle];
}

+ (NSString *)sizeAndShareLinkCreateDateForSharedLinkNode:(MEGANode *)node api:(MEGASdk *)api {
    return [NSString stringWithFormat:@"%@ • %@", [self sizeForNode:node api:api], node.publicLinkCreationTime.mnz_formattedDateMediumTimeShortStyle];
}

+ (NSString *)sizeForNode:(MEGANode *)node api:(MEGASdk *)api {
    NSString *size;
    if ([node isFile]) {
        size = [NSString memoryStyleStringFromByteCount:node.size.longLongValue];
    } else {
        size = [NSString memoryStyleStringFromByteCount:[api sizeForNode:node].longLongValue];
    }
    return size;
}

+ (NSString *)filesAndFoldersInFolderNode:(MEGANode *)node api:(MEGASdk *)api {
    NSInteger files = [api numberChildFilesForParent:node];
    NSInteger folders = [api numberChildFoldersForParent:node];
    
    return [NSString mnz_stringByFiles:files andFolders:folders];
}

+ (void)importNode:(MEGANode *)node toShareWithCompletion:(void (^)(MEGANode *node))completion {
    if (node.owner == [MEGASdkManager sharedMEGAChatSdk].myUserHandle) {
        completion(node);
    } else {
        MEGANode *remoteNode = [[MEGASdkManager sharedMEGASdk] nodeForFingerprint:node.fingerprint];
        if (remoteNode && remoteNode.owner == [MEGASdkManager sharedMEGAChatSdk].myUserHandle) {
            completion(remoteNode);
        } else {
            MEGACopyRequestDelegate *copyRequestDelegate = [[MEGACopyRequestDelegate alloc] initWithCompletion:^(MEGARequest *request) {
                MEGANode *resultNode = [[MEGASdkManager sharedMEGASdk] nodeForHandle:request.nodeHandle];
                completion(resultNode);
            }];
        
            [MyChatFilesFolderNodeAccess.shared loadNodeWithCompletion:^(MEGANode * _Nullable myChatFilesFolderNode, NSError * _Nullable error) {
                if (error || myChatFilesFolderNode == nil) {
                    MEGALogWarning(@"Coud not load MyChatFiles target folder doe tu error %@", error);
                    return;
                }
                [[MEGASdkManager sharedMEGASdk] copyNode:node newParent:myChatFilesFolderNode delegate:copyRequestDelegate];
            }];
        }
    }
}

#pragma mark - Manage session

+ (BOOL)hasSession_alertIfNot {
    if ([SAMKeychain passwordForService:@"MEGA" account:@"sessionV3"]) {
        return YES;
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"pleaseLogInToYourAccount", @"Alert title shown when you need to log in to continue with the action you want to do") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil]];
        [UIApplication.mnz_visibleViewController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
}

#pragma mark - Logout

+ (void)logout {
    [NSNotificationCenter.defaultCenter postNotificationName:MEGALogoutNotification object:self];    
    [Helper cancelAllTransfers];
    
    [self cleanAccount];
    
    [Helper deleteUserData];
    [Helper deleteMasterKey];

    [Helper resetUserData];
    
    [Helper deletePasscode];
}

+ (void)cancelAllTransfers {
    [[MEGASdkManager sharedMEGASdk] cancelTransfersForDirection:0];
    [[MEGASdkManager sharedMEGASdk] cancelTransfersForDirection:1];
    
    [[MEGASdkManager sharedMEGASdkFolder] cancelTransfersForDirection:0];
}

+ (void)clearEphemeralSession {
    [SAMKeychain deletePasswordForService:@"MEGA" account:@"sessionId"];
    [SAMKeychain deletePasswordForService:@"MEGA" account:@"email"];
    [SAMKeychain deletePasswordForService:@"MEGA" account:@"name"];
    [SAMKeychain deletePasswordForService:@"MEGA" account:@"password"];
}

+ (void)deleteUserData {
    // Remove "Inbox" folder return an error. "Inbox" is reserved by Apple
    NSString *offlineDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [NSFileManager.defaultManager mnz_removeFolderContentsAtPath:offlineDirectory];
    
    [NSFileManager.defaultManager mnz_removeFolderContentsAtPath:NSTemporaryDirectory()];
    
    // Delete application support directory content
    NSString *applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportDirectory error:nil]) {
        if ([file containsString:@"MEGACD"] || [file containsString:@"spotlightTree"] || [file containsString:@"Uploads"] || [file containsString:@"Downloads"]) {
            [NSFileManager.defaultManager mnz_removeItemAtPath:[applicationSupportDirectory stringByAppendingPathComponent:file]];
        }
    }

    // Delete Spotlight index
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            MEGALogError("[Spotlight] Deindexing all searchable items error: %@", error.localizedDescription);
        } else {
            MEGALogDebug(@"[Spotlight] All searchable items deindexed");
        }
    }];
}

+ (void)deleteMasterKey {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *masterKeyFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", NSLocalizedString(@"general.security.recoveryKeyFile", @"Name for the recovery key file")]];
    [[NSFileManager defaultManager] mnz_removeItemAtPath:masterKeyFilePath];
}

+ (void)resetUserData {
    [[Helper uploadingNodes] removeAllObjects];
    
    [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
    
    NSUserDefaults *sharedUserDefaults = [NSUserDefaults.alloc initWithSuiteName:MEGAGroupIdentifier];
    [sharedUserDefaults removePersistentDomainForName:MEGAGroupIdentifier];
    
    // This key is to check if the app has been reinstalled. Don't remove it when logging out
    [self markAppAsLaunched];
}

+ (void)deletePasscode {
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        if (LTHPasscodeViewController.sharedUser.isLockscreenPresent) {
            [LTHPasscodeViewController deletePasscodeAndClose];
        } else {
            [LTHPasscodeViewController deletePasscode];
        }
    }
}

+ (void)showExportMasterKeyInView:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *masterKeyFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", NSLocalizedString(@"general.security.recoveryKeyFile", @"Name for the recovery key file")]];
    
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:masterKeyFilePath contents:[[[MEGASdkManager sharedMEGASdk] masterKey] dataUsingEncoding:NSUTF8StringEncoding] attributes:@{NSFileProtectionKey:NSFileProtectionComplete}];
    if (success) {
        UIAlertController *recoveryKeyAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"masterKeyExported", @"Alert title shown when you have exported your MEGA Recovery Key") message:NSLocalizedString(@"masterKeyExported_alertMessage", @"The Recovery Key has been exported into the Offline section as MEGA-RECOVERYKEY.txt. Note: It will be deleted if you log out, please store it in a safe place.")  preferredStyle:UIAlertControllerStyleAlert];
        [recoveryKeyAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MEGASdkManager sharedMEGASdk] masterKeyExported];
            [viewController dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion();
                }
            }];
        }]];
        
        [viewController presentViewController:recoveryKeyAlertController animated:YES completion:nil];
    }
}

+ (void)showMasterKeyCopiedAlert {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[MEGASdkManager sharedMEGASdk] masterKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"recoveryKeyCopiedToClipboard", @"Title of the dialog displayed when copy the user's Recovery Key to the clipboard to be saved or exported - (String as short as possible).") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil]];
    [UIApplication.mnz_presentingViewController presentViewController:alertController animated:YES completion:nil];
    
    [[MEGASdkManager sharedMEGASdk] masterKeyExported];
}

#pragma mark - Log

+ (void)enableOrDisableLog {
    BOOL enableLog = ![[NSUserDefaults standardUserDefaults] boolForKey:@"logging"];
    NSString *alertTitle = enableLog ? NSLocalizedString(@"enableDebugMode_title", @"Alert title shown when the DEBUG mode is enabled") :NSLocalizedString(@"disableDebugMode_title", @"Alert title shown when the DEBUG mode is disabled");
    NSString *alertMessage = enableLog ? NSLocalizedString(@"enableDebugMode_message", @"Alert message shown when the DEBUG mode is enabled") :NSLocalizedString(@"disableDebugMode_message", @"Alert message shown when the DEBUG mode is disabled");
    
    UIAlertController *logAlertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [logAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Button title to cancel something") style:UIAlertActionStyleCancel handler:nil]];
    
    [logAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"Button title to cancel something") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (enableLog) {
#if MAIN_APP_TARGET
            [MEGAChatSdk setLogObject:Logger.shared];
#endif
            [[MEGALogger sharedLogger] preparingForLogging];
        } else {
            [[MEGALogger sharedLogger] stopLogging];
            
#if MAIN_APP_TARGET
            [MEGAChatSdk setLogObject:nil];
            [Logger.shared removeLogsDirectory];
#endif
        }
    }]];
    
    [UIApplication.mnz_presentingViewController presentViewController:logAlertController animated:YES completion:nil];
}

@end
