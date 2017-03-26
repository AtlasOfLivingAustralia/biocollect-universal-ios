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

@implementation OzHomeVCDataSource


#pragma mark - MGSpotyViewControllerDataSource

- (NSInteger)spotyViewController:(MGSpotyViewController *)spotyViewController
           numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
        
        /*
        UIView *stroke = [[UIView alloc] init];
        stroke.backgroundColor = [UIColor grayColor];
        stroke.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:stroke];
        NSDictionary *views = NSDictionaryOfVariableBindings(stroke);
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[stroke(1)]|" options:0 metrics:nil views:views]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stroke]|" options:0 metrics:nil views:views]];
       */  
    }
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Record a sightings";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"nochange"]];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"All sightings";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"nochange"]];
    }
    else if(indexPath.row == 2) {
        cell.textLabel.text = @"My sightings";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"nochange"]];
    } else if(indexPath.row == 3) {
        cell.textLabel.text = @"Explore species by location";
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", @""];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", @""];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"loc1_changed"]];
    } else if(indexPath.row == 4) {
        cell.textLabel.text = @"Synchornise records on disk";
        cell.detailTextLabel.text = @"";
        [cell.imageView setImage:[UIImage imageNamed:@"nochange"]];
    }
    
    return cell;
}

@end
