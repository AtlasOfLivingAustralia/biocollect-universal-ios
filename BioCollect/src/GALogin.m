//
//  GALogin.m
//  GreenArmy
//
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
@interface GALogin ()

@end

@implementation GALogin

@synthesize loginButton, usernameTextField, passwordTextField,registerButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
 
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
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
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Time consuming processing on the seperate task
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSError *error = nil;
        NSMutableArray *p = nil;
        NSString *userName = self.usernameTextField.text;
        NSString *password = self.passwordTextField.text;
        
        [appDelegate.restCall  authenticate:userName password:password error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            //Dismiss the ui indicator modal
            [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
            
            // Invalid user name and password
            if(error != nil){
                DebugLog(@"%@",[error localizedDescription]);
                NSString *message = [error localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                self.passwordTextField.text = @"";
                self.usernameTextField.text = @"";
                //Dismiss the login modal
                [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                
                [UIView transitionWithView:appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{ appDelegate.window.rootViewController = appDelegate.tabBarController; }
                                completion:nil];
            }
        });
    });
}

#pragma mark - Text field delegate handler.

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameTextField){
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    if(textField == self.passwordTextField){
        [textField resignFirstResponder];
        [self authenticate];
    }
    
    return TRUE;
}

-(void) logout {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message:@"Are you sure you want to logout?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [alert show];
}

#pragma mark - UIAlert view delegate.

- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    if( buttonIndex != 0 ) {
        [appDelegate displaySigninPage];
    }
}

@end





















































