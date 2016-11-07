//
//  LoopdHub.h
//  ScavengerHuntVia
//
//  Created by Allen Houng on 1/23/15.
//  Copyright (c) 2015 Loopd Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



typedef void (^LoopdResultBlock)(id responseObject, NSError *error);



@interface LCBadge : NSObject

/**
 *  The local name of the bluetooth device.
 */
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *badgeId;

/**
 *  The status of contact exchange
 */
@property (nonatomic, strong) NSString *manufacturerString;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@end
