#import <UIKit/UIKit.h>

@interface WexPyqSingleFriendController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *queryButton;
@property (nonatomic, strong) NSArray *friendList;
@property (nonatomic, strong) NSString *selectedFriendName;

@end