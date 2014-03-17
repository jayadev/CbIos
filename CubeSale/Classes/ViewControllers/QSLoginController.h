//
//  QSLoginController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "OAuthLoginView.h"

#import "QSHttpClient.h"
//#import "QSRootViewController.h"

enum QSLoginStatus
{
    QS_LOGGED_IN = 0,
    QS_NOT_LOGGED_IN = 1
};

@protocol QSLoginControllerDelegate;

@interface QSLoginController : NSObject

@property(nonatomic,weak)id<QSLoginControllerDelegate>delegate;

//- (QSRootViewController *) getController;
//- (void) setController:(QSRootViewController *)controller;

+ (enum QSLoginStatus) autoLogin;


- (void) doLogin;
//- (void) doRegister;
//- (void) onRegisterDone:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)consent;
//
//+ (QSHttpClient *) postRegistration:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)update :(bool)consent :(UIViewController *)parent :(id <QSHttpClientDelegate>)delegate;

    //+ (void) storeUserData;
+ (void) doUnregister:(bool)partial;

+ (NSString *) getToken;
+ (NSString *) getUserId;
+ (bool) getUserValidation;
+ (void) setUserValidation:(bool) validation;
+ (NSString *) getUserEmail;
+ (NSString *) getUserName;
+ (NSString *) getUserCompany;
+ (void) setUserCompany:(NSString *)company;
+ (NSString *) getUserCompanyEmail;
+ (NSString *) getUserCompanyZip;
+ (NSString *) getUserCompanyCity;
+ (NSString *) getUserCompanyCcode;
+ (NSString *) getUserLocation;
+ (NSString *) getUserHobby;
+ (NSString *) getUserProfilerImage;
+ (NSString *) getUserProfilerUrl;
+ (void) initUserWatchItems: (NSArray *)items;
+ (NSMutableArray *) getUserWatchItems;

+ (NSMutableArray *) getUserWatchList;
+ (void) addUserWatch: (NSDictionary *)item;
+ (void) removeUserWatch: (NSString *)pid;
+ (bool) isInUserWatch: (NSString *)pid;

@end

@protocol QSLoginControllerDelegate <NSObject>

-(void)loginDidComplete;
-(void)loginDidFail;

@end
