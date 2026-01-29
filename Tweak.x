#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/**
 * WexPyq - 微信朋友圈查询插件
 * 插件入口文件，负责：
 * 1. 在微信中添加悬浮窗按钮
 * 2. 在微信设置页面添加入口
 * 3. 处理插件的加载和初始化
 * 4. 提供日志记录功能
 */

// 全局变量
static UIButton *wexPyqButton = nil;  // 悬浮窗按钮
static BOOL wexPyqEnabled = YES;      // 插件启用状态
static char buttonTappedKey;           // 按钮点击事件关联对象的键

/**
 * 记录日志到文件
 * @param message 要记录的日志信息
 * 
 * 功能说明：
 * 1. 在~/Documents目录下创建WexPyq.log文件
 * 2. 以追加模式写入日志，保留历史记录
 * 3. 每条日志包含时间戳
 * 4. 处理各种错误情况，确保日志记录不会影响插件运行
 */
static void logToFile(NSString *message) {
    // 生成带时间戳的日志内容
    NSString *timestamp = [NSString stringWithFormat:@"[%@] %@", 
        [NSDate dateWithTimeIntervalSinceNow:0], message];
    
    // 获取沙盒路径
    NSString *homePath = NSHomeDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 检查主目录是否存在
    if (![fileManager fileExistsAtPath:homePath]) {
        NSLog(@"[WexPyq] ERROR: Home path does not exist: %@", homePath);
        return;
    }
    
    // 获取Documents目录路径
    NSString *documentsPath = [homePath stringByAppendingPathComponent:@"Documents"];
    
    // 如果Documents目录不存在，创建它
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
    
    // 日志文件路径
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

/**
 * 显示朋友圈查询菜单
 * 
 * 功能说明：
 * 1. 使用NSClassFromString动态查找WexPyqMainController类
 * 2. 创建导航控制器并设置为主界面
 * 3. 查找当前的keyWindow并显示菜单
 * 4. 如果控制器类不存在，降级显示alert提示
 * 5. 支持iOS 13+的Scene架构和传统窗口架构
 * 
 * 技术要点：
 * - 使用@autoreleasepool管理内存
 * - 动态类加载避免编译时依赖
 * - 多层错误处理确保稳定运行
 * - 详细的日志记录便于调试
 */
static void showWexPyqMenu() {
    @autoreleasepool {
        NSLog(@"[WexPyq] showWexPyqMenu called");
        logToFile(@"[WexPyq] showWexPyqMenu called");
        
        // 动态查找WexPyqMainController类
        Class WexPyqMainControllerClass = NSClassFromString(@"WexPyqMainController");
        if (WexPyqMainControllerClass) {
            NSLog(@"[WexPyq] Found WexPyqMainController class");
            logToFile(@"[WexPyq] Found WexPyqMainController class");
            
            // 创建主控制器和导航控制器
            UIViewController *mainController = [[WexPyqMainControllerClass alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
            navController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            // 查找keyWindow
            UIWindow *keyWindow = nil;
            if (@available(iOS 13.0, *)) {
                // iOS 13+ 使用Scene架构
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
            
            // 降级到传统窗口查找
            if (!keyWindow) {
                keyWindow = [UIApplication sharedApplication].windows.firstObject;
            }
            
            // 显示菜单
            if (keyWindow && keyWindow.rootViewController) {
                NSLog(@"[WexPyq] Presenting WexPyqMainController...");
                logToFile(@"[WexPyq] Presenting WexPyqMainController...");
                [keyWindow.rootViewController presentViewController:navController animated:YES completion:nil];
            } else {
                NSLog(@"[WexPyq] ERROR: No rootViewController found!");
                logToFile(@"[WexPyq] ERROR: No rootViewController found!");
            }
        } else {
            // 降级处理：控制器类不存在时显示alert
            NSLog(@"[WexPyq] ERROR: WexPyqMainController class not found!");
            logToFile(@"[WexPyq] ERROR: WexPyqMainController class not found!");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"朋友圈查询" message:@"插件功能开发中" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            
            // 查找keyWindow
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
            
            // 显示alert
            if (keyWindow && keyWindow.rootViewController) {
                NSLog(@"[WexPyq] Showing alert (fallback)...");
                logToFile(@"[WexPyq] Showing alert (fallback)...");
                [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

/**
 * 切换插件启用状态并显示菜单
 * 
 * 功能说明：
 * 1. 切换wexPyqEnabled全局变量的状态
 * 2. 将状态保存到NSUserDefaults，实现持久化
 * 3. 记录状态变更日志
 * 4. 如果切换到启用状态，显示插件菜单
 * 
 * 技术要点：
 * - 使用NSUserDefaults实现状态持久化
 * - 调用synchronize确保状态立即保存
 * - 条件性显示菜单，优化用户体验
 */
static void toggleWexPyq() {
    // 切换启用状态
    wexPyqEnabled = !wexPyqEnabled;
    
    // 保存状态到NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 记录状态变更
    NSLog(@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    // 如果启用，显示菜单
    if (wexPyqEnabled) {
        showWexPyqMenu();
    }
}

/**
 * 在微信界面添加悬浮窗按钮
 * 
 * 功能说明：
 * 1. 检查按钮是否已存在，避免重复创建
 * 2. 读取插件启用状态，决定是否创建按钮
 * 3. 查找当前的keyWindow，支持iOS 13+的Scene架构
 * 4. 创建悬浮窗按钮并设置样式和位置
 * 5. 使用objc_setAssociatedObject添加点击事件处理
 * 6. 将按钮添加到窗口并设置zPosition确保显示在最上层
 * 
 * 技术要点：
 * - 使用objc关联对象实现按钮点击事件
 * - 多层窗口查找逻辑确保兼容性
 * - 详细的日志记录便于调试
 * - 合理的错误处理确保稳定运行
 */
static void addWexPyqButton() {
    NSLog(@"[WexPyq] addWexPyqButton called");
    logToFile(@"[WexPyq] addWexPyqButton called");
    
    // 检查按钮是否已存在
    if (wexPyqButton) {
        NSLog(@"[WexPyq] Button already exists, returning");
        logToFile(@"[WexPyq] Button already exists, returning");
        return;
    }
    
    // 读取插件启用状态
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Current enabled state: %@", wexPyqEnabled ? @"YES" : @"NO");
    logToFile([NSString stringWithFormat:@"[WexPyq] Current enabled state: %@", wexPyqEnabled ? @"YES" : @"NO"]);
    
    // 如果插件禁用，跳过按钮创建
    if (!wexPyqEnabled) {
        NSLog(@"[WexPyq] Plugin disabled, skipping button creation");
        logToFile(@"[WexPyq] Plugin disabled, skipping button creation");
        return;
    }
    
    // 查找keyWindow
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        // iOS 13+ 使用Scene架构
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
    
    // 降级到传统窗口查找
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
        NSLog(@"[WexPyq] Using first window as fallback: %@", keyWindow);
        logToFile([NSString stringWithFormat:@"[WexPyq] Using first window as fallback: %@", keyWindow]);
    }
    
    // 检查是否找到窗口
    if (!keyWindow) {
        NSLog(@"[WexPyq] ERROR: No window found!");
        logToFile(@"[WexPyq] ERROR: No window found!");
        return;
    }
    
    // 记录窗口信息
    NSLog(@"[WexPyq] Window bounds: %@", NSStringFromCGRect(keyWindow.bounds));
    logToFile([NSString stringWithFormat:@"[WexPyq] Window bounds: %@", NSStringFromCGRect(keyWindow.bounds)]);
    
    // 创建悬浮窗按钮
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
    
    // 添加按钮到窗口并设置zPosition
    [keyWindow addSubview:wexPyqButton];
    wexPyqButton.layer.zPosition = CGFLOAT_MAX;
    
    // 记录按钮添加成功
    NSLog(@"[WexPyq] Button added successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame));
    logToFile([NSString stringWithFormat:@"[WexPyq] Button added successfully at position: %@", NSStringFromCGRect(wexPyqButton.frame)]);
}

/**
 * UIButton分类，实现performClick:方法
 * 
 * 功能说明：
 * 1. 为UIButton添加performClick:方法
 * 2. 从关联对象中获取点击处理block
 * 3. 如果block存在，执行它
 * 
 * 技术要点：
 * - 使用objc_getAssociatedObject获取关联的block
 * - 条件性执行block，确保安全
 * - 作为按钮点击事件的处理入口
 */
@interface UIButton (WexPyq)
/**
 * 按钮点击事件处理方法
 * @param sender 事件发送者
 */
- (void)performClick:(id)sender;
@end

@implementation UIButton (WexPyq)

- (void)performClick:(id)sender {
    // 从关联对象中获取点击处理block
    void (^tapBlock)(void) = objc_getAssociatedObject(self, &buttonTappedKey);
    // 如果block存在，执行它
    if (tapBlock) {
        tapBlock();
    }
}

@end

/**
 * MMSettingViewController接口声明
 * 添加view属性，确保hook时可以访问
 */
@interface MMSettingViewController
@property (nonatomic, strong) UIView *view;
@end

/**
 * MMSettingViewController hook
 * 
 * 功能说明：
 * 1. 在微信设置页面添加一个明显的"朋友圈查询"按钮
 * 2. 按钮点击后触发插件菜单显示
 * 3. 支持微信设置页面的动态加载
 * 
 * 技术要点：
 * - 使用%hook钩子微信设置控制器
 * - 在viewDidAppear中添加按钮，确保视图已完全加载
 * - 使用dispatch_after避免UI阻塞
 * - 详细的日志记录便于调试
 */
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

/**
 * UIViewController hook
 * 
 * 功能说明：
 * 1. 监听所有UIViewController的viewDidAppear事件
 * 2. 检测是否在微信应用中（bundleIdentifier为com.tencent.xin）
 * 3. 使用dispatch_once确保只添加一次悬浮窗按钮
 * 4. 使用dispatch_after延迟添加按钮，避免影响应用启动
 * 
 * 技术要点：
 * - 使用%hook钩子所有UIViewController
 * - 通过bundleIdentifier识别微信应用
 * - 使用dispatch_once实现单例模式
 * - 使用dispatch_after优化启动性能
 */
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // 检测是否在微信应用中
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        // 使用dispatch_once确保只添加一次按钮
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ 
            // 延迟1秒添加按钮，避免影响应用启动
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
                addWexPyqButton();
            });
        });
    }
}

%end

/**
 * 插件构造函数
 * 
 * 功能说明：
 * 1. 在插件加载时执行初始化操作
 * 2. 记录插件加载日志
 * 3. 从NSUserDefaults读取初始启用状态
 * 4. 如果状态未设置或为NO，强制设置为YES
 * 5. 确保插件默认处于启用状态
 * 
 * 技术要点：
 * - 使用%ctor标记构造函数，Theos会自动识别
 * - 初始化插件状态，确保首次运行时正确设置
 * - 详细的日志记录，便于调试和问题排查
 */
%ctor {
    // 记录插件加载
    NSLog(@"[WexPyq] Plugin loaded");
    logToFile(@"[WexPyq] Plugin loaded");
    
    // 读取初始启用状态
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
    logToFile([NSString stringWithFormat:@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF"]);
    
    // 如果状态未设置或为NO，强制设置为YES
    if (!wexPyqEnabled) {
        wexPyqEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"[WexPyq] Forced to ON state");
        logToFile(@"[WexPyq] Forced to ON state");
    }
}