//
//  GALogin.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GALogin.h"
#import "GAAppDelegate.h"
#import "MRProgress.h"
#import "GASettings.h"

@interface GALogin ()

@end

@implementation GALogin

@synthesize loginButton, usernameTextField, passwordTextField;

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
    //TODO: Render the webpage under the webview modal.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://auth.ala.org.au/userdetails/registration/createAccount"]];
}

-(void) authenticate {
    // Processing UI indicator on the main thread.
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Time consuming processing on the seperate task
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSError *error = nil;
        NSMutableArray *p = nil;
        NSString *userName = self.usernameTextField.text;
        NSString *password = self.passwordTextField.text;
        
        [appDelegate.restCall  authenticate:userName password:password error:&error];
        if(error == nil) {
            p = [appDelegate.restCall downloadProjects:&error];
            if([p count] > 0) {
                [appDelegate.sqlLite storeProjects : p];
            }
        }
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
                
                //After completing the time consuming task run the UI update back in the main thread.
                //[appDelegate updateTableModelsAndViews:p];
                //Dismiss the login modal
                [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                //[appDelegate.detailVC.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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

/*
-(void)layoutSubviews
{
    DebugLog(@"layoutSubviews called");
    CGRect viewsize=[[UIScreen mainScreen]bounds];
    self.view.frame=CGRectMake(0, 0, 320, viewsize.size.height);
}
*/

@end





















































