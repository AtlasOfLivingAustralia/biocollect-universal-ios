//
//  GALogin.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GALogin : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *registerButton;
@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;

- (IBAction)onClickLogin:(id)sender;
- (IBAction)onClickRegister:(id)sender;
- (void) logout;
- (void) logoutWithErrorMsg:(NSString *) msg;
@end
