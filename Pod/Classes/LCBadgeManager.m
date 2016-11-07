//
//  LoopdCentralManager.m
//  Loopd
//
//  Created by Derrick Chao on 2015/2/13.
//  Copyright (c) 2015年 Loopd Inc. All rights reserved.
//

@import CoreBluetooth;
#import "LCBadgeManager.h"
#import "LCBadge.h"
#import "LCScanningConfig.h"

#define SERVICE_UUID                @"FB694B90-F49E-4597-8306-171BBA78F846"



@interface LCBadgeManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) LCBadge *currentBadge;
@property (nonatomic) LCScanningConfig *scanningConfig;
@end





@implementation LCBadgeManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static LCBadgeManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LCBadgeManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Property Lazy Loading

- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:globalQueue];
    }
    
    return _centralManager;
}

- (LCScanningConfig *)scanningConfig {
    if (!_scanningConfig) {
        _scanningConfig = [LCScanningConfig new];
    }
    
    return _scanningConfig;
}

#pragma mark - Instance Method

- (void)startScan {
    [self startScanWithConfig:nil];
}

- (void)startScanWithConfig:(LCScanningConfig *)config {
    self.scanningConfig = config;
    CBCentralManagerState state = (CBCentralManagerState)[self.centralManager state];
    if (state == CBCentralManagerStatePoweredOn) {
        [self retryScan];
    }
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)retryScan {
    if (self.currentBadge) {
        self.currentBadge = nil;
    }
    [self stopScan];
    
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    NSNumber *isAllowDuplicatesKey = [NSNumber numberWithBool:self.scanningConfig.isAllowDuplicatesKey];
    [self.centralManager scanForPeripheralsWithServices:@[uuid]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:isAllowDuplicatesKey}];
}

- (void)connectBadge:(LCBadge *)badge {
    NSParameterAssert(badge != nil);
    @synchronized(self) {
        if (!self.currentBadge) {
            NSLog(@"connectBadge: %@", badge.badgeId);
            self.currentBadge = badge;
            [self.centralManager connectPeripheral:badge.peripheral options:nil];
        }
    }
}

- (void)disconnectBadge {
    if (self.currentBadge) {
        [self.centralManager cancelPeripheralConnection:self.currentBadge.peripheral];
    }
}

- (void)readValue {
    if (self.currentBadge && self.currentBadge.characteristic) {
        [self.currentBadge.peripheral readValueForCharacteristic:self.currentBadge.characteristic];
    }
}

#pragma mark Command

- (void)executeCommandCode:(NSString *)commandCode {
    [self execute:self.currentBadge.characteristic commandCode:commandCode];
}

