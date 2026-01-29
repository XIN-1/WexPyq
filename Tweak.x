#import <UIKit/UIKit.h>
#import "WexPyqMainController.h"

static UIButton *wexPyqButton = nil;
static BOOL wexPyqEnabled = YES;

static void showWexPyqMenu() {
    NSLog(@"[WexPyq] ========== showWexPyqMenu called =========");
    
    WexPyqMainController *mainController = [[WexPyqMainController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        NSLog(@"[WexPyq] Connected scenes: %lu", (unsigned long)scenes.count);
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    NSLog(@"[WexPyq] Checking window: %p, isKeyWindow: %d", window, window.isKeyWindow);
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
        NSLog(@"[WexPyq] Fallback to first window: %p", keyWindow);
    }
    
    NSLog(@"[WexPyq] Key window: %p", keyWindow);
    NSLog(@"[WexPyq] Root view controller: %p", keyWindow.rootViewController);
    
    UIViewController *rootViewController = keyWindow.rootViewController;
    if (rootViewController) {
        NSLog(@"[WexPyq] Presenting menu...");
        [rootViewController presentViewController:navController animated:YES completion:nil];
    } else {
        NSLog(@"[WexPyq] ERROR: No rootViewController found!");
    }
}

static void addWexPyqButton() {
    NSLog(@"[WexPyq] ========== addWexPyqButton called =========");
    
    if (wexPyqButton) {
        NSLog(@"[WexPyq] Button already exists, skipping");
        return;
    }
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] wexPyqEnabled from defaults: %d", wexPyqEnabled);
    
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] Plugin disabled, not adding button");
        return;
    }
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (!keyWindow) {
        NSLog(@"[WexPyq] ERROR: No key window found!");
        return;
    }
    
    NSLog(@"[WexPyq] Key window bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    
    wexPyqButton = [UIButton buttonWithType:UIButtonTypeSystem];
    wexPyqButton.frame = CGRectMake(keyWindow.bounds.size.width - 60, 100, 50, 50);
    [wexPyqButton setTitle:@"🔍" forState:UIControlStateNormal];
    wexPyqButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.9];
    wexPyqButton.layer.cornerRadius = 25;
    wexPyqButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [wexPyqButton addTarget:wexPyqButton action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyWindow addSubview:wexPyqButton];
    
    NSLog(@"[WexPyq] Button added to window successfully!");
}

@interface WexPyqButton : UIButton
@end

@implementation WexPyqButton

- (void)buttonTapped:(id)sender {
    NSLog(@"[WexPyq] ========== buttonTapped called =========");
    
    wexPyqEnabled = !wexPyqEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
    
    if (wexPyqEnabled) {
        showWexPyqMenu();
    }
}

@end

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSLog(@"[WexPyq] viewDidAppear called for: %@", bundleIdentifier);
    
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        NSLog(@"[WexPyq] WeChat detected!");
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"[WexPyq] Scheduling button addition...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addWexPyqButton();
            });
        });
    }
}

%end

%ctor {
    NSLog(@"[WexPyq] ========== Plugin loaded =========");
    NSLog(@"[WexPyq] Current application: %@", [NSBundle mainBundle].bundleIdentifier);
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
}