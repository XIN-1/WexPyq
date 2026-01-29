#import <UIKit/UIKit.h>
#import "WexPyqMainController.h"

static UIButton *wexPyqButton = nil;
static BOOL wexPyqEnabled = YES;

static void logToFile(NSString *message) {
    NSString *timestamp = [NSString stringWithFormat:@"[%@] %@", 
        [NSDate dateWithTimeIntervalSinceNow:0], message];
    
    NSString *homePath = NSHomeDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:homePath]) {
        NSLog(@"[WexPyq] Home path does not exist: %@", homePath);
        return;
    }
    
    NSString *documentsPath = [homePath stringByAppendingPathComponent:@"Documents"];
    
    if (![fileManager fileExistsAtPath:documentsPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:documentsPath 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:&error];
        if (error) {
            NSLog(@"[WexPyq] Failed to create Documents directory: %@", error);
            return;
        }
    }
    
    NSString *logPath = [documentsPath stringByAppendingPathComponent:@"WexPyq.log"];
    NSString *content = [NSString stringWithFormat:@"%@\n", timestamp];
    
    NSError *error = nil;
    [content writeToFile:logPath 
              atomically:YES 
                encoding:NSUTF8StringEncoding 
                   error:&error];
    if (error) {
        NSLog(@"[WexPyq] Failed to write log: %@", error);
    }
}

static void showWexPyqMenu() {
    NSString *message = @"showWexPyqMenu called";
    NSLog(@"[WexPyq] %@", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] %@", message]);
    
    WexPyqMainController *mainController = [[WexPyqMainController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
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
    
    UIViewController *rootViewController = keyWindow.rootViewController;
    if (rootViewController) {
        NSLog(@"[WexPyq] Presenting menu...");
        logToFile(@"[WexPyq] Presenting menu...");
        [rootViewController presentViewController:navController animated:YES completion:nil];
    } else {
        NSLog(@"[WexPyq] ERROR: No rootViewController found!");
        logToFile(@"[WexPyq] ERROR: No rootViewController found!");
    }
}

static void addWexPyqButton() {
    NSString *message = @"addWexPyqButton called";
    NSLog(@"[WexPyq] ========== %@ =========", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ========== %@ =========", message]);
    
    if (wexPyqButton) {
        NSLog(@"[WexPyq] Button already exists, skipping");
        logToFile(@"[WexPyq] Button already exists, skipping");
        return;
    }
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] wexPyqEnabled from defaults: %d", wexPyqEnabled);
    logToFile([NSString stringWithFormat:@"[WexPyq] wexPyqEnabled from defaults: %d", wexPyqEnabled]);
    
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] Plugin disabled, not adding button");
        logToFile(@"[WexPyq] Plugin disabled, not adding button");
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
        logToFile(@"[WexPyq] ERROR: No key window found!");
        return;
    }
    
    NSLog(@"[WexPyq] Key window bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    logToFile([NSString stringWithFormat:@"[WexPyq] Key window bounds: %@", NSStringFromCGRect(keyWindow.bounds)]);
    
    wexPyqButton = [UIButton buttonWithType:UIButtonTypeSystem];
    wexPyqButton.frame = CGRectMake(keyWindow.bounds.size.width - 60, 100, 50, 50);
    [wexPyqButton setTitle:@"🔍" forState:UIControlStateNormal];
    wexPyqButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.9];
    wexPyqButton.layer.cornerRadius = 25;
    wexPyqButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [wexPyqButton addTarget:wexPyqButton action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyWindow addSubview:wexPyqButton];
    
    NSLog(@"[WexPyq] Button added to window successfully!");
    logToFile(@"[WexPyq] Button added to window successfully!");
}

@interface WexPyqButton : UIButton
@end

@implementation WexPyqButton

- (void)buttonTapped:(id)sender {
    NSString *message = @"buttonTapped called";
    NSLog(@"[WexPyq] ========== %@ =========", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ========== %@ =========", message]);
    
    wexPyqEnabled = !wexPyqEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
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
    logToFile([NSString stringWithFormat:@"[WexPyq] viewDidAppear called for: %@", bundleIdentifier]);
    
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        NSLog(@"[WexPyq] WeChat detected!");
        logToFile(@"[WexPyq] WeChat detected!");
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"[WexPyq] Scheduling button addition...");
            logToFile(@"[WexPyq] Scheduling button addition...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addWexPyqButton();
            });
        });
    }
}

%end

%ctor {
    NSString *message = @"Plugin loaded";
    NSLog(@"[WexPyq] ========== %@ =========", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ========== %@ =========", message]);
    
    NSLog(@"[WexPyq] Current application: %@", [NSBundle mainBundle].bundleIdentifier);
    logToFile([NSString stringWithFormat:@"[WexPyq] Current application: %@", [NSBundle mainBundle].bundleIdentifier]);
    
    NSLog(@"[WexPyq] Home directory: %@", NSHomeDirectory());
    logToFile([NSString stringWithFormat:@"[WexPyq] Home directory: %@", NSHomeDirectory()]);
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
}