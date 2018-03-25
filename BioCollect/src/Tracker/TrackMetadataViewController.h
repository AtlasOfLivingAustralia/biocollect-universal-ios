//
//  TrackMetadataViewController.h
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 26/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"
#import "MetadataForm.h"

@interface TrackMetadataViewController : FXFormViewController{
    BOOL showModal;
}
- (instancetype) initWithForm: (MetadataForm*) form;
@end
