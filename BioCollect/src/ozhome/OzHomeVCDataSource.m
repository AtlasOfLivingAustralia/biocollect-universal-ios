//
//  OzHomeVCDataSource.m
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 14/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "OzHomeVCDataSource.h"
#import "MGSpotyViewController.h"
#import "HomeCustomCell.h"
#import "GAAppDelegate.h"
#import "GASettings.h"

@implementation OzHomeVCDataSource


#pragma mark - MGSpotyViewControllerDataSource

- (NSInteger)spotyViewController:(MGSpotyViewController *)spotyViewController
           numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)spotyViewController:(MGSpotyViewController *)spotyViewController
                               tableView:(UITableView *)tableView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Record a Sighting";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"icon_camera"]];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Explore Species";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"icon_location"]];
    }
    else if(indexPath.row == 2) {
        cell.textLabel.text = @"My Sightings";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"icon_my_records"]];
    } else if(indexPath.row == 3) {
        cell.textLabel.text = @"All Sightings";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"icon_all_records"]];
    } else if(indexPath.row == 4) {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate.records count] > 0) {
            cell.textLabel.text = [[NSString alloc] initWithFormat: @"Drafts - %ld records",[appDelegate.records count]];
        } else {
            cell.textLabel.text = @"Draft Sightings";
        }
        
        [cell.imageView setImage:[UIImage imageNamed:@"icon_draft"]];
    } else if(indexPath.row == 5) {
        cell.textLabel.text = @"About the ALA";
        cell.detailTextLabel.text = @"";
        [cell.imageView setImage:[UIImage imageNamed:@"icon_about"]];
    } else if(indexPath.row == 6) {
        cell.textLabel.text = @"Contact the ALA";
        cell.detailTextLabel.text = @"";
        [cell.imageView setImage:[UIImage imageNamed:@"icon_address"]];
    } else if(indexPath.row == 7) {
        cell.textLabel.text = [GASettings appVersion];
        cell.detailTextLabel.text = @"";
        [cell.imageView setImage:[UIImage imageNamed:@"icon_version"]];
    } else {
        cell.textLabel.text = @"About";
        cell.detailTextLabel.text = @"";
        [cell.imageView setImage:[UIImage imageNamed:@"icon_draft"]];
    }
    
    return cell;
}

@end
