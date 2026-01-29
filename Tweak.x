#import <UIKit/UIKit.h>
#import "WexPyqMainController.h"
#import <Preferences/Preferences.h>

static UIButton *wexPyqButton = nil;
static BOOL wexPyqEnabled = YES;

static void showWexPyqMenu() {
    NSLog(@"[WexPyq] Showing menu...");
    
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
        [rootViewController presentViewController:navController animated:YES completion:nil];
    } else {
        NSLog(@"[WexPyq] No rootViewController found!");
    }
}

static void addWexPyqButton() {
    if (wexPyqButton) return;
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
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
    
    if (!keyWindow) return;
    
    wexPyqButton = [UIButton buttonWithType:UIButtonTypeSystem];
    wexPyqButton.frame = CGRectMake(keyWindow.bounds.size.width - 60, 100, 50, 50);
    [wexPyqButton setTitle:@"🔍" forState:UIControlStateNormal];
    wexPyqButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.9];
    wexPyqButton.layer.cornerRadius = 25;
    wexPyqButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [wexPyqButton addTarget:wexPyqButton action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyWindow addSubview:wexPyqButton];
    
    NSLog(@"[WexPyq] Button added to window");
}

@interface WexPyqButton : UIButton
@end

@implementation WexPyqButton

- (void)buttonTapped:(id)sender {
    NSLog(@"[WexPyq] Button tapped!");
    showWexPyqMenu();
}

@end

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleIdentifier isEqualToString:@"com.tencent.xin"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"[WexPyq] WeChat detected");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                addWexPyqButton();
            });
        });
    }
}

%end

@interface MMSettingViewController
- (void)viewDidLoad;
- (UITableView *)tableView;
@end

%hook MMSettingViewController

- (void)viewDidLoad {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UITableView *tableView = [self valueForKey:@"tableView"];
        if (!tableView) return;
        
        wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WexPyqSettingCell"];
        cell.textLabel.text = @"朋友圈查询";
        cell.detailTextLabel.text = wexPyqEnabled ? @"已开启" : @"已关闭";
        cell.imageView.image = [UIImage systemImageNamed:@"magnifyingglass.circle"];
        cell.accessoryType = wexPyqEnabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

%end

@interface UITableView (WexPyq)
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

%hook UITableView

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *cellIdentifier = @"WexPyqSettingCell";
        cell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"朋友圈查询";
            cell.detailTextLabel.text = wexPyqEnabled ? @"已开启" : @"已关闭";
            cell.imageView.image = [UIImage systemImageNamed:@"magnifyingglass.circle"];
            cell.accessoryType = wexPyqEnabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        wexPyqEnabled = !wexPyqEnabled;
        [[NSUserDefaults standardUserDefaults] setBool:wexPyqEnabled forKey:@"WexPyqEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"[WexPyq] Toggled to: %@", wexPyqEnabled ? @"ON" : @"OFF");
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (wexPyqEnabled) {
            if (wexPyqButton) {
                [wexPyqButton removeFromSuperview];
                wexPyqButton = nil;
            }
            addWexPyqButton();
        } else {
            if (wexPyqButton) {
                [wexPyqButton removeFromSuperview];
                wexPyqButton = nil;
            }
        }
        
        return;
    }
    
    %orig;
}

%end

%ctor {
    NSLog(@"[WexPyq] Plugin loaded");
    NSLog(@"[WexPyq] Current application: %@", [NSBundle mainBundle].bundleIdentifier);
    
    wexPyqEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"WexPyqEnabled"];
    NSLog(@"[WexPyq] Initial state: %@", wexPyqEnabled ? @"ON" : @"OFF");
}