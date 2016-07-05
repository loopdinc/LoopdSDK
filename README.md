# iOS-Loopd-SDK

[![CI Status](http://img.shields.io/travis/Derrick/LoopdSDK.svg?style=flat)](https://travis-ci.org/Derrick/LoopdSDK)
[![Version](https://img.shields.io/cocoapods/v/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![License](https://img.shields.io/cocoapods/l/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![Platform](https://img.shields.io/cocoapods/p/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)

## Description
The Loopd Beacon SDK provides apis to interact with the Loopd Beacons from Android/iOS devices, and includes ranging, connecting, and writing and reading data between Loopd Beacons.

## Requirements
| Version | Minimum iOS Target  |
|:--------------------:|:---------------------------:|
| 1.x | iOS 8 |

## Installation

<!--LoopdSDK is available through [CocoaPods](http://cocoapods.org). To install-->
<!--it, simply add the following line to your Podfile:-->

<!--```ruby-->
<!--pod "LoopdSDK"-->
<!--```-->

Drag the ./Pod/LoopdSDK.framework file into your project.


## Usage
Clone the repo, and the example project in the Example directory.
### LCBadgeManager
`LCBadgeManager` is a basic manager than helps the developer to control the Loopd Badge.
```objective-c
@interface ViewController () <LCBadgeManagerDelegate>
@property (strong, nonatomic) LCBadgeManager *badgeManager;
@end

- (void)viewDidLoad {
    [super viewDidLoad];

    self.badgeManager = [LCBadgeManager new];
    self.badgeManager.delegate = self;
    [self.badgeManager startScan];
}
```
You can also give limitations to it.
```objective-c
// config
LCScanningConfig *scanningConfig = [LCScanningConfig new];
scanningConfig.RSSI = -50;
scanningConfig.isAllowDuplicatesKey = YES;

[self.badgeManager startScanWithConfig:scanningConfig];
```

Try to connect with the badge.
When connected, you can execute commands to the badge.
```objective-c
#pragma mark - Badge Manager Delegate

- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge {
    [self.badgeManager connectBadge:badge];
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didConnectBadge:(LCBadge *)badge {
    // turn on red LED
    [self.badgeManager executeCommandCode:@"0F"];
}
```


### LCBadgeManagerDelegate
```objective-c
@protocol LCBadgeManagerDelegate <NSObject>
@optional
- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge;
- (void)badgeManager:(LCBadgeManager *)badgeManager didConnectBadge:(LCBadge *)badge;
- (void)badgeManager:(LCBadgeManager *)badgeManager didFailToConnectBadge:(LCBadge *)badge error:(NSError *)error;
- (void)badgeManager:(LCBadgeManager *)badgeManager didDisconnectBadge:(LCBadge *)badge error:(NSError *)error;
- (void)badgeManager:(LCBadgeManager *)badgeManager didUpdateValueForBadge:(LCBadge *)badge;
@end
```

### LCContactExchangeManager
`LCContactExchangeManager` is a manager that helps the developer implement contact exchange easily.
```objective-c
@interface ViewController () <LCContactExchangeManagerDelegate>
@property (strong, nonatomic) LCContactExchangeManager *contactExchangeManager;
@end

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *badgeId = @"123abc";
    self.contactExchangeManager = [LCContactExchangeManager new];
    self.contactExchangeManager.delegate = self;
    [self.contactExchangeManager startScanningWithBadgeId:badgeId];
}

#pragma mark - Contact Exchange Manager Delegate

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager
    didUpdateExchangedBadgeIds:(NSArray *)exchangedBadgeIds
                   targetBadge:(LCBadge *)targetBadge {
    // targetBadge is the current badge
    // exchangedBadgeIds is the array of other user's badge id
}

```
### LCContactExchangeManagerDelegate
```objective-c
@protocol LCContactExchangeManagerDelegate <NSObject>
@optional
- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager
                didDetectBadge:(LCBadge *)badge;

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager
    didUpdateExchangedBadgeIds:(NSArray *)exchangedBadgeIds;

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager
    didUpdateExchangedBadgeIds:(NSArray *)exchangedBadgeIds
                   targetBadge:(LCBadge *)targetBadge;
@end
```

## Commands
| command | action  |
|:-------:|:-------:|
| 00 | Switch off both LEDs |
<!--| 0F | Switch on red LED |-->
<!--| F0 | Switch on yellow LED |-->
| FF | Switch on both LEDs |
| 11 | Force the device to disconnect |
| A0xx | advertise xx times per second |
| 07 | Read contact exchange data |
<!--| 100004 | Change transmission power +4dBm |-->
<!--| 10FF04 | Change transmission power -4dBm |-->
<!--| 12 |  Get the mac address <br /> Write 0x12 to the characteristic to get 12 byte MAC address (AA:BB:CC:DD:EE:FF)-->
<!--The notification is 0x12AABBCCDDEEFF |-->
<!--| 14 |  Get the amount of free space left <br /> Write 0x14, and the notification it will return will be 0x144060. This translates to 0x6040 = 24640 bytes of memory is free. |-->
<!--| 20 |  Set the Local Name of the device <br /> Write 0x20 + 8 bytes (Hex conversion of the ASCII) |-->
<!--| 80 |  iBeacon mode <br /> 0x80+16 bytes of Data + 1byte Major ID + 1 byte Minor ID |-->
<!--| 90 |  Eddystone mode <br /> 0x90+1 byte Frame Type + PDU based on Frame type |-->
<!--| 89 |  Advertise iBeacon and Eddystone Alternatively |-->


Example:
```objective-c
- (void)turnOnBothLEDs {
    [self.badgeManager executeCommandCode:@"00"];
}

- (void)advertise4timesPerSecond {
    [self.badgeManager executeCommandCode:@"A004"];
}

- (void)advertise8timesPerSecond {
    [self.badgeManager executeCommandCode:@"A008"];
}

- (void)iBeaconExample {
    // 0x80+16 bytes of Data + 1byte Major ID + 1 byte Minor ID
    [self.badgeManager executeCommandCode:@"80FFEEDDCCBBAA99887766554433221100ABCD"];
}

- (void)eddystoneExample {
    // 0x90+1 byte Frame Type + PDU based on Frame type
    [self.badgeManager executeCommandCode:@"9000CEAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBB"];
}
```

## Author

Derrick Chao, derrick@getloopd.com

## License

LoopdSDK is available under the MIT license. See the LICENSE file for more info.
