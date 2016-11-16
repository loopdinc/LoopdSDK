//
//  LCContactExchangeManager.h
//  Loopd
//
//  Created by Derrick Chao on 2015/5/19.
//  Copyright (c) 2015年 Loopd Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCBadge;
@class LCContactExchangeManager;
@protocol LCContactExchangeManagerDelegate <NSObject>
@optional
- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager
                didDetectBadge:(LCBadge *)badge;

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager willContactExchangeWithBadge:(LCBadge *)badge;
- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager didContactExchangeWithBadge:(LCBadge *)badge;

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager didUpdateExchangedBadgeIds:(NSArray *)exchangedBadgeIds;

- (void)contactExchangeManager:(LCContactExchangeManager *)contactExchangeManager didUpdateExchangedBadgeIds:(NSArray *)exchangedBadgeIds targetBadge:(LCBadge *)targetBadge;
@end





@interface LCContactExchangeManager : NSObject

@property (weak, nonatomic) id <LCContactExchangeManagerDelegate> delegate;

/**
 *  Check is current device enable BlueTooth or not.
 *
 *  @return Return YES if current device enable BlueTooth.
 */
- (BOOL)isBlueToothEnabled;

/**
 *  Try to find a badge that close enough.
 *
 *  @param RSSI The current received signal strength indicator (RSSI) of the peripheral, in decibels.
 */
- (void)startDetectingWithinRSSI:(NSInteger)RSSI;

/**
 *  Start try to find a target badge with id = badgeId.
 *
 *  @param badgeId Target badge id.
 */
- (void)startScanningWithBadgeId:(NSString *)badgeId;
- (void)startScanningWithBadgeId:(NSString *)badgeId RSSI:(NSInteger)RSSI;

/**
 *  Stop!
 */
- (void)stopScanning;

@end
