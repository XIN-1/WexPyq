#import "WexPyqSingleFriendController.h"

@implementation WexPyqSingleFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查询单个好友";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(backButtonTapped)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self setupUI];
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 56)];
    self.searchBar.placeholder = @"搜索好友昵称";
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 56, self.view.bounds.size.width, self.view.bounds.size.height - 56 - 80) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.queryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.queryButton.frame = CGRectMake(20, self.view.bounds.size.height - 70, self.view.bounds.size.width - 40, 50);
    [self.queryButton setTitle:@"查询朋友圈" forState:UIControlStateNormal];
    self.queryButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    [self.queryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.queryButton.layer.cornerRadius = 8;
    self.queryButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.queryButton addTarget:self action:@selector(queryMoments) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.queryButton];
    
    // 尝试读取微信真实好友列表
    self.friendList = [self getWeChatFriends];
    if (!self.friendList || self.friendList.count == 0) {
        // 如果读取失败，使用模拟数据
        self.friendList = @[
            @{@"name": @"张三", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"李四", @"avatar": @"👩", @"status": @"离线"},
            @{@"name": @"王五", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"赵六", @"avatar": @"👩", @"status": @"忙碌"},
            @{@"name": @"孙七", @"avatar": @"👨", @"status": @"在线"}
        ];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *friend = self.friendList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend[@"avatar"], friend[@"name"]];
    cell.detailTextLabel.text = friend[@"status"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if ([self.selectedFriendName isEqualToString:friend[@"name"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *friend = self.friendList[indexPath.row];
    self.selectedFriendName = friend[@"name"];
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.friendList = @[
            @{@"name": @"张三", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"李四", @"avatar": @"👩", @"status": @"离线"},
            @{@"name": @"王五", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"赵六", @"avatar": @"👩", @"status": @"忙碌"},
            @{@"name": @"孙七", @"avatar": @"👨", @"status": @"在线"}
        ];
    } else {
        NSArray *allFriends = @[
            @{@"name": @"张三", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"李四", @"avatar": @"👩", @"status": @"离线"},
            @{@"name": @"王五", @"avatar": @"👨", @"status": @"在线"},
            @{@"name": @"赵六", @"avatar": @"👩", @"status": @"忙碌"},
            @{@"name": @"孙七", @"avatar": @"👨", @"status": @"在线"}
        ];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        self.friendList = [allFriends filteredArrayUsingPredicate:predicate];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (NSArray *)getWeChatFriends {
    NSMutableArray *friends = [NSMutableArray array];
    
    @try {
        // 尝试查找微信的好友列表类
        Class CContactMgrClass = NSClassFromString(@"CContactMgr");
        if (CContactMgrClass) {
            // 尝试获取单例
            SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
            id contactMgr = nil;
            if ([CContactMgrClass respondsToSelector:sharedManagerSelector]) {
                contactMgr = [CContactMgrClass performSelector:sharedManagerSelector];
            }
            
            if (contactMgr) {
                // 尝试获取好友列表
                SEL getAllContactsSelector = NSSelectorFromString(@"getAllContacts");
                NSArray *allContacts = nil;
                if ([contactMgr respondsToSelector:getAllContactsSelector]) {
                    allContacts = [contactMgr performSelector:getAllContactsSelector];
                }
                
                if (allContacts && [allContacts isKindOfClass:[NSArray class]]) {
                    for (id contact in allContacts) {
                        // 尝试获取好友信息
                        SEL userNameSelector = NSSelectorFromString(@"userName");
                        SEL nickNameSelector = NSSelectorFromString(@"nickName");
                        
                        NSString *userName = nil;
                        NSString *nickName = nil;
                        
                        if ([contact respondsToSelector:userNameSelector]) {
                            userName = [contact performSelector:userNameSelector];
                        }
                        if ([contact respondsToSelector:nickNameSelector]) {
                            nickName = [contact performSelector:nickNameSelector];
                        }
                        
                        if (userName && nickName) {
                            // 排除特殊账号和自己
                            if (![userName hasPrefix:@"wxid_"] && ![userName isEqualToString:@"filehelper"]) {
                                NSDictionary *friendInfo = @{
                                    @"name": nickName,
                                    @"avatar": @"👤",
                                    @"status": @"在线"
                                };
                                [friends addObject:friendInfo];
                            }
                        }
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"[WexPyq] Exception when getting WeChat friends: %@", exception);
    }
    
    return friends;
}

- (void)queryMoments {
    if (!self.selectedFriendName) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请先选择一个好友"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"查询"
                                                                   message:[NSString stringWithFormat:@"正在查询 %@ 的最近朋友圈...", self.selectedFriendName]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end