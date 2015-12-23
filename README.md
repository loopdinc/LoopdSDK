# LoopdSDK

[![CI Status](http://img.shields.io/travis/Derrick/LoopdSDK.svg?style=flat)](https://travis-ci.org/Derrick/LoopdSDK)
[![Version](https://img.shields.io/cocoapods/v/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![License](https://img.shields.io/cocoapods/l/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)
[![Platform](https://img.shields.io/cocoapods/p/LoopdSDK.svg?style=flat)](http://cocoapods.org/pods/LoopdSDK)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
@interface ContactExBgProcess () <LCContactExchangeManagerDelegate>
@property (strong, nonatomic) LCContactExchangeManager *contactExchangeManager;
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *badgeId = @"123abc";
    self.contactExchangeManager = [LCContactExchangeManager new];
    self.contactExchangeManager.delegate = self;
    [self.contactExchangeManager startScanningWithBadgeId:badgeId];
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

## Author

Derrick, derrick@getloopd.com

## License

LoopdSDK is available under the MIT license. See the LICENSE file for more info.
