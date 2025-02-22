#import "MEGALoginRequestDelegate.h"
#import "SVProgressHUD.h"
#import "MEGA-Swift.h"
#import "InitialLaunchViewController.h"
#import "Helper.h"
#import "NSString+MNZCategory.h"
#import "UIApplication+MNZCategory.h"

@import SAMKeychain;

@interface MEGALoginRequestDelegate ()

@property (nonatomic, getter=hasSession) BOOL session;

@end

@implementation MEGALoginRequestDelegate

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [SAMKeychain passwordForService:@"MEGA" account:@"sessionV3"] ? YES : NO;
    }
    
    return self;
}

#pragma mark - Private

- (NSString *)timeFormatted:(NSUInteger)totalSeconds {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    NSString *currentLanguageID = NSBundle.mainBundle.preferredLocalizations.firstObject;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:currentLanguageID];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:totalSeconds];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - MEGARequestDelegate

- (void)onRequestStart:(MEGASdk *)api request:(MEGARequest *)request {
    if (!self.hasSession) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
    }

}

- (void)onRequestFinish:(MEGASdk *)api request:(MEGARequest *)request error:(MEGAError *)error {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD dismiss];
        
    if (self.confirmAccountInOtherClient) {
        [Helper clearEphemeralSession];
    }
    
    if (error.type) {
        NSString *message;
        switch ([error type]) {
            case MEGAErrorTypeApiEArgs:
            case MEGAErrorTypeApiENoent:
                message = NSLocalizedString(@"invalidMailOrPassword", @"Message shown when the user writes a wrong email or password on login");
                
                // The email or password have been changed in other client while the app requires the 2fa code
                if ((error.type == MEGAErrorTypeApiENoent) && request.text) {
                    if (request.text.mnz_isDecimalNumber) {
                        if (self.errorCompletion) self.errorCompletion(error);
                    }
                }
                break;
                
            case MEGAErrorTypeApiEExpired: {
                if (self.errorCompletion) {
                    self.errorCompletion(error);
                    return;
                } else {
                    message = [NSString stringWithFormat:@"%@ %@", request.requestString, NSLocalizedString(error.name, nil)];
                    break;
                }
            }
                
            case MEGAErrorTypeApiEFailed:
                if (self.errorCompletion) self.errorCompletion(error);
                return;
                
            case MEGAErrorTypeApiETooMany:
                message = [NSString stringWithFormat:NSLocalizedString(@"tooManyAttemptsLogin", @"Error message when to many attempts to login"), [self timeFormatted:3600]];
                break;
                
            case MEGAErrorTypeApiEIncomplete:
                message = NSLocalizedString(@"accountNotConfirmed", @"Text shown just after creating an account to remenber the user what to do to complete the account creation proccess");
                break;
            
            case MEGAErrorTypeApiESid:
            case MEGAErrorTypeApiEBlocked:
                return;
                
            case MEGAErrorTypeApiEMFARequired:
                if (self.errorCompletion) self.errorCompletion(error);
                return;
                
            default:
                message = [NSString stringWithFormat:@"%@ %@", request.requestString, NSLocalizedString(error.name, nil)];
                break;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [UIApplication.mnz_presentingViewController presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    if (!self.hasSession) {
        NSString *session = [api dumpSession];
        [SAMKeychain setPassword:session forService:@"MEGA" account:@"sessionV3"];
        DevicePermissionsHandlerObjC *handler = [[DevicePermissionsHandlerObjC alloc] init];
        [handler shouldSetupPermissionsWithCompletion:^(BOOL shouldSetupPermissions) {
            [MEGALoginRequestDelegate presentLaunchViewController:shouldSetupPermissions];
        }];
    }
}

+ (void)presentLaunchViewController:(BOOL)shouldSetupPermissions{
    NSAssert([NSThread isMainThread], @"must be called on main thread");
    
    LaunchViewController *launchVC;
    if (shouldSetupPermissions) {
        launchVC = [[UIStoryboard storyboardWithName:@"Launch" bundle:nil] instantiateViewControllerWithIdentifier:@"InitialLaunchViewControllerID"];
    } else {
        launchVC = [[UIStoryboard storyboardWithName:@"Launch" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchViewControllerID"];
    }
    
    launchVC.delegate = (id<LaunchViewControllerDelegate>)UIApplication.sharedApplication.delegate;
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = launchVC;
}

@end
