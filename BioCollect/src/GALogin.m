//
//  GALogin.m

//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GALogin.h"
#import "GAAppDelegate.h"
#import "MRProgress.h"
#import "GASettings.h"
#import "GASettingsConstant.h"
#import "MRProgressOverlayView.h"
#import "SVModalWebViewController.h"
#import "RKDropdownAlert.h"

@interface GALogin ()
@property (nonatomic, strong) GAAppDelegate* appDelegate;
@end

@implementation GALogin

@synthesize loginButton, registerButton, logoImageView, appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (self) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[GASettings appLoginImage]]]];
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [self.logoImageView setImage:[UIImage imageNamed: [GASettings appLoginLogo]]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickLogin:(id)sender {
    [self authenticate];
}
- (IBAction)onClickRegister:(id)sender{
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@", AUTH_SERVER, AUTH_REGISTER];
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
    webViewController.title = @"Register";
    [self presentViewController:webViewController animated:YES completion:NULL];
}

-(void) authenticate {
    // Processing UI indicator on the main thread.
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];

    NSString *url = [[NSString alloc] initWithFormat:@"%@%@", AUTH_SERVER, AUTH_DISCOVERY];
    NSURL *issuer = [NSURL URLWithString:url];
    
    // Fetch the OIDC discovery document
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
        [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
        if (!configuration) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        
        
        // Create the request object
        OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:CLIENT_ID
                                                        scopes:@[OIDScopeOpenID, OIDScopeProfile]
                                                   redirectURL:[NSURL URLWithString:AUTH_REDIRECT]
                                                  responseType:OIDResponseTypeCode
                                          additionalParameters:nil];
        
        // Make the authorization request
        appDelegate.currentAuthorizationFlow =
        [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                       presentingViewController: self callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
            // If the authentication was successful
            if (authState) {
                // Create a dictionary from the token rseponse
                NSDictionary *credsDict = [[NSDictionary alloc] initWithObjectsAndKeys:authState.lastTokenResponse.accessToken, @"access_token", authState.lastTokenResponse.idToken, @"id_token", authState.lastTokenResponse.tokenType, @"token_type", authState.lastTokenResponse.refreshToken, @"refresh_token", nil];
                [GASettings setCredentials: credsDict];
                
                // Dismiss the login modal
                [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                NSString *appType = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_AppType"];
                [UIView transitionWithView:appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{ appDelegate.window.rootViewController = appDelegate.ozHomeNC; }
                                completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                                message:[error localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
                [alert show];
                
                // Dismiss the ui indicator modal
                [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
            }
        }];
    }];
}

-(void) logout {
    NSLog(@"Logging out!");
    [self logoutWithErrorMsg:@""];
}

-(void) logoutWithErrorMsg :(NSString *) errorMsg {
    Locale* locale = appDelegate.locale;
    
    if([[appDelegate restCall] notReachable]) {
        [RKDropdownAlert title:[locale get: @"menu.logout.offline.title"] message:[locale get: @"menu.logout.offline.message"] backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
        return;
    }
    
    if([[GASettings appHubName] isEqualToString:@"trackshub"]) {
        NSInteger size = [[appDelegate trackerService].tracks count];
        if(size > 0) {
            [RKDropdownAlert title:[locale get: @"menu.logout.pendingTracks.title"] message:[locale get: @"menu.logout.pendingTracks"] backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[locale get: @"menu.logout.title"]
                                                        message:[NSString stringWithFormat:[locale get: @"menu.logout.passwordMessage"],
                                                                 [GASettings getEmailAddress],errorMsg]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
        [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [alert show];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [locale get: @"menu.logout.title"]
                                                        message:[locale get: @"menu.logout.genericMessage"]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
        [alert show];
    }
}

#pragma mark - UIAlert view delegate
- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    Locale* locale = appDelegate.locale;
    if( buttonIndex != 0 ) {
        if([[GASettings appHubName] isEqualToString:@"trackshub"]) {
            NSString *password = [actionSheet textFieldAtIndex:0].text;
            if([password length] > 0) {
                // Run this in a background
                [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error = nil;
                    // [appDelegate.restCall  authenticate:[GASettings getEmailAddress] password: password error:&error];
                    // Execute under UI thread.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
                        if(error != nil) {
                            [self logoutWithErrorMsg: [locale get: @"menu.logout.errorMsg"]];
                        } else {
                            [appDelegate displaySigninPage];
                        }
                    });
                });
            } else {
                [self logoutWithErrorMsg:[locale get: @"menu.logout.errorMsg"]];
            }
        } else {
            [appDelegate displaySigninPage];
        }
    }
}
@end
