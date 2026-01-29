#import <UIKit/UIKit.h>
#import "WexPyqMainController.h"

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

@interface MMSettingViewController
- (void)viewDidLoad;
@end

%hook MMSettingViewController

- (void)viewDidLoad {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UITableView *tableView = [self valueForKey:@"tableView"];
        if (!tableView) return;
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WexPyqCell"];
        cell.textLabel.text = @"朋友圈查询";
        cell.imageView.image = [UIImage systemImageNamed:@"magnifyingglass.circle"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView cellForRowAtIndexPath:indexPath];
    });
}

%end

@interface UITableView (WexPyq)
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

%hook UITableView

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *cellIdentifier = @"WexPyqCell";
        cell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"朋友圈查询";
            cell.imageView.image = [UIImage systemImageNamed:@"magnifyingglass.circle"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        showWexPyqMenu();
        return;
    }
    
    %orig;
}

%end

%ctor {
    NSLog(@"[WexPyq] Plugin loaded");
    NSLog(@"[WexPyq] Current application: %@", [NSBundle mainBundle].bundleIdentifier);
}