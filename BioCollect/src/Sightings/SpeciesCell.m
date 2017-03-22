//
//  SpeciesCell.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 25/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
// http://www.wrichards.com/blog/2011/11/sdwebimage-fixed-width-cell-images/

#import "SpeciesCell.h"

@implementation SpeciesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5,5,55,55);
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(70,self.textLabel.frame.origin.y,self.frame.size.width - 110,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(70,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
}

@end
