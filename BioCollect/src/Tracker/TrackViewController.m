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
    if (isPractise == nil) {
        isPractise = NO;
    }
    
    self = [super init];
    self.delegate = self;
    [_trackForm startRecordingLocation];
    return self;
}

- (instancetype) initWithForm:(MetadataForm*) form {
    _trackForm = form;
    if (isPractise == nil) {
        isPractise = NO;
    }
    
    self = [super init];
    self.delegate = self;
    [_trackForm startRecordingLocation];
    
    return self;
}

- (instancetype) initWithSaveDisabled {
    isPractise = YES;
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
    
    self.trackMetadataViewController = meta;
    self.trackForm = meta.formController.form;
    
    _sighingtListViewController = [SightingListViewController new];
    _sighingtListViewController.animals = self.trackForm.animals;
    _sighingtListViewController.title = [locale get: @"sighting.title"];
    _sighingtListViewController.tabBarItem.image = [UIImage imageNamed:@"icon_dog"];
    [_sighingtListViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Helvetica" size:15.0], NSFontAttributeName, nil]
                                   forState:UIControlStateNormal];

    
    _route = [[RouteViewController alloc] initWithRoute: self.trackForm.route andAnimals: self.trackForm.animals];
    _route.title = [locale get: @"map.title"];
    _route.tabBarItem.image = [UIImage imageNamed: @"icon_track"];
    [_route.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Helvetica" size:15.0], NSFontAttributeName, nil]
                                   forState:UIControlStateNormal];

    
    [self setViewControllers: @[meta, _sighingtListViewController, _route]];
    
    UIBarButtonItem *addAnimal = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAnimal)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:) ];
    centreMap = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(centreMap:)];
    [centreMap setEnabled:NO];
    
    if (isPractise) {
        [save setEnabled:NO];
    }
    
    self.navigationItem.rightBarButtonItems = @[save, camera, addAnimal, centreMap];

    if(!isPractise){
        UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton)];
        self.navigationItem.leftBarButtonItem = back;
    }
    
    // register events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSighting:) name:@"SPECIES-REMOVED" object: nil];
}

- (void) willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [_route stopNotification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event handlers
- (void) cancelButton {
    
    if (!isPractise) {
        GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: [locale get: @"trackmetadata.confirmexit.title"]
                                                                       message: [locale get: @"trackmetadata.confirmexit.message"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* no = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmexit.no"] style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                }];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmexit.yes"] style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                [self.navigationController popViewControllerAnimated:YES];
                                                            }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) addAnimal {
    _sightingVC = [SightingViewController new];
    [self.navigationController pushViewController:_sightingVC animated:YES];
    SpeciesListVC *speciesVC = [[SpeciesListVC alloc] initWithNibName:@"SpeciesListVC" bundle:nil];
    [self.navigationController pushViewController:speciesVC animated:YES];
    
    // Set self to listen for the message "SecondViewControllerDismissed"
    // and run a method when this message is detected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speciesSelected:) name:@"SPECIES_SEARCH_SELECTED" object:nil];
}

- (void) speciesSelected: (NSNotification *) notice {
    
    SightingForm *form = _sightingVC.formController.form;
    form.animal = (Species *)notice.object;
    [_sightingVC.formController.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SPECIES-SIGHTING-SAVED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSighting:) name:@"SPECIES-SIGHTING-SAVED" object:nil];
    
    [self setSelectedIndex:1];
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

- (void) centreMap: (NSNotification *) notice {
    [_route zoomToRoute];
}

- (void) save {
    GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:  [locale get: @"trackmetadata.confirmsave.title"]
                                                                   message: [locale get: @"trackmetadata.confirmsave.message"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* saveAndContinue = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmsave.continue"] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [appDelegate.trackerService addTrack: self.trackForm];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-SAVED" object: nil];
                                                         }];
    
    UIAlertAction* saveAndExit = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmsave.exit"] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             if (self.trackForm.endTime == nil) {
                                                                 self.trackForm.endTime = [NSDate date];
                                                             }

                                                             [_trackForm stopRecordingLocation];
                                                             [_route stopNotification];
                                                             [appDelegate.trackerService addTrack: self.trackForm];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-SAVED" object: nil];
                                                             [self.navigationController popViewControllerAnimated:YES];
                                                         }];
    
    [alert addAction:saveAndContinue];
    [alert addAction:saveAndExit];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)takePhoto:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: [locale get: @"camera.error.title"]
                                                                       message: [locale get: @"camera.error.message"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[locale get: @"camera.error.ok"] style:UIAlertActionStyleDefault
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
    if(viewController == _route){
        [centreMap setEnabled: YES];
    } else {
        [centreMap setEnabled: NO];
    }
}
@end
