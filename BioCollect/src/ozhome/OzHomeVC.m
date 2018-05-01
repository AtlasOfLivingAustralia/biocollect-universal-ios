//
//  OzHomeVC.m
//  Oz Atlas

#import "OzHomeVC.h"
#import "MGSpotyViewControllerDelegate.h"
#import "GAAppDelegate.h"
#import "GASettings.h"
#import "OzHomeVCDelegate.h"
#import "OzHomeVCDataSource.h"
#import "RecordViewController.h"

@interface OzHomeVC ()
@property(strong, nonatomic) UILabel *lblTitle;
@end

@implementation OzHomeVC {
    OzHomeVCDelegate *delegate_;
    OzHomeVCDataSource *dataSource_;
}

- (instancetype)initWithMainImage:(UIImage *)image
{
    self = [super initWithMainImage:image tableScrollingType:MGSpotyViewTableScrollingTypeNormal]; //or MGSpotyViewTableScrollingTypeOver
    if (self) {
        dataSource_ = [OzHomeVCDataSource new];
        delegate_ = [OzHomeVCDelegate new];
        
        self.overViewUpFadeOut = YES;
        self.blurRadius = 8.f;
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated {
    [self updateGreetingsLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = dataSource_;
    self.delegate = delegate_;
    [self navigationController].delegate = self;
    //[self.navigationController setNavigationBarHidden:TRUE];
    [self setOverView:self.myOverView];
    
   
}

- (UIView *)myOverView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.overView.frame.size.width, 250)];
    [self mg_addElementOnView:view];
    return view;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController == self)
    {
        if( ![self navigationController].navigationBarHidden)
        {
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
        }
    }
    else
    {
        if([self navigationController].navigationBarHidden)
        {
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Private methods

- (void)mg_addElementOnView:(UIView *)view
{
    //Add an example imageView
    UIView *itemsContainer = [UIView new];
    itemsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:itemsContainer];
    
    UIImageView *imageView = [UIImageView new];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [imageView setImage:[UIImage imageNamed:[GASettings appHomeBkSmall]]];
    [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [imageView.layer setBorderWidth:2.0];
    [imageView.layer setCornerRadius:45.0];
    imageView.userInteractionEnabled = YES;
    [itemsContainer addSubview:imageView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapRecognizer];
    
    
    //Add an example label
    _lblTitle = [UILabel new];
    [self updateGreetingsLabel];
    [itemsContainer addSubview:_lblTitle];
    
    //Add an example button
    UIButton *btContact = [UIButton buttonWithType:UIButtonTypeCustom];
    btContact.translatesAutoresizingMaskIntoConstraints = NO;
    [btContact setTitle:@"Logout" forState:UIControlStateNormal];
    [btContact addTarget:self action:@selector(actionContact:) forControlEvents:UIControlEventTouchUpInside];
    btContact.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1];
    btContact.titleLabel.font = [UIFont fontWithName:@"Verdana" size:12.0];
    btContact.layer.cornerRadius = 5.0;
    [itemsContainer addSubview:btContact];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:itemsContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:itemsContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    NSDictionary *items = NSDictionaryOfVariableBindings(imageView, _lblTitle, btContact);
    [items enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [itemsContainer addConstraint:[NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:itemsContainer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }];
    
    [itemsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(90)]" options:0 metrics:nil views:items]];
    [itemsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[btContact(70)]" options:0 metrics:nil views:items]];
    [itemsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-10-|" options:0 metrics:nil views:items]];
    
    [itemsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(90)]-10-[_lblTitle]-10-[btContact(30)]|" options:0 metrics:nil views:items]];
}

-(void) updateGreetingsLabel {
    NSString *firstname = [GASettings getFirstName];
    NSString *displayName = nil;
    if([firstname length] > 14) {
        displayName = [[NSString alloc]initWithFormat:@"Hello %@...",[firstname substringToIndex: MIN(14, [firstname length])]];
    } else if ([firstname length] > 0) {
        displayName = [[NSString alloc]initWithFormat:@"Hello %@",firstname];
    } else {
        NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"];
        displayName = [[NSString alloc]initWithFormat:@"Welcome to %@",value];
    }
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_lblTitle setText:displayName];
    [_lblTitle setFont:[UIFont boldSystemFontOfSize:25.0]];
    [_lblTitle setTextAlignment:NSTextAlignmentCenter];
    [_lblTitle setTextColor:[UIColor whiteColor]];
    _lblTitle.numberOfLines = 0;
    _lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
}

#pragma mark - Action

- (void)actionContact:(id)sender
{
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.loginViewController logout];
}


#pragma mark - Gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    [self updateGreetingsLabel];
}



@end
