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
        NSLog(@"[WexPyq] ERROR: Home path does not exist: %@", homePath);
        return;
    }
    
    NSLog(@"[WexPyq] Home path: %@", homePath);
    
    NSString *documentsPath = [homePath stringByAppendingPathComponent:@"Documents"];
    NSLog(@"[WexPyq] Documents path: %@", documentsPath);
    
    if (![fileManager fileExistsAtPath:documentsPath]) {
        NSLog(@"[WexPyq] INFO: Documents directory does not exist, creating...");
        NSError *error = nil;
        [fileManager createDirectoryAtPath:documentsPath 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:&error];
        if (error) {
            NSLog(@"[WexPyq] ERROR: Failed to create Documents directory: %@", error);
            return;
        }
        NSLog(@"[WexPyq] SUCCESS: Created Documents directory");
    }
    
    NSString *logPath = [documentsPath stringByAppendingPathComponent:@"WexPyq.log"];
    NSLog(@"[WexPyq] Log path: %@", logPath);
    
    NSString *content = [NSString stringWithFormat:@"%@\n", timestamp];
    
    NSError *error = nil;
    [content writeToFile:logPath 
              atomically:YES 
                encoding:NSUTF8StringEncoding 
                   error:&error];
    if (error) {
        NSLog(@"[WexPyq] ERROR: Failed to write log: %@", error);
    } else {
        NSLog(@"[WexPyq] SUCCESS: Log written to file");
    }
}

