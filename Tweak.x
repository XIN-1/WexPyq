#import <UIKit/UIKit.h>
#import "WexPyqMainController.h"

@interface WexPyq : NSObject
@end

%hook MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showWexPyqMenu];
    });
    
    return result;
}

%new
- (void)showWexPyqMenu {
    WexPyqMainController *mainController = [[WexPyqMainController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [rootViewController presentViewController:navController animated:YES completion:nil];
}

%end

%ctor {
    NSLog(@"[WexPyq] Plugin loaded");
}