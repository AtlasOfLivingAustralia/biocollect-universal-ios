//
//  WKWebView.m
//  Oz Atlas

#import <Foundation/Foundation.h>
#import "ALAWKWebView.h"
#import "GAAppDelegate.h"

@interface ALAWKWebView ()
@property(strong,nonatomic) WKWebView *webView;
@property(strong,nonatomic) NSMutableURLRequest *request;
@property (strong, nonatomic) JGActionSheet *menu;
@property (strong, nonatomic) JGActionSheetSection *menuGroup;
@property (strong, nonatomic) JGActionSheetSection *cancelGroup;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation ALAWKWebView

@synthesize request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *controller = [[WKUserContentController alloc] init];
        [controller addScriptMessageHandler:self name:@"observe"];
        configuration.userContentController = controller;
        NSString *url = [[NSString alloc] initWithFormat:@"http://192.168.0.8:8087/biocollect/biocontrolhub/mobile/index"];
        _webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds] configuration:configuration];
        _webView.navigationDelegate = self;
        NSString *escapedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:escapedUrlString]];
        
        UIBarButtonItem *leftMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home-50"]
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(reload:)];
        
        UIBarButtonItem *rightMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(showOptions:)];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: leftMenu, nil];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: rightMenu, nil];
        
        
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[appDelegate.mkmUtil logoFileText]]];
        //imageView.contentMode = UIViewContentModeCenter;
        //self.navigationItem.titleView = imageView;
        
        
        [self.view addSubview:_webView];
        self.indicator.center = CGPointMake(CGRectGetMidX(_webView.bounds), CGRectGetMidY(_webView.bounds));
        [self.view addSubview:_indicator];
    }
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView sizeToFit];
    
}

-(void) viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.body && [message.body isEqualToString:@"project-trigger"]) {
        // Switch tab.
        dispatch_async(dispatch_get_main_queue(), ^{
            /*AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.tabBarController.selectedViewController = [appDelegate.tabBarController.viewControllers objectAtIndex:1];
            if([appDelegate.mkmUtil notReachable]) {
                [MKMUtil internetDownError];
            }
            // Refreshing here, stuffs up the UI.
            [appDelegate.notificationVC refresh];
            */
        });
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    /*if ([keyPath isEqualToString:@"estimatedProgress"]) {
     if ([change[NSKeyValueChangeKindKey] integerValue] == NSKeyValueObservingOptionNew) {
     
     }
     }*/
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_webView setFrame:[[UIScreen mainScreen] bounds]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                /*
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                 message:@"Authentication denied, try logging out and logging in again."
                 delegate:nil
                 cancelButtonTitle:@"Cancel"
                 otherButtonTitles:nil];
                 [alert show];
                 */
                
            });
        }
        
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.indicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.indicator stopAnimating];
}

-(void) homeView: (id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tabBarController.selectedViewController = [appDelegate.tabBarController.viewControllers objectAtIndex:0];
        [self setLoadRequest];
        [_webView loadRequest:request];
        
        /*
        if([appDelegate.mkmUtil notReachable]) {
            [MKMUtil internetDownError];
        }
        */
    });
}

-(void) setLoadRequest {
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
    if([appDelegate.mkmUtil notReachable]) {
        [MKMUtil internetDownError];
        return;
    }
    */
    //[request setHTTPMethod:@"POST"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //NSString *token = appDelegate.user && appDelegate.user.accessToken ? appDelegate.user.accessToken : @"";
    //[request setValue: [[NSString alloc] initWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    //[request setTimeoutInterval: DEFAULT_TIMEOUT];
    
    [_webView loadRequest:request];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}
@end