static void showWexPyqMenu() {
    NSString *message = @"showWexPyqMenu called"; 
    NSLog(@"[WexPyq] ============= %@ =============", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ============= %@ =============", message]);
    
    WexPyqMainController *mainController = [[WexPyqMainController alloc] init];
    NSLog(@"[WexPyq] Created main controller: %p", mainController);
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    NSLog(@"[WexPyq] Created navigation controller: %p", navController);
    
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        NSLog(@"[WexPyq] Connected scenes count: %lu", (unsigned long)scenes.count);
        for (UIScene *scene in scenes) {
            NSLog(@"[WexPyq] Scene: %@, class: %@", scene, NSStringFromClass([scene class]));
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                NSLog(@"[WexPyq] Window scene windows count: %lu", (unsigned long)windowScene.windows.count);
                for (UIWindow *window in windowScene.windows) {
                    NSLog(@"[WexPyq] Window: %p, isKeyWindow: %d, bounds: %@", window, window.isKeyWindow, NSStringFromCGRect(window.bounds));
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        NSLog(@"[WexPyq] Found key window: %p", keyWindow);
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
    
    if (!keyWindow) {
        NSLog(@"[WexPyq] ERROR: No key window found!");
        logToFile(@"[WexPyq] ERROR: No key window found!");
        return;
    }
    
    NSLog(@"[WexPyq] Key window bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    NSLog(@"[WexPyq] Key window rootViewController: %p", keyWindow.rootViewController);
    
    UIViewController *rootViewController = keyWindow.rootViewController;
    if (rootViewController) {
        NSLog(@"[WexPyq] SUCCESS: Presenting menu...");
        logToFile(@"[WexPyq] SUCCESS: Presenting menu...");
        [rootViewController presentViewController:navController animated:YES completion:^{ 
            NSLog(@"[WexPyq] SUCCESS: Menu presented successfully");
            logToFile(@"[WexPyq] SUCCESS: Menu presented successfully");
        }];
    } else {
        NSLog(@"[WexPyq] ERROR: No rootViewController found!");
        logToFile(@"[WexPyq] ERROR: No rootViewController found!");
    }
}

static void addWexPyqButton() {
    NSString *message = @"addWexPyqButton called"; 
    NSLog(@"[WexPyq] ============= %@ =============", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ============= %@ =============", message]);
    
    if (wexPyqButton) {
        NSLog(@"[WexPyq] INFO: Button already exists, skipping");
        logToFile(@"[WexPyq] INFO: Button already exists, skipping");
        return;
    }
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] INFO: wexPyqEnabled from defaults: %d", wexPyqEnabled);
    logToFile([NSString stringWithFormat:@"[WexPyq] INFO: wexPyqEnabled from defaults: %d", wexPyqEnabled]);
    
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] INFO: Plugin disabled, not adding button");
        logToFile(@"[WexPyq] INFO: Plugin disabled, not adding button");
        return;
    }
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        NSLog(@"[WexPyq] INFO: Connected scenes count: %lu", (unsigned long)scenes.count);
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        NSLog(@"[WexPyq] SUCCESS: Found key window: %p", keyWindow);
                        break;
                    }
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
        NSLog(@"[WexPyq] INFO: Fallback to first window: %p", keyWindow);
    }
    
    if (!keyWindow) {
        NSLog(@"[WexPyq] ERROR: No key window found!");
        logToFile(@"[WexPyq] ERROR: No key window found!");
        return;
    }
    
    NSLog(@"[WexPyq] SUCCESS: Key window found, bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    logToFile([NSString stringWithFormat:@"[WexPyq] SUCCESS: Key window found, bounds: %@", NSStringFromCGRect(keyWindow.bounds)]);
    
    wexPyqButton = [UIButton buttonWithType:UIButtonTypeSystem];
    wexPyqButton.frame = CGRectMake(keyWindow.bounds.size.width/2 - 25, 100, 50, 50);
    [wexPyqButton setTitle:@"🔍" forState:UIControlStateNormal];
    wexPyqButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    wexPyqButton.layer.cornerRadius = 25;
    wexPyqButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [wexPyqButton addTarget:wexPyqButton action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyWindow addSubview:wexPyqButton];
    
    // Set button layer zPosition to make it appear on top
    wexPyqButton.layer.zPosition = CGFLOAT_MAX;
    
    NSLog(@"[WexPyq] SUCCESS: Button added to window successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame));
    logToFile([NSString stringWithFormat:@"[WexPyq] SUCCESS: Button added to window successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame)]);
}

@interface WexPyqButton : UIButton
@end

@implementation WexPyqButton

- (void)buttonTapped:(id)sender {
    NSString *message = @"buttonTapped called"; 
    NSLog(@"[WexPyq] ============= %@ =============", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ============= %@ =============", message]);
    
    wexPyqEnabled = !wexPyqEnabled;
    NSLog(@"[WexPyq] INFO: Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
    
    [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    logToFile([NSString stringWithFormat:@"[WexPyq] INFO: Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    if (wexPyqEnabled) {
        NSLog(@"[WexPyq] INFO: Showing menu...");
        showWexPyqMenu();
    } else {
        NSLog(@"[WexPyq] INFO: Plugin disabled, menu not shown");
        logToFile(@"[WexPyq] INFO: Plugin disabled, menu not shown");
    }
}

@end

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSLog(@"[WexPyq] INFO: viewDidAppear called for: %@", bundleIdentifier);
    
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        NSLog(@"[WexPyq] SUCCESS: WeChat detected!");
        logToFile(@"[WexPyq] SUCCESS: WeChat detected!");
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"[WexPyq] INFO: Scheduling button addition in 1 second...");
            logToFile(@"[WexPyq] INFO: Scheduling button addition in 1 second...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addWexPyqButton();
            });
        });
    }
}

%end

%ctor {
    NSString *message = @"Plugin loaded"; 
    NSLog(@"[WexPyq] ============= %@ =============", message);
    logToFile([NSString stringWithFormat:@"[WexPyq] ============= %@ =============", message]);
    
    NSLog(@"[WexPyq] INFO: Current application: %@", [NSBundle mainBundle].bundleIdentifier);
    logToFile([NSString stringWithFormat:@"[WexPyq] INFO: Current application: %@", [NSBundle mainBundle].bundleIdentifier]);
    
    NSLog(@"[WexPyq] INFO: Home directory: %@", NSHomeDirectory());
    logToFile([NSString stringWithFormat:@"[WexPyq] INFO: Home directory: %@", NSHomeDirectory()]);
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] INFO: Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] INFO: Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    // 强制开启插件
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] INFO: Forcing plugin to ON state");
        wexPyqEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        logToFile(@"[WexPyq] INFO: Forced plugin to ON state");
    }
}