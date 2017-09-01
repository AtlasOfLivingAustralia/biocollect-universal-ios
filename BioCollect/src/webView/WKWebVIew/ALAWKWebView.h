//
//  WKWebView.h
//  Oz Atlas


#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "JGActionSheet.h"

@interface ALAWKWebView : UIViewController <WKScriptMessageHandler, JGActionSheetDelegate>
- (void) homeView: (id)sender;
- (void) homeViewTab:(id)sender;
@end
