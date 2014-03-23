//
//  QSHttpClient.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RequestType_Post,
    RequestType_Get
}NetworkRequestType;

@protocol QSHttpClientDelegate;

@interface QSHttpClient : NSObject
{
}

@property(nonatomic,weak)id<QSHttpClientDelegate> delegate;

-(void)executeNetworkRequest:(NetworkRequestType)requesType WithRelativeUrl:(NSString*)relativeUrlPath parameters:(NSDictionary*)params;
- (void) cancelRequest;

@end

@protocol QSHttpClientDelegate <NSObject>

@required
- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error;

@end
