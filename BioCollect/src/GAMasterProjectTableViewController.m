//
//  GAMasterProjectViewController.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAMasterProjectTableViewController.h"
#import "GADetailActivitiesTableViewController.h"
#import "GAProject.h"
#import "MRProgress.h"
#import "GASettings.h"

@interface GAMasterProjectTableViewController (){
    NSMutableArray *_objects;
}
@end


@implementation GAMasterProjectTableViewController
@synthesize detailFormViewController, projects,version;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.title = NSLocalizedString(@"Green Army", @"Green Army");
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heading"]];
        self.clearsSelectionOnViewWillAppear = YES;
        self.projects = [[NSMutableArray alloc]init];
        NSString * ver = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        version = [[NSString alloc] initWithFormat:@"App version - %@ (%@)",ver,build];
    }
   // [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:114.0/255.0 green:169.0/255.0 blue:81.0/255.0 alpha:1]];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - upload button selector

#pragma mark = GARestCall delegate.

-(void) bk_closeModal :(id) object{
    [NSThread sleepForTimeInterval:1.0];
     GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [MRProgressOverlayView dismissAllOverlaysForView:appDelegate.window animated:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
}

-(void) updateProjectTableModel : (NSMutableArray *) p{
    [self.projects removeAllObjects];
    [self.projects addObjectsFromArray:p];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    if(section == 0) {
        return [self.projects count];
    }
    else{
        return 1;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"My Projects";
    else{
        return @"Info";
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if(indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if([self.projects count] > 0) {
            GAProject *project = [self.projects objectAtIndex:indexPath.row];
            cell.textLabel.text = project.projectName;
            cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",project.description];
        }
        cell.imageView.image = [UIImage imageNamed:@"pad"];
    }
    else{
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",[GASettings getEmailAddress]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = version;
        cell.imageView.image = [UIImage imageNamed:@"profile"];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:
         UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into
        //the array, and add a new row to the table view.
    }
}
*/
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:
 (NSIndexPath *) fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:
 (NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.section == 0){
       [self.detailFormViewController setSelectedProjectIndex : (int)indexPath.row];
    }
}

@end