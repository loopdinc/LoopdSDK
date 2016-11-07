//
//  LoopdHub.m
//  ScavengerHuntVia
//
//  Created by Allen Houng on 1/23/15.
//  Copyright (c) 2015 Loopd Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "LCBadge.h"



@interface LCBadge ()

@end


@implementation LCBadge

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

- (NSDictionary *)dictionaryRepresentation {
    unsigned int count = 0;
    // Get a list of all properties in the class.
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSString *value = [self valueForKey:key];
        
        // Only add to the NSDictionary if it's not nil.
        if (value)
            [dictionary setObject:value forKey:key];
    }
    
    free(properties);
    
    return dictionary;
}

#pragma mark - Unsync Single Badge

+ (void)unsyncBadge:(NSString *)badgeId eventAttendeeId:(NSString *)eventAttendeeId completion:(LoopdResultBlock)completion {
    [[self class] unsyncBadge:badgeId eventAttendeeId:eventAttendeeId isReturned:YES completion:completion];
}

+ (void)unsyncBadge:(NSString *)badgeId eventAttendeeId:(NSString *)eventAttendeeId isReturned:(BOOL)isReturned completion:(LoopdResultBlock)completion {
    NSString *currentEventId = [LCEventConfig currentEventConfig].eventId;
    NSString *relativePath = [NSString stringWithFormat:@"events/%@/badges/%@", currentEventId, badgeId];
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSDictionary *params = @{@"source": @"IOS_R",
                             @"sourceId": deviceId,
                             @"isReturned": @(isReturned)};
    
    [[self class] requestMethod:LCRequestMethodDELETE
                   relativePath:relativePath
                     parameters:params
                     completion:^(id responseObject, NSError *error) {
                         if (error) {
                             NSLog(@"unsyncSingleBadge error: %@", error);
                             NSLog(@"unsyncSingleBadge error responseObject: %@", responseObject);
                         }
                         
                         if (completion) {
                             completion(responseObject, error);
                         }
                     }];
}

@end
