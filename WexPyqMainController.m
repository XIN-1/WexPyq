#import "WexPyqMainController.h"
#import "WexPyqSingleFriendController.h"
#import "WexPyqMultipleFriendsController.h"
#import "WexPyqTagFriendsController.h"

@implementation WexPyqMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"朋友圈查询";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加关闭按钮
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(closeButtonTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    self.menuItems = @[
        @{@"title": @"查询单个好友", @"icon": @"👤", @"desc": @"查询指定好友的最近朋友圈"},
        @{@"title": @"查询多个好友", @"icon": @"👥", @"desc": @"批量查询多个好友的最近朋友圈"},
        @{@"title": @"查询标签好友", @"icon": @"🏷️", @"desc": @"查询某个标签下所有好友的最近朋友圈"}
    ];
    
    [self setupTableView];
}

- (void)closeButtonTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *item = self.menuItems[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", item[@"icon"], item[@"title"]];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.text = item[@"desc"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            WexPyqSingleFriendController *singleController = [[WexPyqSingleFriendController alloc] init];
            [self.navigationController pushViewController:singleController animated:YES];
            break;
        }
        case 1: {
            WexPyqMultipleFriendsController *multipleController = [[WexPyqMultipleFriendsController alloc] init];
            [self.navigationController pushViewController:multipleController animated:YES];
            break;
        }
        case 2: {
            WexPyqTagFriendsController *tagController = [[WexPyqTagFriendsController alloc] init];
            [self.navigationController pushViewController:tagController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

@end