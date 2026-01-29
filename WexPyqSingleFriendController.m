#import "WexPyqSingleFriendController.h"

@implementation WexPyqSingleFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查询单个好友";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
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
    
    self.friendList = @[
        @{@"name": @"张三", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"李四", @"avatar": @"👩", @"status": @"离线"},
        @{@"name": @"王五", @"avatar": @"👨", @"status": @"在线"},
        @{@"name": @"赵六", @"avatar": @"👩", @"status": @"忙碌"},
        @{@"name": @"孙七", @"avatar": @"👨", @"status": @"在线"}
    ];
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