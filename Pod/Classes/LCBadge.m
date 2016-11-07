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

@end
