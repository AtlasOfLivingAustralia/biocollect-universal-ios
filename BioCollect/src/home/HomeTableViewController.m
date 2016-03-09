//
//  HomeTableViewController.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 3/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeTableViewController.h"
#import "HomeCustomCell.h"
#import "HomeWebView.h"

@implementation HomeTableViewController
@synthesize  bioProjects, appDelegate, bioProjectService, totalProjects, offset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Load project
    self.bioProjects = [[NSMutableArray alloc]init];
    NSError *error = nil;
    self.offset = 0;
    NSInteger max = 1;
    self.totalProjects = [self.bioProjectService getBioProjects: bioProjects offset:self.offset max:max error:&error];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSUInteger retValue = 0;
    if(self.bioProjects != nil){
        retValue = [self.bioProjects count];
    }
    return retValue;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Projects";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    HomeCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HomeCustomCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if([self.bioProjects count] > 0) {
        GAProject *project = [self.bioProjects objectAtIndex:indexPath.row];
        cell.textLabel.text = project.projectName;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", project.description];

        NSString *url = [[NSString alloc] initWithFormat: @"%@", project.urlImage];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString]
                          placeholderImage:[UIImage imageNamed:@"icon-placeholder.png"]];

    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        //Show next level depth.
        HomeWebView *homeWebView = [[HomeWebView alloc] initWithNibName:@"HomeWebView" bundle:nil];
        homeWebView.project =  [self.bioProjects objectAtIndex:indexPath.row];
      
        if(homeWebView.project && homeWebView.project.isExternal && ![homeWebView.project.urlWeb isEqual: [NSNull null]]) {
            homeWebView.title = homeWebView.project.projectName;
            [homeWebView.webView setScalesPageToFit:YES];
            [[self navigationController] pushViewController:homeWebView animated:TRUE];
            
        } else if(homeWebView.project && !homeWebView.project.isExternal) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                            message:@"Internal Project"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else if(homeWebView.project && homeWebView.project.isExternal && [homeWebView.project.urlWeb isEqual: [NSNull null]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                            message:@"Project external web link not available"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Invalid Project"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        //Add loading message.
        self.offset = self.offset + 1;
        NSInteger max = 1;
        NSError *error = nil;
        self.totalProjects = [self.bioProjectService getBioProjects: bioProjects offset:self.offset max:max error:&error];
        [self.tableView reloadData];
    }
}


@end