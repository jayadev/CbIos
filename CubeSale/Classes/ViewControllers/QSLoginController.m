//
//  QSLoginController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSRegisterViewController.h"
#import "QSLoginViewController.h"
#import "QSLoginController.h"
#import "QSRootViewController.h"

#import "SBJson.h"

#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>

#define MAX_USER_WATCH 10
#define DATA_VERSION @"1.2"

NSString *escapeString(NSString *str);

static NSString *s_token;
static bool s_userValidation = false;
static NSString *s_email;
static NSString *s_userId;
static NSString *s_firstName;
static NSString *s_lastName;
static NSString *s_formattedName;
static NSString *s_profileUrl;
static NSString *s_pictureUrl;
static NSString *s_companyEmail = @"";
static NSString *s_companyZip = @"";
static NSString *s_companyCity = @"";
static NSString *s_companyCcode = @"";
static NSString *s_company = @"";
static NSString *s_location = @"";
static NSString *s_hobby;
static NSMutableArray *s_watchList;

static NSMutableArray *s_watchItems;

@interface QSLoginController () <QSHttpClientDelegate>
{
    QSHttpClient *_http;
    NSMutableData *_postResponse;

    __unsafe_unretained QSRootViewController *_controller;

    UINavigationController *_navigation;
    // OAuthLoginView *_loginView;
    QSRegisterViewController *_registerView;
        
    bool _registered;
}

@end

@implementation QSLoginController

+ (NSString *) getToken
{
    return s_token;
}
+ (bool) getUserValidation
{
    return s_userValidation;
}
+ (void) setUserValidation:(bool) validation
{
    s_userValidation = validation;
}
+ (NSString *) getUserId
{
    return s_userId;
}
+ (NSString *) getUserEmail
{
    return s_email;
}
+ (NSString *) getUserName
{
    return s_formattedName;
}
+ (NSString *) getUserCompany
{
    return s_company;
}
+ (void) setUserCompany:(NSString *)company
{
    s_company = company;
}
+ (NSString *) getUserCompanyEmail
{
    return s_companyEmail;
}
+ (NSString *) getUserCompanyZip
{
    return s_companyZip;
}
+ (NSString *) getUserCompanyCity
{
    return s_companyCity;
}
+ (NSString *) getUserCompanyCcode
{
    return s_companyCcode;
}
+ (NSString *) getUserLocation
{
    return s_location;
}
+ (NSString *) getUserHobby
{
    return s_hobby;
}
+ (NSString *) getUserProfilerImage
{
    return s_pictureUrl;
}
+ (NSString *) getUserProfilerUrl
{
    return s_profileUrl;
}

+ (void) initUserWatchItems: (NSArray *)items
{
    [s_watchItems addObjectsFromArray:items];
}

+ (NSMutableArray *) getUserWatchItems
{
    return s_watchItems;
}

+ (NSMutableArray *) getUserWatchList
{
    return s_watchList;
}
+ (void) addUserWatch: (NSDictionary *)item
{
    NSString *pid = [item valueForKey:@"id"];
    if(NSNotFound == [s_watchList indexOfObject:pid]) {
        // Make room for the new one
        if(s_watchList.count == MAX_USER_WATCH) {
            [s_watchList removeLastObject];
        }
        
        [s_watchList insertObject:pid atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:s_watchList forKey:@"userwatch"];

        if(s_watchItems.count == MAX_USER_WATCH) {
            [s_watchItems removeLastObject];
        }
        [s_watchItems insertObject:item atIndex:0];
    }
    NSLog(@"watch: %@", s_watchList);
}
+ (void) removeUserWatch: (NSString *)pid
{
    [s_watchList removeObject:pid];
    [[NSUserDefaults standardUserDefaults] setObject:s_watchList forKey:@"userwatch"];
    NSLog(@"remove watch: %@", s_watchList);
    
    [s_watchItems enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        NSDictionary *item = (NSDictionary *)obj;
        if([(NSString *)[item valueForKey:@"id"] isEqualToString:pid]) {
            [s_watchItems removeObjectAtIndex:index];
            *stop=YES;
        }
    }];
    NSLog(@"post remove watch items: %d", s_watchList.count);
}
+ (bool) isInUserWatch: (NSString *)pid
{   
    return (NSNotFound != [s_watchList indexOfObject:pid]);
}

