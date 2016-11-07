//
//  LCScanningConfig.m
//  LoopdBadgeSDK
//
//  Created by Derrick Chao on 2015/8/25.
//  Copyright (c) 2015年 Loopd. All rights reserved.
//

#import "LCScanningConfig.h"

@implementation LCScanningConfig

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _isAllowDuplicatesKey = YES;
    _RSSI = -999;
    
    return self;
}

@end
