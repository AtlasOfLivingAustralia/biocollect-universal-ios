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

OIDEndSessionRequest *request;
OIDExternalUserAgentIOS *agent;

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
    
    [loginButton setEnabled:false];
    [loginButton setAlpha:0.4];

    NSString *url = COGNITO_ENABLED ?
    [[NSString alloc] initWithFormat:@"https://cognito-idp.%@.amazonaws.com/%@_%@", COGNITO_REGION, COGNITO_REGION, COGNITO_USER_POOL] :
    [[NSString alloc] initWithFormat:@"%@%@", AUTH_SERVER, @"/cas/oidc"];
    NSLog(@"%@", url);
    NSURL *issuer = [NSURL URLWithString:url];

    // Fetch the OIDC discovery document
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
        if (!configuration) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSLog(@"%@", [configuration.authorizationEndpoint absoluteString]);
        [GASettings setOpenIDConfig:configuration];
        [loginButton setEnabled:true];
        [loginButton setAlpha:1];
        NSLog(@"OpenID Discovery Successful!");
    }];
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
    // Retrieve the OpenID configuration
    OIDServiceConfiguration *configuration = [GASettings getOpenIDConfig];
    NSString *bundleId = [[[NSBundle mainBundle] bundleIdentifier] stringByReplacingOccurrencesOfString:@".testing" withString:@""];
    NSArray *bundleParts = [bundleId componentsSeparatedByString:@"."];
    NSString *bundleName = [bundleParts lastObject];
    
    // Fix bundleName for bilbyblitz app
    if ([bundleName isEqualToString:@"tracker"]) {
        bundleName = @"bilbyblitz";
    }
    
    NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", bundleName, @"://signin"]];
    NSLog(@"REDIRECT URL %@", redirectURL.absoluteString);
    
    // Create the login request object
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:CLIENT_ID
                                                    scopes:nil
                                               redirectURL:redirectURL
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];
    
    NSLog(@"%@", [request authorizationRequestURL]);

    // Make the authorization request
    appDelegate.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                   presentingViewController: self callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
        // If the authentication was successful
        if (authState) {
            // Create a dictionary from the token rseponse
            [GASettings setAuthState:authState];

            // Dismiss the login modal
            [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];

            [UIView transitionWithView:appDelegate.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{ appDelegate.window.rootViewController = appDelegate.ozHomeNC; }
                            completion:nil];
        } else {
            // Only display non-generic authenitcation errors
            if (error.code != -3) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Authentication Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:dismissAction];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
            }
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void) logout {
    [self logoutWithErrorMsg:@""];
}

-(void) logoutWithErrorMsg :(NSString *) errorMsg {
    Locale* locale = appDelegate.locale;
    
    if([[appDelegate restCall] notReachable]) {
        [RKDropdownAlert title:[locale get: @"menu.logout.offline.title"] message:[locale get: @"menu.logout.offline.message"] backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
        return;
    }
    

    UIAlertController *alertController = [UIAlertController
      alertControllerWithTitle:[locale get: @"menu.logout.title"]
      message:[locale get: @"menu.logout.genericMessage"]
      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noAction = [UIAlertAction
      actionWithTitle:@"No"
      style:UIAlertActionStyleCancel
      handler:nil];

    UIAlertAction *yesAction = [UIAlertAction
      actionWithTitle:@"Yes"
      style:UIAlertActionStyleDefault
      handler:^(UIAlertAction *action) {
        [self performLogout];
      }];

    [alertController addAction:noAction];
    [alertController addAction:yesAction];

    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)performLogout {
    // Retrieve the OpenID discovery document & auth state
    OIDServiceConfiguration *configuration = [GASettings getOpenIDConfig];
    OIDAuthState *authState = [GASettings getAuthState];
    
    NSString *bundleId = [[[NSBundle mainBundle] bundleIdentifier] stringByReplacingOccurrencesOfString:@".testing" withString:@""];
    NSArray *bundleParts = [bundleId componentsSeparatedByString:@"."];
    NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [bundleParts lastObject], @"://signout"]];
    
    // Build the end session request params
    NSDictionary *additionalParameters = [[NSDictionary alloc] initWithObjectsAndKeys:CLIENT_ID, @"client_id", redirectURL.absoluteString, @"logout_uri", nil];
    
    // Create & assign the request and agent
    request = [[OIDEndSessionRequest alloc] initWithConfiguration:configuration idTokenHint:authState.lastTokenResponse.idToken postLogoutRedirectURL:redirectURL
        additionalParameters:additionalParameters];
    agent = [[OIDExternalUserAgentIOS alloc] initWithPresentingViewController:appDelegate.ozHomeNC];
    
    if (COGNITO_ENABLED) {
        [request setValue:nil forKey:@"state"];
    }
    
    // Make the endSession request
    appDelegate.currentAuthorizationFlow = [OIDAuthorizationService presentEndSessionRequest:request externalUserAgent:agent callback:^(OIDEndSessionResponse * _Nullable endSessionResponse, NSError * _Nullable error) {
        if (endSessionResponse || !COGNITO_ENABLED) {
            [appDelegate displaySigninPage];
        } else if (error && error.code != -3) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout Error"
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:nil];
            [alert addAction:dismissAction];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
}
@end
