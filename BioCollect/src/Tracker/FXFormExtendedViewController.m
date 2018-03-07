//
//  FXFormExtendedViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 6/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXFormExtendedViewController.h"

@implementation FXFormExtendedViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    if(self.field.value == nil){
        barButton.enabled = NO;
    }
}

- (void) done {
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.field.value != nil){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
@end
