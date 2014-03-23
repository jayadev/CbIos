//
//  QSDataStore.h
//  CubeSale
//
//  Created by Ankit Jain on 16/03/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSDataStore : NSObject

+(void)storeObject:(id<NSCoding>)object forKey:(NSString*)key;
+(id)retrieveObjectForKey:(NSString*)key;
+(void)removeObjectForKey:(NSString *)key;
+(void)syncronize;

@end
