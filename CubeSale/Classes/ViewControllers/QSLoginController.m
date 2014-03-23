//
//  QSLoginController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//
#import "QSLoginController.h"
#import "QSLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "QSUserSessionConstants.h"
#import "QSUtil.h"
#import "QSDataStore.h"


@interface QSLoginController ()


@end

@implementation QSLoginController

+ (enum QSLoginStatus) autoLogin
{
    bool forceRegister = false;
    
  
    NSDictionary *userInfo = [QSDataStore retrieveObjectForKey:@"string"];
    if( !userInfo ) {
        forceRegister = true;
    }
    
    // See if the app has a valid token for the current state.
    if (!forceRegister && (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)) {
        //token is available
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
        return QS_NOT_LOGGED_IN;
    }
}


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
            //[_controller onSignout:false];
            break;
        default:
            break;
    }
}
- (void)userInfoResponse:(FBRequestConnection *)connection
                      user:(id<FBGraphUser>) user
                      error:(NSError *)error {
    if(user == NULL) {
        assert("no user profile exist");
        // lets go back to home
        //logout and go back to home
        return;
    }
    NSString *token = [FBSession activeSession].accessTokenData.accessToken;
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithCapacity:16];
    [userInfoDict setObject:token forKey:KFBTOKEN];
    [userInfoDict setObject:user.id forKey:KUSERID];
    [userInfoDict setObject:user[@"email"] forKey:KUSER_EMAIL];
    [userInfoDict setObject:user.first_name forKey:KUSER_FIRSTNAME];
    [userInfoDict setObject:user.last_name forKey:KUSER_LASRNAME];
    [userInfoDict setObject:user.name forKey:KUSER_FORMATTEDNAME];
    [userInfoDict setObject:user.link forKey:KUSER_FB_PROFILEURL];
    
    NSString *pictureUrl = NULL;
    NSDictionary *pictureMap = user[@"picture"][@"data"];
    if(NULL != pictureMap) {
        pictureUrl = pictureMap[@"url"];
        [userInfoDict setObject:pictureUrl forKey:KUSER_FB_PICTUREURL];
    }
    [QSDataStore storeObject:userInfoDict forKey:KUSERINFODICT];
    
    if(self.delegate){
        [self.delegate loginDidComplete];
    }
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




@end
