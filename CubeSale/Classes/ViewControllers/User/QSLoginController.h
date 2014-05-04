//
//  QSLoginController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>


enum QSLoginStatus
{
    QS_LOGGED_IN = 0,
    QS_NOT_LOGGED_IN = 1
};

@protocol QSLoginControllerDelegate;

@interface QSLoginController : NSObject

@property(nonatomic,weak)id<QSLoginControllerDelegate>delegate;

+ (enum QSLoginStatus) autoLogin;
- (void) doLogin;
+ (void) doUnregister:(bool)partial;

@end

@protocol QSLoginControllerDelegate <NSObject>

-(void)loginDidComplete;
-(void)loginDidFail;

@end
