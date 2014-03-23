//
//  QSDataStore.m
//  CubeSale
//
//  Created by Ankit Jain on 16/03/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSDataStore.h"

#define QS_KEY(key)  [NSString stringWithFormat:@"com.qs.%@", key]


@implementation QSDataStore

+(void)storeObject:(id<NSCoding>)object forKey:(NSString*)key {
    if(!key) {
        assert("SLDataStore: storeObject: forKey: key cannot be null");
        return;
    }
    if(!object) {
        assert("SLDataStore: storeObject: Object cannot be null forKey:");
        return;
    }
    key = QS_KEY(key);
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}
+(id)retrieveObjectForKey:(NSString*)key {
    if(!key) {
        assert("SLDataStore: storeObject: forKey: key cannot be null");
        return nil;
    }
    key = QS_KEY(key);
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+(void)removeObjectForKey:(NSString *)key {
    if (!key) return;
    key = QS_KEY(key);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

+(void)syncronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
