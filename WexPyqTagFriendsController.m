#import "WexPyqTagFriendsController.h"

@implementation WexPyqTagFriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查询标签好友";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 80) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.queryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.queryButton.frame = CGRectMake(20, self.view.bounds.size.height - 70, self.view.bounds.size.width - 40, 50);
    [self.queryButton setTitle:@"查询朋友圈" forState:UIControlStateNormal];
    self.queryButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
    [self.queryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.queryButton.layer.cornerRadius = 8;
    self.queryButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.queryButton addTarget:self action:@selector(queryMoments) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.queryButton];
    
    self.tagList = @[
        @{@"name": @"家人", @"icon": @"👨‍👩‍👧‍👦", @"count": @"5人", @"color": @"#FF6B6B"},
        @{@"name": @"同事", @"icon": @"💼", @"count": @"12人", @"color": @"#4ECDC4"},
        @{@"name": @"同学", @"icon": @"🎓", @"count": @"8人", @"color": @"#45B7D1"},
        @{@"name": @"朋友", @"icon": @"🤝", @"count": @"20人", @"color": @"#96CEB4"},
        @{@"name": @"客户", @"icon": @"💰", @"count": @"15人", @"color": @"#FFEAA7"},
        @{@"name": @"家人", @"icon": @"👨‍👩‍👧", @"count": @"3人", @"color": @"#DDA0DD"},
        @{@"name": @"运动", @"icon": @"🏃", @"count": @"6人", @"color": @"#98D8C8"}
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *tag = self.tagList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", tag[@"icon"], tag[@"name"]];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.text = tag[@"count"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    if ([self.selectedTag isEqualToString:tag[@"name"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *tag = self.tagList[indexPath.row];
    self.selectedTag = tag[@"name"];
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

#pragma mark - Actions

- (void)queryMoments {
    if (!self.selectedTag) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请先选择一个标签"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSDictionary *selectedTagInfo = nil;
    for (NSDictionary *tag in self.tagList) {
        if ([tag[@"name"] isEqualToString:self.selectedTag]) {
            selectedTagInfo = tag;
            break;
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"正在查询「%@」标签下 %@ 的最近朋友圈...", self.selectedTag, selectedTagInfo[@"count"]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"查询"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end