- (void)execute:(CBCharacteristic *)characteristic commandCode:(NSString *)commandCode {
    NSLog(@"<<< execute command %@ >>>", commandCode);
    
    // need check command code is valid
    
    // need to check already connect to a badge
    
    NSMutableString *wholeCommand = [[NSString stringWithFormat:@"%@", commandCode] mutableCopy];
    
    NSInteger bytesLeft = 24 - wholeCommand.length;
    for(NSInteger i = 0; i <= bytesLeft; i++) {
        [wholeCommand appendString:@"0"];
    }
    
    NSMutableData *commandData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([wholeCommand length] / 2); i++) {
        byte_chars[0] = [wholeCommand characterAtIndex:i*2];
        byte_chars[1] = [wholeCommand characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandData appendBytes:&whole_byte length:1];
    }
    
    [self.currentBadge.peripheral writeValue:commandData
                           forCharacteristic:characteristic
                                        type:CBCharacteristicWriteWithResponse];
    
    //NSData *dataInData = [self.dataInTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    //[self.peripheral writeValue:dataInData forCharacteristic:self.dataInCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - CBCentral Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"Central Manager Powered On!");
            [self retryScan];
            break;
        }
        case CBCentralManagerStatePoweredOff: {
            NSLog(@"Central Manager Powered Off!");
            break;
        }
        case CBCentralManagerStateResetting: {
            NSLog(@"Central Manager Resetting!");
            break;
        }
        case CBCentralManagerStateUnauthorized: {
            NSLog(@"Central Manager Unauthorized!");
            break;
        }
        case CBCentralManagerStateUnknown: {
            NSLog(@"Central Manager Unknown!");
            break;
        }
        case CBCentralManagerStateUnsupported: {
            NSLog(@"Central Manager Unsupported!");
            break;
        }
        default: {
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
//    NSLog(@"==============================================");
//    NSLog(@"Local name: %@", advertisementData[CBAdvertisementDataLocalNameKey]);
//    NSLog(@"Discovered %@", peripheral.name);
//    NSLog(@"CBAdvertisementDataManufacturerDataKey: %@", advertisementData[CBAdvertisementDataManufacturerDataKey]);
//    NSLog(@"Peripheral RSSI: %@", RSSI);
//    NSLog(@"advertisementData: %@", advertisementData);
    
    NSString *discoveredBadgeId = [advertisementData[CBAdvertisementDataLocalNameKey] description];
    NSString *manufacturerString = [advertisementData[CBAdvertisementDataManufacturerDataKey] description];
    
    if (RSSI.integerValue > self.scanningConfig.RSSI
        && RSSI.integerValue < 0
        && discoveredBadgeId) {
        LCBadge *badge = [LCBadge new];
        badge.name = peripheral.name;
        badge.badgeId = discoveredBadgeId;
        badge.manufacturerString = manufacturerString;
        badge.rssi = RSSI;
        badge.peripheral = peripheral;
        
        if ([self.delegate respondsToSelector:@selector(badgeManager:didDiscoverBadge:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // put delegate here, so the delegate perform in main thread.
                [self.delegate badgeManager:self didDiscoverBadge:badge];
            });
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectBadge: %@", self.currentBadge.badgeId);
    self.currentBadge.peripheral.delegate = self;
    [self.currentBadge.peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectBadge: %@", self.currentBadge.badgeId);
    if ([self.delegate respondsToSelector:@selector(badgeManager:didFailToConnectBadge:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate badgeManager:self didFailToConnectBadge:self.currentBadge error:error];
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectBadge: %@", self.currentBadge.badgeId);
    if (!error) {
        NSLog(@"DISCONNECT SUCCESS!");
    } else {
        NSLog(@"WARNING: %@", error);
    }
    
    self.currentBadge = nil;
    
    [self retryScan];
    
    if ([self.delegate respondsToSelector:@selector(badgeManager:didDisconnectBadge:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate badgeManager:self didDisconnectBadge:self.currentBadge error:error];
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
}

#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverBadge: %@", self.currentBadge.badgeId);
    if (!error) {
        [peripheral discoverCharacteristics:nil forService:peripheral.services.firstObject];
    } else {
        NSLog(@"peripheral didDiscoverServices error: %@", error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    [peripheral setNotifyValue:YES forCharacteristic:service.characteristics.firstObject];
    CBCharacteristic *currentCharacteristic = service.characteristics.firstObject;
    self.currentBadge.characteristic = currentCharacteristic;
    
    // connect badge done
    if ([self.delegate respondsToSelector:@selector(badgeManager:didConnectBadge:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate badgeManager:self didConnectBadge:self.currentBadge];
        });
    }
    
    // descriptor
    [peripheral discoverDescriptorsForCharacteristic:currentCharacteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"peripheral Characteristic value : %@ with ID %@", characteristic.value, characteristic.UUID);
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(badgeManager:didUpdateValueForBadge:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate badgeManager:self didUpdateValueForBadge:self.currentBadge];
            });
        }
    } else {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"characteristic.descriptors: %@", characteristic.descriptors);
    
    if (characteristic.descriptors.count > 0) {
        for (CBDescriptor *descriptor in characteristic.descriptors) {
            NSLog(@"descriptor: %@", descriptor);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

@end
