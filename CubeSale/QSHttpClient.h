//
//  QSHttpClient.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QSHttpClientDelegate <NSObject>

@required
- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData;

@end

@interface QSHttpClient : NSObject
{
}

@property bool disableUI;

- (void) submitRequest:(NSURLRequest *)request :(NSString *)url :(UIViewController *)parent :(id <QSHttpClientDelegate>)delegate :(NSString *)successMessage :(id)userData;
- (void) cancelRequest;

@end
