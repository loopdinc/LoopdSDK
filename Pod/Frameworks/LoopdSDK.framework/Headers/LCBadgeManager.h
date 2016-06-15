//
//  LoopdCentralManager.h
//  Loopd
//
//  Created by Derrick Chao on 2015/2/13.
//  Copyright (c) 2015年 Loopd Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LCBadge;
@class LCBadgeManager;
@class LCScanningConfig;
@protocol LCBadgeManagerDelegate <NSObject>
@optional
- (void)badgeManager:(LCBadgeManager *)badgeManager didDiscoverBadge:(LCBadge *)badge;
- (void)badgeManager:(LCBadgeManager *)badgeManager didConnectBadge:(LCBadge *)badge;
- (void)badgeManager:(LCBadgeManager *)badgeManager didFailToConnectBadge:(LCBadge *)badge error:(NSError *)error;
- (void)badgeManager:(LCBadgeManager *)badgeManager didDisconnectBadge:(LCBadge *)badge error:(NSError *)error;
- (void)badgeManager:(LCBadgeManager *)badgeManager didUpdateValueForBadge:(LCBadge *)badge;
@end





@interface LCBadgeManager : NSObject

@property (weak, nonatomic) id <LCBadgeManagerDelegate> delegate;

/**
 *  Start scan nearby bluetooth devices.
 */
- (void)startScan;

/**
 *  Start scan nearby bluetooth devices with some limitations.
 *
 *  @param config Configuration for the badge manager.
 */
- (void)startScanWithConfig:(LCScanningConfig *)config;

/**
 *  Stop scan nearby bluetooth devices.
 */
- (void)stopScan;

/**
 *  Connect with the badge and read data from it.
 *
 *  @param badge Target badge object.
 */
- (void)connectBadge:(LCBadge *)badge;

/**
 *  Disconnect with the badge.
 */
- (void)disconnectBadge;

/**
 *  Write a command code into the badge. Need to connect with the badge first!
 *
 *  @param commandCode The command code you want to execute. For example: 0xff
 */
- (void)executeCommandCode:(NSString *)commandCode;

@end
