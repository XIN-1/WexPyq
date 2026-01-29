#import "WexPyqMultipleFriendsController.h"

@implementation WexPyqMultipleFriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查询多个好友";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.selectedFriends = [NSMutableSet set];
    
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 130) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.selectAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectAllButton.frame = CGRectMake(20, self.view.bounds.size.height - 120, self.view.bounds.size.width - 40, 50);
    [self.selectAllButton setTitle:@"全选/取消全选" forState:UIControlStateNormal];
    self.selectAllButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    [self.selectAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectAllButton.layer.cornerRadius = 8;
    self.selectAllButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.selectAllButton addTarget:self action:@selector(toggleSelectAll) forControlEvents:UIControlEventTouchUpInside];
    
    self.queryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.queryButton.frame = CGRectMake(20, self.view.bounds.size.height - 60, self.view.bounds.size.width - 40, 50);
    [self.queryButton setTitle:@"查询朋友圈" forState:UIControlStateNormal];
    self.queryButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:1.0];
    [self.queryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.queryButton.layer.cornerRadius = 8;
    self.queryButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.queryButton addTarget:self action:@selector(queryMoments) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.selectAllButton];
    [self.view addSubview:self.queryButton];
    
    self.friendList = [NSMutableArray arrayWithArray:@[
        @{@"name": @"张三", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"李四", @"avatar": @"👩", @"status": @"离线"},
        @{@"name": @"王五", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"赵六", @"avatar": @"👩", @"status": @"忙碌"},
        @{@"name": @"孙七", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"周八", @"avatar": @"👩", @"status": @"离线"},
        @{@"name": @"吴九", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"郑十", @"avatar": @"👩", @"status": @"忙碌"}
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MultipleFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *friend = self.friendList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend[@"avatar"], friend[@"name"]];
    cell.detailTextLabel.text = friend[@"status"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if ([self.selectedFriends containsObject:friend[@"name"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:1.0 alpha:1.0];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *friend = self.friendList[indexPath.row];
    
    if ([self.selectedFriends containsObject:friend[@"name"]]) {
        [self.selectedFriends removeObject:friend[@"name"]];
    } else {
        [self.selectedFriends addObject:friend[@"name"]];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Actions

- (void)toggleSelectAll {
    if (self.selectedFriends.count == self.friendList.count) {
        [self.selectedFriends removeAllObjects];
    } else {
        for (NSDictionary *friend in self.friendList) {
            [self.selectedFriends addObject:friend[@"name"]];
        }
    }
    
    [self.tableView reloadData];
}

- (void)queryMoments {
    if (self.selectedFriends.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请至少选择一个好友"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"正在查询 %lu 个好友的最近朋友圈...", (unsigned long)self.selectedFriends.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"查询"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end