//
//  TrackViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 23/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "TrackViewController.h"
#import "RouteViewController.h"
#import "TrackMetadataViewController.h"
#import "SightingViewController.h"
#import "SightingListViewController.h"
#import "GAAppDelegate.h"
#import "MetadataForm.h"
#import "SpeciesListVC.h"
#import "Species.h"
#import "SightingForm.h"

@implementation TrackViewController
- (instancetype) init {
    _trackForm = [MetadataForm new];
    if (disableSaveButton == nil) {
        disableSaveButton = NO;
    }
    
    self = [super init];
    [_trackForm startRecordingLocation];
    return self;
}

- (instancetype) initWithForm:(MetadataForm*) form {
    _trackForm = form;
    if (disableSaveButton == nil) {
        disableSaveButton = NO;
    }
    
    self = [super init];
    return self;
}

- (instancetype) initWithSaveDisabled {
    disableSaveButton = YES;
    self = [self init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    self.title = [locale get: @"trackviewcontroller.title"];
    
    TrackMetadataViewController *meta = [[TrackMetadataViewController alloc] initWithForm:self.trackForm];
    meta.title = [locale get: @"trackmetadataviewcontroller.title"];
    meta.tabBarItem.image = [UIImage imageNamed:@"icon_page_edit"];
    [meta.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont fontWithName:@"Helvetica" size:15.0], NSFontAttributeName, nil]
                                  forState:UIControlStateNormal];
    
    self.trackForm = meta.formController.form;
    
    _sighingtListViewController = [SightingListViewController new];
    _sighingtListViewController.animals = self.trackForm.animals;
    _sighingtListViewController.title = [locale get: @"sighting.title"];
    _sighingtListViewController.tabBarItem.image = [UIImage imageNamed:@"icon_dog"];
    [_sighingtListViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Helvetica" size:15.0], NSFontAttributeName, nil]
                                   forState:UIControlStateNormal];

    
    _route = [[RouteViewController alloc] initWithRoute: self.trackForm.route andAnimals: self.trackForm.animals];
    _route.tabBarItem.title = [locale get: @"map.title"];
    _route.tabBarItem.image = [UIImage imageNamed: @"icon_track"];
    [_route.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Helvetica" size:15.0], NSFontAttributeName, nil]
                                   forState:UIControlStateNormal];

    
    [self setViewControllers: @[meta, _sighingtListViewController, _route]];
    
    UIBarButtonItem *addAnimal = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAnimal)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:[locale get: @"trackmetadata.save"] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
        UIImage *image = [UIImage imageNamed: @"icon_camera"];
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithImage: image style:nil target:self action:@selector(takePhoto:) ];
    
    if (disableSaveButton) {
        [save setEnabled:NO];
    }
    
    self.navigationItem.rightBarButtonItems = @[save, camera, addAnimal];
    
    // register events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSighting:) name:@"SPECIES-REMOVED" object: nil];
}

- (void) willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [_route stopTimerNotification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event handlers
- (void) addAnimal {
    SpeciesListVC *speciesVC = [[SpeciesListVC alloc] initWithNibName:@"SpeciesListVC" bundle:nil];
    [self.navigationController pushViewController:speciesVC animated:YES];
    
    // Set self to listen for the message "SecondViewControllerDismissed"
    // and run a method when this message is detected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speciesSelected:) name:@"SPECIES_SEARCH_SELECTED" object:nil];
}

- (void) speciesSelected: (NSNotification *) notice {
    SightingViewController *sighting = [SightingViewController new];
    SightingForm *form = sighting.formController.form;
    form.animal = (Species *)notice.object;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SPECIES-SIGHTING-SAVED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSighting:) name:@"SPECIES-SIGHTING-SAVED" object:nil];
    
    [self setSelectedIndex:1];
    [self.navigationController pushViewController:sighting animated:NO];
}


- (void) addSighting: (NSNotification *) notice {
    // remove previous notification registration
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SPECIES_SEARCH_SELECTED" object:nil];

    SightingForm *form = (SightingForm *)notice.object;
    
    if (form != nil) {
        NSUInteger index = [self.trackForm.animals indexOfObject:form];
        
        if (index == NSNotFound) {
            [self.trackForm.animals addObject:form];
            [_sighingtListViewController.tableView reloadData];
            [_route addAnnotations];
        }
    }
}

- (void) removeSighting: (NSNotification *) notice {
    SightingForm *sighting = notice.object;
    [_route removeAnnotation: sighting];
}

- (void) save {
    GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Save track?"
                                                                   message: @"Do you want to save and continue working on this track?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* saveAndContinue = [UIAlertAction actionWithTitle: @"Save & continue" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [appDelegate.trackerService addTrack: self.trackForm];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-SAVED" object: nil];
                                                         }];
    
    UIAlertAction* saveAndExit = [UIAlertAction actionWithTitle: @"Save & exit" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [appDelegate.trackerService addTrack: self.trackForm];
                                                             [self.navigationController popViewControllerAnimated:YES];
                                                             [_trackForm stopRecordingLocation];
                                                             [_route stopTimerNotification];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-SAVED" object: nil];
                                                         }];
    
    [alert addAction:saveAndContinue];
    [alert addAction:saveAndExit];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)takePhoto:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Error"
                                                                       message: @"Device has no camera"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *img = info[UIImagePickerControllerEditedImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    [picker dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - helper functions
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
}
@end
