//
//  SyncTableViewController.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 28/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "SyncTableViewController.h"
#import "RecordForm.h"
#import "GAAppDelegate.h"
#import "RecordViewController.h"

@interface SyncTableViewController ()
@property(strong, nonatomic) UIImage * noImage;
@end

@implementation SyncTableViewController

#define CELL_IDENTIFIER @"recordcell";
@synthesize displayItems;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
        // sync button
        UIBarButtonItem *btnSync = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnSyncPressed)];
        self.navigationItem.rightBarButtonItem = btnSync;
        
        // load data
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        displayItems = appDelegate.records;
        
        //settings
        self.cellIdentifier = @"recordcell";
        if(self.noImage == nil){
            self.noImage = [UIImage imageNamed:@"table-place-holder"];
        }
        
        // table view display settings
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.projectsModified){
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [displayItems count];
}

- (void)btnSyncPressed{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableDictionary *respDict;
            NSMutableArray *recordsToRemove = [[NSMutableArray alloc]init];
            for(RecordForm *record in self.displayItems){
                respDict = [appDelegate.restCall createRecord: record];
                if([respDict[@"status"] isEqualToNumber: [NSNumber numberWithInt: 200]]){
                    [recordsToRemove addObject:record];
                }
            }
            
            [appDelegate removeRecords: recordsToRemove];
            [self.tableView reloadData];
            
            if([self.displayItems count] > 0){
                [[[UIAlertView alloc] initWithTitle:@"Record not synchronised"
                                            message:[NSString stringWithFormat:@"%d records could not be synchronised."]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
    
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Records synchronisation successful"
                                            message:@"All records are now saved on server."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
        });
    });
}

#pragma mark - Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:self.cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RecordForm *record = displayItems[indexPath.row];
    cell.textLabel.text = record.speciesDisplayName;
    cell.detailTextLabel.text = [record getSubtitle];
    if(record.speciesPhoto){
        cell.imageView.image = record.speciesPhoto;
    } else {
        cell.imageView.image = self.noImage;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordForm *record = displayItems[indexPath.row];
    if(record){
        RecordViewController * recVC = [[RecordViewController alloc] init];
        [recVC setRecord: record];
        [self.navigationController pushViewController:recVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        RecordForm *record = displayItems[indexPath.row];
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate removeRecords:@[record]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
