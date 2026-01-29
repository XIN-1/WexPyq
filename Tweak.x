#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIButton *wexPyqButton = nil;
static BOOL wexPyqEnabled = YES;
static char buttonTappedKey;

static void logToFile(NSString *message) {
    NSString *timestamp = [NSString stringWithFormat:@"[%@] %@", 
        [NSDate dateWithTimeIntervalSinceNow:0], message];
    
    NSString *homePath = NSHomeDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:homePath]) {
        NSLog(@"[WexPyq] ERROR: Home path does not exist: %@", homePath);
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
            NSLog(@"[WexPyq] ERROR: Failed to create Documents directory: %@", error);
            return;
        }
    }
    
    NSString *logPath = [documentsPath stringByAppendingPathComponent:@"WexPyq.log"];
    
    // 读取现有日志内容
    NSMutableString *existingContent = [NSMutableString string];
    if ([fileManager fileExistsAtPath:logPath]) {
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:logPath 
                                                      encoding:NSUTF8StringEncoding 
                                                         error:&error];
        if (!error && content) {
            [existingContent appendString:content];
        }
    }
    
    // 添加新日志
    [existingContent appendFormat:@"%@\n", timestamp];
    
    // 写入日志文件
    NSError *error = nil;
    [existingContent writeToFile:logPath 
                      atomically:YES 
                        encoding:NSUTF8StringEncoding 
                           error:&error];
    if (error) {
        NSLog(@"[WexPyq] ERROR: Failed to write log: %@", error);
    }
}

