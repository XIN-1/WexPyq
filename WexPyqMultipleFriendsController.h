#import <UIKit/UIKit.h>

@interface WexPyqMultipleFriendsController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *queryButton;
@property (nonatomic, strong) UIButton *selectAllButton;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) NSMutableSet *selectedFriends;

@end