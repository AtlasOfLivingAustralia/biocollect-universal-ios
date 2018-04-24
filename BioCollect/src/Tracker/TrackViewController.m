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
    [_trackForm loadImages];
    isTrackCreatedFromLocalStorage = NO;
    if (isPractise == nil) {
        isPractise = NO;
    }
    
    self = [super init];
    self.delegate = self;
    [_trackForm startRecordingLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedProject:) name:@"PROJECT-UPDATED" object:nil];
    return self;
}

- (instancetype) initWithForm:(MetadataForm*) form {
    _trackForm = form;
    [_trackForm loadImages];
    isTrackCreatedFromLocalStorage = YES;
    if (isPractise == nil) {
        isPractise = NO;
    }
    
    self = [super init];
    self.delegate = self;
    [_trackForm stopRecordingLocation];
    
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
    _sighingtListViewController.tabBarItem.image = [UIImage imageNamed:@"icon_lizards"];
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
        UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithTitle:[locale get:@"trackviewcontroller.button.back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButton)];
        self.navigationItem.leftBarButtonItem = back;
        
        [self startTimer];
    }
    
    // gesture
    UISwipeGestureRecognizer *leftToRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftToRightSwipe)];
    leftToRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [leftToRightGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:leftToRightGesture];
    
    UISwipeGestureRecognizer *rightToLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightToLeftSwipe)];
    rightToLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [rightToLeftGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:rightToLeftGesture];
    
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
        if(isTrackCreatedFromLocalStorage){
            [self saveAndExitAction];
        } else {
            [self showExitAlertWithDeleteOption];
        }
    } else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) showExitAlertWithDeleteOption {
    GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle: [locale get: @"trackmetadata.confirmexit.title"]
                                                                   message: [locale get: @"trackmetadata.confirmexit.message"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* no = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmexit.no"] style:UIAlertActionStyleDefault
                                               handler:nil];
    
    UIAlertAction* yes = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmexit.yes"] style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [self performBeforeExitRoutine];
                                                    [self deleteTrack];
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteTrack {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.trackerService removeTrack: self.trackForm];
        [self performCleanUp];
    });
}

- (void) addAnimal {
    _sightingVC = [SightingViewController new];
    [self.navigationController pushViewController:_sightingVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSighting:) name:@"SPECIES-SIGHTING-SAVED" object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SPECIES-SIGHTING-SAVED" object:nil];
    [self setSelectedIndex:1];

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
    
    NSString* message = isTrackCreatedFromLocalStorage ? [locale get: @"trackmetadata.confirmsave.message.gotolist"] : [locale get: @"trackmetadata.confirmsave.message"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:  [locale get: @"trackmetadata.confirmsave.title"]
                                                                   message: message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* saveAndContinue = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmsave.continue"] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self saveAndContinue];
                                                         }];
    
    UIAlertAction* saveAndExit = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.confirmsave.exit"] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self saveAndExitAction];
                                                         }];
    
    [alert addAction:saveAndContinue];
    [alert addAction:saveAndExit];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void) saveAndContinue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.trackerService addTrack: self.trackForm];
    });
}

- (void) saveAndExitAction {
    GAAppDelegate * appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self performBeforeExitRoutine];
    [self fillEndTime];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-SAVED" object: nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_trackForm save];
        [appDelegate.trackerService addTrack: self.trackForm];
        [self performCleanUp];
    });
}

- (void) fillEndTime {
    if (self.trackForm.endTime == nil) {
        self.trackForm.endTime = [NSDate date];
    }
}

- (void) performBeforeExitRoutine {
    [self stopTimer];
    [_trackForm stopRecordingLocation];
    [_route stopNotification];
}

- (void) performCleanUp {
    _sightingVC = nil;
    self.sighingtListViewController = nil;
    self.route = nil;
    self.trackMetadataViewController = nil;
    self.trackForm = nil;
    self.delegate = nil;
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
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void) updatedProject: (NSNotification *) notification {
    _trackForm.organisationName = notification.object;
    [_trackMetadataViewController.tableView reloadData];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// gesture handlers
- (void) leftToRightSwipe {
    [self selectPreviousViewController];
}

- (void) rightToLeftSwipe {
    [self selectNextViewController];
}

#pragma mark - helper functions
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self updateTabControllerUI];
}

- (void) updateTabControllerUI {
    self.title = self.selectedViewController.title;
    if(self.selectedViewController == _route){
        [centreMap setEnabled: YES];
    } else {
        [centreMap setEnabled: NO];
    }
}

- (void) selectNextViewController {
    if ([self canSelectNextViewController]) {
        NSUInteger index = self.selectedIndex + 1;
        // Get views. controllerIndex is passed in as the controller we want to go to.
        UIView * fromView = self.selectedViewController.view;
        UIView * toView = [self.viewControllers objectAtIndex:index].view;
        
        // Transition using a page curl.
        [UIView transitionFromView:fromView
                            toView:toView
                          duration:0.5
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            if (finished) {
                                self.selectedIndex = index;
                                [self updateTabControllerUI];
                            }
                        }];
    }
}

- (BOOL) canSelectNextViewController {
    if ((self.selectedIndex + 1) < [self.viewControllers count]) {
        return YES;
    }
    
    return NO;
}

- (void) selectPreviousViewController {
    if ([self canSelectPreviousViewController]) {
        NSUInteger index  = self.selectedIndex - 1;
        // Get views. controllerIndex is passed in as the controller we want to go to.
        UIView * fromView = self.selectedViewController.view;
        UIView * toView = [self.viewControllers objectAtIndex:index].view;
        
        // Transition using a page curl.
        [UIView transitionFromView:fromView
                            toView:toView
                          duration:0.5
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            if (finished) {
                                self.selectedIndex = index;
                                [self updateTabControllerUI];
                            }
                        }];
    }
}

- (BOOL) canSelectPreviousViewController {
    if (self.selectedIndex > 0) {
        return YES;
    }
    
    return NO;
}

- (void) stopTimer {
    [timer invalidate];
    timer = nil;
}

- (void) startTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(saveAndContinue) userInfo:nil repeats:YES];
}

@end