static void showWexPyqMenu() {
    @autoreleasepool {
        NSLog(@"[WexPyq] showWexPyqMenu called");
        logToFile(@"[WexPyq] showWexPyqMenu called");
        
        // 导入控制器头文件
        Class WexPyqMainControllerClass = NSClassFromString(@"WexPyqMainController");
        if (WexPyqMainControllerClass) {
            NSLog(@"[WexPyq] Found WexPyqMainController class");
            logToFile(@"[WexPyq] Found WexPyqMainController class");
            
            UIViewController *mainController = [[WexPyqMainControllerClass alloc] init];
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
            
            if (keyWindow && keyWindow.rootViewController) {
                NSLog(@"[WexPyq] Presenting WexPyqMainController...");
                logToFile(@"[WexPyq] Presenting WexPyqMainController...");
                [keyWindow.rootViewController presentViewController:navController animated:YES completion:nil];
            } else {
                NSLog(@"[WexPyq] ERROR: No rootViewController found!");
                logToFile(@"[WexPyq] ERROR: No rootViewController found!");
            }
        } else {
            NSLog(@"[WexPyq] ERROR: WexPyqMainController class not found!");
            logToFile(@"[WexPyq] ERROR: WexPyqMainController class not found!");
            
            // 降级到alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"朋友圈查询" message:@"插件功能开发中" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            
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
            
            if (keyWindow && keyWindow.rootViewController) {
                NSLog(@"[WexPyq] Showing alert (fallback)...");
                logToFile(@"[WexPyq] Showing alert (fallback)...");
                [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

static void toggleWexPyq() {
    wexPyqEnabled = !wexPyqEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    if (wexPyqEnabled) {
        showWexPyqMenu();
    }
}

static void addWexPyqButton() {
    NSLog(@"[WexPyq] addWexPyqButton called");
    logToFile(@"[WexPyq] addWexPyqButton called");
    
    if (wexPyqButton) {
        NSLog(@"[WexPyq] Button already exists, returning");
        logToFile(@"[WexPyq] Button already exists, returning");
        return;
    }
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Current enabled state: %@", wexPyqEnabled ? @"YES" : @"NO");
    logToFile([NSString stringWithFormat:@"[WexPyq] Current enabled state: %@", wexPyqEnabled ? @"YES" : @"NO"]);
    
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] Plugin disabled, skipping button creation");
        logToFile(@"[WexPyq] Plugin disabled, skipping button creation");
        return;
    }
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        NSLog(@"[WexPyq] Found %lu scenes", (unsigned long)scenes.count);
        logToFile([NSString stringWithFormat:@"[WexPyq] Found %lu scenes", (unsigned long)scenes.count]);
        
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                NSLog(@"[WexPyq] Found UIWindowScene with %lu windows", (unsigned long)windowScene.windows.count);
                logToFile([NSString stringWithFormat:@"[WexPyq] Found UIWindowScene with %lu windows", (unsigned long)windowScene.windows.count]);
                
                for (UIWindow *window in windowScene.windows) {
                    NSLog(@"[WexPyq] Checking window: %@, isKeyWindow: %@", window, window.isKeyWindow ? @"YES" : @"NO");
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        NSLog(@"[WexPyq] Found key window: %@", keyWindow);
                        logToFile([NSString stringWithFormat:@"[WexPyq] Found key window: %@", keyWindow]);
                        break;
                    }
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
        NSLog(@"[WexPyq] Using first window as fallback: %@", keyWindow);
        logToFile([NSString stringWithFormat:@"[WexPyq] Using first window as fallback: %@", keyWindow]);
    }
    
    if (!keyWindow) {
        NSLog(@"[WexPyq] ERROR: No window found!");
        logToFile(@"[WexPyq] ERROR: No window found!");
        return;
    }
    
    NSLog(@"[WexPyq] Window bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    logToFile([NSString stringWithFormat:@"[WexPyq] Window bounds: %@", NSStringFromCGRect(keyWindow.bounds)]);
    
    wexPyqButton = [UIButton buttonWithType:UIButtonTypeSystem];
    wexPyqButton.frame = CGRectMake(keyWindow.bounds.size.width/2 - 25, 100, 50, 50);
    [wexPyqButton setTitle:@"🔍" forState:UIControlStateNormal];
    wexPyqButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    wexPyqButton.layer.cornerRadius = 25;
    wexPyqButton.titleLabel.font = [UIFont systemFontOfSize:24];
    
    // 使用addTarget:action:forControlEvents:的替代方法
    [wexPyqButton addTarget:wexPyqButton action:@selector(performClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 为按钮添加点击处理
    objc_setAssociatedObject(wexPyqButton, &buttonTappedKey, ^{ 
        NSLog(@"[WexPyq] Button tapped (block)");
        logToFile(@"[WexPyq] Button tapped (block)");
        toggleWexPyq();
    }, OBJC_ASSOCIATION_COPY);
    
    [keyWindow addSubview:wexPyqButton];
    wexPyqButton.layer.zPosition = CGFLOAT_MAX;
    
    NSLog(@"[WexPyq] Button added successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame));
    logToFile([NSString stringWithFormat:@"[WexPyq] Button added successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame)]);
}

// 为UIButton添加category，实现performClick:方法
@interface UIButton (WexPyq)
- (void)performClick:(id)sender;
@end

@implementation UIButton (WexPyq)

- (void)performClick:(id)sender {
    void (^tapBlock)(void) = objc_getAssociatedObject(self, &buttonTappedKey);
    if (tapBlock) {
        tapBlock();
    }
}

@end

@interface MMSettingViewController
@property (nonatomic, strong) UIView *view;
@end

%hook MMSettingViewController

- (void)viewDidLoad {
    %orig;
    
    NSLog(@"[WexPyq] MMSettingViewController viewDidLoad called");
    logToFile(@"[WexPyq] MMSettingViewController viewDidLoad called");
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSLog(@"[WexPyq] MMSettingViewController appeared");
    logToFile(@"[WexPyq] MMSettingViewController appeared");
    
    // 添加设置开关
    @autoreleasepool {
        UIView *view = self.view;
        if (view) {
            NSLog(@"[WexPyq] View bounds: %@", NSStringFromCGRect(view.bounds));
            logToFile([NSString stringWithFormat:@"[WexPyq] View bounds: %@", NSStringFromCGRect(view.bounds)]);
            
            // 直接在设置页面顶部添加一个明显的设置按钮
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
                @autoreleasepool {
                    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    settingButton.frame = CGRectMake(20, 80, view.bounds.size.width - 40, 60);
                    [settingButton setTitle:@"朋友圈查询" forState:UIControlStateNormal];
                    [settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    settingButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
                    settingButton.layer.cornerRadius = 10;
                    settingButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
                    
                    // 添加点击事件
                    [settingButton addTarget:settingButton action:@selector(performClick:) forControlEvents:UIControlEventTouchUpInside];
                    objc_setAssociatedObject(settingButton, &buttonTappedKey, ^{ 
                        NSLog(@"[WexPyq] Setting button tapped");
                        logToFile(@"[WexPyq] Setting button tapped");
                        toggleWexPyq();
                    }, OBJC_ASSOCIATION_COPY);
                    
                    [view addSubview:settingButton];
                    settingButton.layer.zPosition = CGFLOAT_MAX;
                    NSLog(@"[WexPyq] Setting button added at position: %@", NSStringFromCGRect(settingButton.frame));
                    logToFile([NSString stringWithFormat:@"[WexPyq] Setting button added at position: %@", NSStringFromCGRect(settingButton.frame)]);
                }
            });
        } else {
            NSLog(@"[WexPyq] ERROR: View is nil");
            logToFile(@"[WexPyq] ERROR: View is nil");
        }
    }
}

%end

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addWexPyqButton();
            });
        });
    }
}

%end

%ctor {
    NSLog(@"[WexPyq] Plugin loaded");
    logToFile(@"[WexPyq] Plugin loaded");
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    if (!wexPyqEnabled) {
        wexPyqEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"[WexPyq] Forced to ON state");
        logToFile(@"[WexPyq] Forced to ON state");
    }
}