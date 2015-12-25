# LoopdSDK

[![CI Status](http://img.shields.io/travis/Derrick/LoopdSDK.svg?style=flat)](https://travis-ci.org/Derrick/LoopdSDK)
[![Version](https://img.shields.io/cocoapods/v/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![License](https://img.shields.io/cocoapods/l/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![Platform](https://img.shields.io/cocoapods/p/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)

## Requirements
| Version | Minimum iOS Target  | 
|:--------------------:|:---------------------------:|
| 1.x | iOS 8 |

## Installation

LoopdSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LoopdSDK"
```

## Usage
Clone the repo, and the example project in the Example directory.
### LCBadgeManager
`LCBadgeManager` is a basic manager than help developer to control Loopd Badge.
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
You can also give some limitation to it!
```objective-c
// config
LCScanningConfig *scanningConfig = [LCScanningConfig new];
scanningConfig.RSSI = -50;
scanningConfig.isAllowDuplicatesKey = YES;
    
[self.badgeManager startScanWithConfig:scanningConfig];
```

Try to connect with the badge when did find the badge.
If it's done. You can execute some commands to the badge.
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
`LCContactExchangeManager` is a manager that help developer implement contact exchange more easier.
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
| 0F | Switch on red LED |
| F0 | Switch on yellow LED |
| FF | Switch on both LEDs |

Example:
```objective-c
- (void)turnOnBothLEDs {
    [self.badgeManager executeCommandCode:@"00"];
}
```

## Author

Derrick, derrick@getloopd.com

## License

LoopdSDK is available under the MIT license. See the LICENSE file for more info.
