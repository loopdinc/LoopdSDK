//
//  LCContactExchangeManager.m
//  Loopd
//
//  Created by Derrick Chao on 2015/5/19.
//  Copyright (c) 2015年 Loopd Inc. All rights reserved.
//

@import CoreBluetooth;
#import "LCContactExchangeManager.h"
#import "LCBadgeManager.h"
#import "LCBadge.h"
#import "LCScanningConfig.h"
#import "LCReachability.h"

#define kTestBadgeId        @"FFD7C016"

#define kScanAllowDuplicatedKey      @NO

typedef NS_ENUM(NSInteger, ScanMode) {
    ScanModePair,
    ScanModeContactExchange
};

@interface LCContactExchangeManager () <LCBadgeManagerDelegate>
@property (strong, nonatomic) LCBadgeManager *badgeManager;
@property (strong, nonatomic) NSMutableArray *exchangedBadgeIds;
@property (strong, nonatomic) NSString *badgeId;
@property (nonatomic) NSInteger rssiLimit;
@property (nonatomic) ScanMode scanMode;
@end

@implementation LCContactExchangeManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static LCContactExchangeManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LCContactExchangeManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Property Lazy Loading

- (LCBadgeManager *)badgeManager {
    if (!_badgeManager) {
        _badgeManager = [LCBadgeManager new];
        _badgeManager.delegate = self;
    }
    
    return _badgeManager;
}

- (NSMutableArray *)exchangedBadgeIds {
    if (!_exchangedBadgeIds) {
        _exchangedBadgeIds = [NSMutableArray new];
    }
    
    return _exchangedBadgeIds;
}

#pragma mark - Instance Method

- (BOOL)isBlueToothEnabled {
    return NO;
}

- (void)startDetectingWithinRSSI:(NSInteger)RSSI {
    self.scanMode = ScanModePair;
    
    // config
    LCScanningConfig *scanningConfig = [LCScanningConfig new];
    scanningConfig.RSSI = RSSI;
    scanningConfig.isAllowDuplicatesKey = YES;
    
    [self.badgeManager startScanWithConfig:scanningConfig];
}

- (void)startScanningWithBadgeId:(NSString *)badgeId {
    [self startScanningWithBadgeId:badgeId RSSI:-999];
}

- (void)startScanningWithBadgeId:(NSString *)badgeId RSSI:(NSInteger)RSSI {
    self.scanMode = ScanModeContactExchange;
    self.badgeId = badgeId;
    
    // config
    LCScanningConfig *scanningConfig = [LCScanningConfig new];
    scanningConfig.isAllowDuplicatesKey = YES;
    scanningConfig.RSSI = RSSI;
    [self.badgeManager startScanWithConfig:scanningConfig];
}

- (void)stopScanning {
    [self.badgeManager stopScan];
}

#pragma mark - Badge Manager Delegate

- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge {
    switch (self.scanMode) {
        case ScanModePair: {
            [self stopScanning];
            
            if ([self.delegate respondsToSelector:@selector(contactExchangeManager:didDetectBadge:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contactExchangeManager:self didDetectBadge:badge];
                });
            }
            break;
        }
            
        case ScanModeContactExchange: {
            if ([self.delegate respondsToSelector:@selector(contactExchangeManager:didDetectBadge:)]) {
                [self.delegate contactExchangeManager:self didDetectBadge:badge];
            }
            
            LCReachability *reachability = [LCReachability reachabilityForInternetConnection];
            LCNetworkStatus networkStatus = [reachability currentReachabilityStatus];
            if (networkStatus == LCNotReachable) {
                return;
            }
            
            if (self.badgeId && [badge.badgeId isEqualToString:self.badgeId] && [badge.manufacturerString isEqualToString:@"<01>"]) {
                [self stopScanning];
                [self.exchangedBadgeIds setArray:@[]];
                if ([self.delegate respondsToSelector:@selector(contactExchangeManager:willContactExchangeWithBadge:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate contactExchangeManager:self willContactExchangeWithBadge:badge];
                    });
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.badgeManager connectBadge:badge];
                });
            } else if (!self.badgeId && [badge.manufacturerString isEqualToString:@"<01>"]) {
                [self stopScanning];
                [self.exchangedBadgeIds setArray:@[]];
                if ([self.delegate respondsToSelector:@selector(contactExchangeManager:willContactExchangeWithBadge:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate contactExchangeManager:self willContactExchangeWithBadge:badge];
                    });
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.badgeManager connectBadge:badge];
                });
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didConnectBadge:(LCBadge *)badge {
    [badge.peripheral readValueForCharacteristic:badge.characteristic];
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didUpdateValueForBadge:(LCBadge *)badge {
    NSString *rawCommand = [badge.characteristic.value description];
    NSString *currentCommand = [[NSString alloc] initWithBytes:[badge.characteristic.value bytes] length:badge.characteristic.value.length encoding:NSUTF8StringEncoding];
    NSString *commandCode;
    if (rawCommand.length > 9) {
        commandCode = [rawCommand substringWithRange:NSMakeRange(1, 8)];
    } else if (rawCommand.length == 4) {
        commandCode = [rawCommand substringWithRange:NSMakeRange(1, 2)];
        commandCode = [commandCode stringByAppendingString:@"000000"];
    } else {
        // write 0x11 to disconnect with badge
        [self.badgeManager executeCommandCode:LCBadgeDisconnectCommand];
//        [self.badgeManager disconnectBadge];
        if (self.scanMode == ScanModeContactExchange) {
            [self startScanningWithBadgeId:self.badgeId];
        }
    }
    NSLog(@"\n============ THE LAST COMMAND ===============\nrawCommand: %@\ncommandCode: %@", rawCommand, commandCode);
    
    if ([commandCode isEqualToString:@"07000000"] || [commandCode isEqualToString:@"11000000"] || [commandCode isEqualToString:@"00000000"]) {
        [self.badgeManager executeCommandCode:LCBadgeReadContactExchangeDataCommand];
        
        // reset after delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            NSLog(@"self.exchangedBadgeIds: %@", self.exchangedBadgeIds);
            if ([self.delegate respondsToSelector:@selector(contactExchangeManager:didUpdateExchangedBadgeIds:targetBadge:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contactExchangeManager:self
                               didUpdateExchangedBadgeIds:self.exchangedBadgeIds
                                              targetBadge:badge];
                });
            }
            
            if ([self.delegate respondsToSelector:@selector(contactExchangeManager:didUpdateExchangedBadgeIds:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contactExchangeManager:self
                               didUpdateExchangedBadgeIds:self.exchangedBadgeIds];
                });
            }
            
            if ([self.delegate respondsToSelector:@selector(contactExchangeManager:didContactExchangeWithBadge:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contactExchangeManager:self didContactExchangeWithBadge:badge];
                });
            }
            
            // write 0x11 to disconnect with badge
            [self.badgeManager executeCommandCode:LCBadgeDisconnectCommand];
            
            // if try to scan all nearby badges
            if (self.scanMode == ScanModeContactExchange && self.badgeId == nil) {
                [self startScanningWithBadgeId:self.badgeId];
            }
        });
    } else {
        currentCommand = [currentCommand stringByReplacingOccurrencesOfString:@"\a" withString:@""];
        if (![currentCommand isEqualToString:@""] && currentCommand) {
            [self.exchangedBadgeIds addObject:currentCommand];
        }
    }
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didFailToConnectBadge:(LCBadge *)badge error:(NSError *)error {
    NSLog(@"didFailToConnectBadge!!!!!!");
    // connect fail, let's retry scan again!!!
    [self startScanningWithBadgeId:self.badgeId];
}

- (void)badgeManager:(LCBadgeManager *)badgeManager didDisconnectBadge:(LCBadge *)badge error:(NSError *)error {
    if (error) {
        // fail disconnect
        
    }
}

@end
