//
//  ViewController.m
//  LoopdSDK_Demo
//
//  Created by Derrick Chao on 2015/12/21.
//  Copyright © 2015年 Loopd. All rights reserved.
//

#import "Loopd-iOS-SDK.h"
#import "ViewController.h"
#import "BadgeDetailVC.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, LCBadgeManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) LCBadgeManager *badgeManager;
@property (strong, nonatomic) NSMutableArray *badges;
@property (strong, nonatomic) NSMutableArray *tempBadges;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Badge List";
    
    [self.badgeManager startScan];
    
    // reload table every second
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reloadSelfTableView) userInfo:nil repeats:YES];
    
    // clean data every 1 mins
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(cleanBadges) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.badgeManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (LCBadgeManager *)badgeManager {
    if (!_badgeManager) {
        _badgeManager = [LCBadgeManager new];
        _badgeManager.delegate = self;
    }
    
    return _badgeManager;
}

- (NSMutableArray *)badges {
    if (!_badges) {
        _badges = [NSMutableArray new];
    }
    
    return _badges;
}

- (NSMutableArray *)tempBadges {
    if (!_tempBadges) {
        _tempBadges = [NSMutableArray new];
    }
    
    return _tempBadges;
}

#pragma mark - Custom Method

- (LCBadge *)findBadgeById:(NSString *)badgeId {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        LCBadge *badge = evaluatedObject;
        if ([badge.badgeId isEqualToString:badgeId]) {
            return YES;
        }
        
        return NO;
    }];
    
    NSArray *filteredArray = [self.tempBadges filteredArrayUsingPredicate:predicate];
    
    return filteredArray.firstObject;
}

- (void)reloadSelfTableView {
    NSArray *sortedArray = [self.tempBadges sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        LCBadge *badge1 = obj1;
        LCBadge *badge2 = obj2;
        
        return [badge1.badgeId compare:badge2.badgeId];
    }];
    
    [self.badges setArray:sortedArray];
    [self.tableView reloadData];
}

- (void)cleanBadges {
    [self.badges removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.badges.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = @"BadgeListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    LCBadge *badge = self.badges[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", badge.badgeId, (long)badge.rssi.integerValue];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LCBadge *badge = self.badges[indexPath.row];
    [self performSegueWithIdentifier:@"BadgeDetailVC" sender:badge];
}

#pragma mark - Badge Manager Delegate

- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge {
    NSLog(@"==============================================");
    NSLog(@"advertisementData: %@", badge.manufacturerString);
    NSLog(@"Discovered %@", badge.badgeId);
    
    
    // try to find an exist badge in self.badges
    LCBadge *existBadge = [self findBadgeById:badge.badgeId];
    if (existBadge) {
        [self.tempBadges removeObject:existBadge];
    }
    
    [self.tempBadges addObject:badge];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BadgeDetailVC"]) {
        BadgeDetailVC *badgeDetailVC = segue.destinationViewController;
        badgeDetailVC.badgeManager = self.badgeManager;
        badgeDetailVC.badge = sender;
    }
}

@end
