//
//  BadgeDetailVC.m
//  LoopdSDK_Demo
//
//  Created by Derrick Chao on 2015/12/21.
//  Copyright © 2015年 Loopd. All rights reserved.
//

#import <LoopdSDK/LoopdSDK.h>
#import "BadgeDetailVC.h"

@interface BadgeDetailVC () <LCBadgeManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *badgeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionsButton;
@end

@implementation BadgeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Badge Detail";
    
    self.actionsButton.enabled = NO;
    
    // try to connect the badge
    self.badgeManager.delegate = self;
    [self.badgeManager connectBadge:self.badge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.badgeManager disconnectBadge];
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

#pragma mark - UI

- (void)initUI {
    self.actionsButton.enabled = YES;
    self.actionsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.actionsButton.layer.borderWidth = 1;
    self.actionsButton.layer.cornerRadius = 5;
    
    self.badgeIdLabel.text = [NSString stringWithFormat:@"badge id: %@", self.badge.badgeId];
    
    self.badgeStatusLabel.text = [NSString stringWithFormat:@"status: %@", self.badge.manufacturerString];
}

#pragma mark - IBAction

- (IBAction)actionButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions"
                                                                             message:@"please choose one"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *turnOnRedLEDAction = [UIAlertAction actionWithTitle:@"Switch on Red Led" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"0F"];
    }];
    UIAlertAction *turnOffYellowLEDAction = [UIAlertAction actionWithTitle:@"Switch on Yellow Led" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"F0"];
    }];
    UIAlertAction *turnOnAllLEDAction = [UIAlertAction actionWithTitle:@"Switch Both Leds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"FF"];
    }];
    UIAlertAction *turnOffAllLEDAction = [UIAlertAction actionWithTitle:@"Switch off Both Leds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"00"];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:turnOnRedLEDAction];
    [alertController addAction:turnOffYellowLEDAction];
    [alertController addAction:turnOnAllLEDAction];
    [alertController addAction:turnOffAllLEDAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - Badge Manager Delegate

- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge {
    
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didConnectBadge:(LCBadge *)badge {
    self.connectionStatusLabel.text = @"Connected";
    
    [self initUI];
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didFailToConnectBadge:(LCBadge *)badge error:(NSError *)error {
    NSLog(@"didFailToConnectBadge error:%@", error);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
