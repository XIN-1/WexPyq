#import <UIKit/UIKit.h>

@interface WexPyqTagFriendsController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *queryButton;
@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, strong) NSString *selectedTag;

@end