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
    
//    UIAlertAction *turnOnRedLEDAction = [UIAlertAction actionWithTitle:@"Switch on Red Led" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.badgeManager executeCommandCode:@"0F"];
//    }];
//    UIAlertAction *turnOffYellowLEDAction = [UIAlertAction actionWithTitle:@"Switch on Yellow Led" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.badgeManager executeCommandCode:@"F0"];
//    }];
    UIAlertAction *turnOnAllLEDAction = [UIAlertAction actionWithTitle:@"Switch Both Leds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"FF"];
    }];
    UIAlertAction *turnOffAllLEDAction = [UIAlertAction actionWithTitle:@"Switch off Both Leds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"00"];
    }];
//    UIAlertAction *changeTransmissionPowerAction = [UIAlertAction actionWithTitle:@"Change transmission power" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self showChangeTransmissionPowerActionSheet];
//    }];
    UIAlertAction *forceTheDeviceDisconnectAction = [UIAlertAction actionWithTitle:@"Force the device to disconnect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"11"];
    }];
//    UIAlertAction *getMacAddressAction = [UIAlertAction actionWithTitle:@"Get the mac address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.badgeManager executeCommandCode:@"12"];
//    }];
//    UIAlertAction *getTheAmountOfFreeSpaceLeftAction = [UIAlertAction actionWithTitle:@"Get the amount of free space left" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.badgeManager executeCommandCode:@"14"];
//    }];
    UIAlertAction *changeTheAdvertisementFrequencyAction = [UIAlertAction actionWithTitle:@"Change the advertisement frequency" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changeTheAdvertisementFrequencyActionSheet];
    }];
//
//    // new commands
//    UIAlertAction *iBeaconModeAction = [UIAlertAction actionWithTitle:@"iBeacon mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self iBeaconModePressed];
//    }];
//    UIAlertAction *eddystoneModeAction = [UIAlertAction actionWithTitle:@"Eddystone mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self eddystoneModePressed];
//    }];
//    UIAlertAction *iBeaconEddystoneAlternativelyAction = [UIAlertAction actionWithTitle:@"iBeacon and Eddystone Alternatively" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self iBeaconAndEddystoneModePressed];
//    }];
    UIAlertAction *customAction = [UIAlertAction actionWithTitle:@"Custom command" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self customActionPressed];
    }];
    
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
//    [alertController addAction:turnOnRedLEDAction];
//    [alertController addAction:turnOffYellowLEDAction];
    [alertController addAction:turnOnAllLEDAction];
    [alertController addAction:turnOffAllLEDAction];
    
//    [alertController addAction:changeTransmissionPowerAction];
    [alertController addAction:forceTheDeviceDisconnectAction];
//    [alertController addAction:getMacAddressAction];
//    [alertController addAction:getTheAmountOfFreeSpaceLeftAction];
    [alertController addAction:changeTheAdvertisementFrequencyAction];
    
//    [alertController addAction:iBeaconModeAction];
//    [alertController addAction:eddystoneModeAction];
//    [alertController addAction:iBeaconEddystoneAlternativelyAction];
    [alertController addAction:customAction];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)showChangeTransmissionPowerActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions"
                                                                             message:@"please choose one"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *plus4Action = [UIAlertAction actionWithTitle:@"+4dBm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"100004"];
    }];
    UIAlertAction *minus4Action = [UIAlertAction actionWithTitle:@"-4dBm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"10FF04"];
    }];
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:plus4Action];
    [alertController addAction:minus4Action];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)changeTheAdvertisementFrequencyActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions"
                                                                             message:@"please choose one"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *advertise1TimesPerSecondAction = [UIAlertAction actionWithTitle:@"advertise 1 times per second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"A001"];
    }];
    UIAlertAction *advertise2TimesPerSecondAction = [UIAlertAction actionWithTitle:@"advertise 2 times per second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"A002"];
    }];
    UIAlertAction *advertise4TimesPerSecondAction = [UIAlertAction actionWithTitle:@"advertise 4 times per second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"A004"];
    }];
    UIAlertAction *advertise8TimesPerSecondAction = [UIAlertAction actionWithTitle:@"advertise 8 times per second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"A008"];
    }];
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:advertise1TimesPerSecondAction];
    [alertController addAction:advertise2TimesPerSecondAction];
    [alertController addAction:advertise4TimesPerSecondAction];
    [alertController addAction:advertise8TimesPerSecondAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)iBeaconModePressed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"iBeacon mode"
                                                                             message:@"please enter command"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // add text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"80FFEEDDCCBBAA99887766554433221100ABCD";
    }];
    
    // actions
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    // add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *commandTextField = alertController.textFields.firstObject;
        [self.badgeManager executeCommandCode:commandTextField.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)eddystoneModePressed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Eddystone mode"
                                                                             message:@"please enter command"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // add text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"9000CEAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBB";
    }];
    
    // actions
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    // add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *commandTextField = alertController.textFields.firstObject;
        [self.badgeManager executeCommandCode:commandTextField.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)iBeaconAndEddystoneModePressed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Advertise iBeacon and Eddystone alternatively"
                                                                             message:@"please choose one action"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *iBeaconAdvertisementAction = [UIAlertAction actionWithTitle:@"iBeacon advertisement" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"8900"];
    }];
    UIAlertAction *eddystoneAdvertismentAction = [UIAlertAction actionWithTitle:@"Eddystone advertisment" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"8901"];
    }];
    UIAlertAction *alternateAdvertisementAction = [UIAlertAction actionWithTitle:@"alternate advertisement of iBeacon and Eddystone" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.badgeManager executeCommandCode:@"89ff"];
    }];
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:iBeaconAdvertisementAction];
    [alertController addAction:eddystoneAdvertismentAction];
    [alertController addAction:alternateAdvertisementAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)customActionPressed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Custom Command"
                                                                             message:@"please enter command"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // add text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    // actions
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    // add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *commandTextField = alertController.textFields.firstObject;
        [self.badgeManager executeCommandCode:commandTextField.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
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

- (void)badgeManager:(LCBadgeManager *)badgeManager didUpdateValueForBadge:(LCBadge *)badge {
    NSString *currentCommand = [[NSString alloc] initWithBytes:[badge.characteristic.value bytes] length:badge.characteristic.value.length encoding:NSUTF8StringEncoding];
    
    NSLog(@"didUpdateValueForBadge");
    NSLog(@"currentCommand: %@", currentCommand);
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
