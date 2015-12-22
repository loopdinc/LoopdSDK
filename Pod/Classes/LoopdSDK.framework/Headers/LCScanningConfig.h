//
//  LCScanningConfig.h
//  LoopdBadgeSDK
//
//  Created by Derrick Chao on 2015/8/25.
//  Copyright (c) 2015年 Loopd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCScanningConfig : NSObject

/**
 *  default is YES
 *  @discussion A Boolean indicating that the scan should run without duplicate filtering. By default, multiple discoveries of the
 *              same peripheral are coalesced into a single discovery event. Specifying this option will cause a discovery event to be generated
 *				every time the peripheral is seen, which may be many times per second. This can be useful in specific situations, such as making
 *				a connection based on a peripheral's RSSI, but may have an adverse affect on battery-life and application performance.
 */
@property (nonatomic) BOOL isAllowDuplicatesKey;

/**
 *  RSSI limit
 */
@property (nonatomic) NSInteger RSSI;

@end
