//
//  FXFormLargeImagePickerCell.m
//  BioCollect
//
//  Created by Varghese, Temi (PI, Black Mountain) on 17/4/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXFormLargeImagePickerCell.h"
#import "FXForms.h"

static const CGFloat FXFormFieldLabelSpacing = 5;
static const CGFloat FXFormFieldMinLabelWidth = 97;
static const CGFloat FXFormFieldMaxLabelWidth = 240;
static const CGFloat FXFormFieldMinFontSize = 12;
static const CGFloat FXFormFieldPaddingLeft = 10;
static const CGFloat FXFormFieldPaddingRight = 10;
static const CGFloat FXFormFieldPaddingTop = 12;
static const CGFloat FXFormFieldPaddingBottom = 12;
static const CGFloat FXFormFieldImageHeight = 400;

@implementation FXFormLargeImagePickerCell
+ (CGFloat)heightForField:(FXFormField *)field width:(CGFloat)width
{
    CGFloat height = [field.title length]? 21: 0; // label height
    height += FXFormFieldPaddingTop + FXFormFieldImageHeight + FXFormFieldPaddingBottom + FXFormFieldLabelSpacing;
    return height;
}

- (void) setUp {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    double width = self.contentView.bounds.size.width - FXFormFieldPaddingLeft - FXFormFieldPaddingRight;
    imagePickerView = [[UIImageView alloc] initWithFrame:CGRectMake(FXFormFieldPaddingLeft, 44, width, FXFormFieldImageHeight)];
    //    imagePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    imagePickerView.contentMode = UIViewContentModeScaleAspectFit;
    imagePickerView.clipsToBounds = YES;
    [self.contentView addSubview:imagePickerView];
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect labelFrame = self.textLabel.frame;
    labelFrame.origin.y = FXFormFieldPaddingTop;
    labelFrame.size.width = MIN(MAX([self.textLabel sizeThatFits:CGSizeZero].width, FXFormFieldMinLabelWidth), FXFormFieldMaxLabelWidth);
    self.textLabel.frame = labelFrame;
    
    CGRect imageViewFrame = imagePickerView.frame;
    imageViewFrame.origin.x = FXFormFieldPaddingLeft;
    imageViewFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height + FXFormFieldLabelSpacing;
    imageViewFrame.size.width = self.contentView.bounds.size.width - FXFormFieldPaddingLeft - FXFormFieldPaddingRight;
    imageViewFrame.size.height = FXFormFieldImageHeight;
    if (![self.textLabel.text length])
    {
        imageViewFrame.origin.y = self.textLabel.frame.origin.y;
    }
    
    imagePickerView.frame = imageViewFrame;
    
    CGRect contentViewFrame = self.contentView.frame;
    CGRect bounds = self.contentView.bounds;
    contentViewFrame.size.height = imagePickerView.frame.origin.y + imagePickerView.frame.size.height + FXFormFieldPaddingBottom;
    bounds.size.height = contentViewFrame.size.height;
    self.contentView.frame = contentViewFrame;
}

- (UIImageView *)imagePickerView
{
    return (UIImageView *) imagePickerView;
}
@end