+ (enum QSLoginStatus) autoLogin
{
    bool forceRegister = false;
    
    NSString *version = [[NSUserDefaults standardUserDefaults] stringForKey:@"version"];
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userinfo"];
    if((nil != userInfo) && (nil != version) && (NSOrderedSame == [version compare:DATA_VERSION]))
    {
        NSLog(@"Userinfo: %@", userInfo);

        s_token = [userInfo valueForKey:@"token"];
        s_userId = [userInfo valueForKey:@"id"];
        s_email = [userInfo valueForKey:@"email"];
        s_firstName = [userInfo valueForKey:@"first"];
        s_lastName = [userInfo valueForKey:@"last"];
        s_formattedName = [userInfo valueForKey:@"formatted"];
        s_profileUrl = [userInfo valueForKey:@"profileUrl"];
        s_pictureUrl = [userInfo valueForKey:@"pictureUrl"];
        s_companyEmail = [userInfo valueForKey:@"companyEmail"];
        s_companyZip = [userInfo valueForKey:@"companyZip"];
        s_companyCity = [userInfo valueForKey:@"companyCity"];
        s_companyCcode = [userInfo valueForKey:@"companyCcode"];
        s_location = [userInfo valueForKey:@"location"];
        s_hobby = [userInfo valueForKey:@"hobby"];
        
        s_watchList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"userwatch"];
        if(nil == s_watchList) {
            s_watchList = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];   
        }
        s_watchItems = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];
    } else {
        s_userId = nil;
        s_email = nil;
        s_firstName = nil;
        s_lastName = nil;
        s_formattedName = nil;
        s_profileUrl = nil;
        s_pictureUrl = nil;
        s_companyEmail = nil;
        s_companyZip = nil;
        s_companyCity = nil;
        s_companyCcode = nil;
        s_location = nil;
        s_hobby = nil;
        s_watchList = nil;   
        s_watchItems = nil;
        
        forceRegister = true;
    }
    
    // See if the app has a valid token for the current state.
    if (!forceRegister && (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)) {
    // if (!forceRegister && (FBSession.activeSession.isOpen)) {
        NSLog(@"We already have a token");
        
        // refresh too
        [FBSession openActiveSessionWithReadPermissions:@[
                                                      @"basic_info", @"email", @"user_location", @"user_interests"]
                                       allowLoginUI:NO
                                  completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             if((state == FBSessionStateClosed) || (state == FBSessionStateClosedLoginFailed)) {
                 NSLog(@"Auto token refresh has failed, will ask to login next time");
                 [FBSession.activeSession closeAndClearTokenInformation];
             }
         }];

        return QS_LOGGED_IN;
    } else {
        NSLog(@"We need to login");
        return QS_NOT_LOGGED_IN;
    }
    
/*    OAToken *accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"linkedin" prefix:@"cubesales"];
    if((nil != accessToken) && !forceRegister)
    {
        NSLog(@"We already have a token: %@", accessToken);
        
        s_token = accessToken;
        return QS_LOGGED_IN;
    }*/
}

//
//- (QSRootViewController *) getController
//{
//    return _controller;
//}
//
//- (void) setController:(QSRootViewController *)controller
//{
//    _controller = controller;
//}

- (void)dealloc
{
    NSLog(@"QSLoginController dealloc");
}


- (void) doLogin
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info", @"email", @"user_location", @"user_interests"]
                                          allowLoginUI:YES
                                completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSLog(@"Session: %@", session);

    NSString *additionalError = @"Error";
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"FB Session open");
            FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=id,name,picture,first_name,last_name,link,location,email,username"];
            [request startWithCompletionHandler:
             ^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
                 [self userInfoResponse:connection user:user error:error];
             }];
        }
            break;
        case FBSessionStateClosed:
            NSLog(@"FB Session closed");
            [FBSession.activeSession closeAndClearTokenInformation];
            // [_controller onSignout:false];
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FB Session login failed");
            [FBSession.activeSession closeAndClearTokenInformation];
            additionalError = @"Failed to login using Facebook";
            [_controller onSignout:false];
            break;
        default:
            break;
    }
    
    /*if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:additionalError
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }*/
}

- (void)userInfoResponse:(FBRequestConnection *)connection
                      user:(id<FBGraphUser>) user
                      error:(NSError *)error
{
    if(NULL == user) {
        NSLog(@"No user profile?");
        // lets go back to home
        [_controller onSignout:false];
        return;
    }

    NSString *token = [[FBSession activeSession] accessToken];
    NSLog(@"token: %@", token);
    NSLog(@"user: %@", user);
    
    NSString *userId = user.id;
    NSString *userName = user.username;
    NSString *email = user[@"email"];
    NSString *firstName = user.first_name;
    NSString *lastName = user.last_name;
    NSString *formattedName = user.name;
    NSString *profileUrl = user.link;

    NSString *pictureUrl = NULL;
    NSDictionary *pictureMap = user[@"picture"][@"data"];
    if(NULL != pictureMap) {
        pictureUrl = pictureMap[@"url"];
    }
    
    s_token = token;

    s_email = email;
    s_firstName = firstName;
    s_lastName = lastName;
    s_formattedName = formattedName;
    s_profileUrl = profileUrl;
    s_pictureUrl = pictureUrl;
    if(NULL == s_pictureUrl) s_pictureUrl = @"";

    /*s_companyEmail = @"";
    s_companyZip = @"";
    s_companyCity = @"";
    s_companyCcode = @"";
    s_location = @"";*/
    
    if((nil != s_userId) && [s_userId isEqualToString:userId]) {
        NSLog(@"User already registered: %@ %@", s_userId, s_email);
    } else {
        s_userId = userId;
        s_watchList = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];
        s_watchItems = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];
        s_hobby = @"";
    }

    if(self.delegate){
        [self.delegate loginDidComplete];
    }
    //[self doRegister];
}


+ (void) doUnregister:(bool)partial
{
    [[FBSession activeSession]  closeAndClearTokenInformation];
    FBSession.activeSession = nil;
    // [OAToken removeFromUserDefaultsWithServiceProviderName:@"linkedin" prefix:@"cubesales"];
    if(!partial) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userinfo"];
    }
}

//- (void) onRegisterDone:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)consent
//{
//        //_http = [QSLoginController postRegistration:email :companyEmail :zip :city :ccode :hobby :false :consent :_navigation :self];
//}



NSString *escapeString(NSString *str)
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)str, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
}


@end
