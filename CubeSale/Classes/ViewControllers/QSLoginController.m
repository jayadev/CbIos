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

- (QSRootViewController *) getController
{
    return _controller;
}

- (void) setController:(QSRootViewController *)controller
{
    _controller = controller;
}

- (void)dealloc
{
    NSLog(@"QSLoginController dealloc");
}

- (void) start:(UIViewController *)parentView
{
    UIViewController *loginView = nil;

    QSLoginViewController *connectView = [[QSLoginViewController alloc] initWithNibName:@"QSLoginViewController" bundle:nil];
    [connectView setController:self];
    loginView = connectView;

    /*if(nil == s_userId) { // first timer
        QSLoginViewController *connectView = [[QSLoginViewController alloc] initWithNibName:@"QSLoginViewController" bundle:nil];
        [connectView setController:self];
        loginView = connectView;
    } else {
        _loginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
        
        // register to be told when the login is finished
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginViewDidFinish:) name:@"loginViewDidFinish" object:_loginView];        
        loginView = _loginView;
    }*/
    
    _navigation = [[UINavigationController alloc] initWithRootViewController:loginView];
    _navigation.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _navigation.navigationBarHidden = YES;
    
    [parentView presentModalViewController:_navigation animated:YES];
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

    /*_loginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(loginViewDidFinish:) name:@"loginViewDidFinish" object:_loginView];
    
    [_navigation pushViewController:_loginView animated:YES];*/
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

    [self doRegister];
}

- (void) doRegister
{
    _registered = false;

    _registerView = [[QSRegisterViewController alloc] initWithNibName:@"QSRegisterViewController" bundle:nil];    
    [_registerView setController:self];

    [_navigation pushViewController:_registerView animated:YES];    
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

- (void) onRegisterDone:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)consent
{
    _http = [QSLoginController postRegistration:email :companyEmail :zip :city :ccode :hobby :false :consent :_navigation :self];
}

+ (QSHttpClient *) postRegistration:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)update :(bool)consent :(UIViewController *)parent :(id <QSHttpClientDelegate>)delegate
{
    s_email = email;
    s_companyEmail = companyEmail;
    s_companyZip = zip;
    s_companyCity = city;
    s_companyCcode = ccode;
    s_location = [NSString stringWithFormat:@"%@, %@", city, zip];
    s_hobby = hobby;
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *bodyString = [NSString stringWithFormat:
        @"user_id=%@&email=%@&firstname=%@&lastname=%@&username=%@&img_url=%@&profile_url=%@&hobby=%@&company_email=%@&company_zip=%@&company_city=%@&company_ccode=%@&update=%@&consent=%@",
        escapeString(s_userId), escapeString(s_email),
        escapeString(s_firstName), escapeString(s_lastName), escapeString(s_formattedName),
        escapeString(s_pictureUrl), escapeString(s_profileUrl),
        escapeString(s_hobby),
        escapeString(s_companyEmail), escapeString(s_companyZip),
        escapeString(s_companyCity), escapeString(s_companyCcode),
        (update ? @"1" : @"0"), (consent ? @"1" : @"0")];
    NSLog(@"Submitting registration: %@", bodyString);
    
    NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSString *apiBase = [QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/registerUser", apiBase];
    
    QSHttpClient *http = [[QSHttpClient alloc] init];
    http.disableUI = true;
    [http submitRequest:request :url :parent :delegate :@"" :nil];
    
    return http;
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    if(!success) {
        return;
    }        
    
    _registered = true;

    [QSLoginController storeUserData];
    
    [_controller onLoggedIn];
}

+ (void) storeUserData
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              s_token, @"token",
                              s_userId, @"id",
                              s_email, @"email",
                              s_firstName, @"first",
                              s_lastName, @"last",
                              s_formattedName, @"formatted",
                              s_profileUrl, @"profileUrl",
                              s_pictureUrl, @"pictureUrl",
                              s_companyEmail, @"companyEmail",
                              s_companyZip, @"companyZip",
                              s_companyCity, @"companyCity",
                              s_companyCcode, @"companyCcode",
                              s_location, @"location",
                              s_hobby, @"hobby",
                              nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:DATA_VERSION forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults] setObject:s_watchList forKey:@"userwatch"];    
}

NSString *escapeString(NSString *str)
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)str, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
}

/*-(void) loginViewDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSDictionary *profile = [notification userInfo];
    
    if(NULL != profile)
    {
        NSLog(@"Profile: %@", profile);

        NSString *userId = [profile objectForKey:@"id"];        
        NSString *email = [profile objectForKey:@"emailAddress"];
        NSString *firstName = [profile objectForKey:@"firstName"];
        NSString *lastName = [profile objectForKey:@"lastName"];
        NSString *formattedName = [profile objectForKey:@"formattedName"];
        NSString *pictureUrl = [profile objectForKey:@"pictureUrl"];
        NSDictionary *location = [profile objectForKey:@"location"];
        NSString *locationName = [location objectForKey:@"name"];
        NSDictionary *country = [location objectForKey:@"country"];
        NSString *ccode = [country objectForKey:@"code"];
        NSString *headline = [profile objectForKey:@"headline"];
        NSString *companyId = NULL;
        NSString *companyName = NULL;
        
        NSDictionary *positions = [profile objectForKey:@"positions"];        
        NSArray *positionsValues = [positions objectForKey:@"values"];
        for(int i = 0; i < positionsValues.count; i++)
        {
            NSDictionary *position = [positionsValues objectAtIndex:i];
            int isCurrent = [[position objectForKey:@"isCurrent"] intValue];
            if(1 == isCurrent)
            {
                NSDictionary *company = [position objectForKey:@"company"];
                NSNumber *cid = [company objectForKey:@"id"];
                if(NULL != cid) {
                    companyId = [cid stringValue];
                }
                companyName = [company objectForKey:@"name"];
                break;
            }
        }
        
        s_token = _loginView.accessToken;
        
        s_email = email;
        s_firstName = firstName;
        s_lastName = lastName;
        s_formattedName = formattedName;
        s_pictureUrl = pictureUrl;
        if(NULL == s_pictureUrl) s_pictureUrl = @"";
        s_companyId = companyId;
        if(NULL == s_companyId) s_companyId = @"";
        s_companyName = companyName;
        if(NULL == s_companyName) s_companyName = @"";
        s_location = locationName;
        if(NULL == s_location) s_location = @"";
        s_ccode = ccode;
        if(NULL == s_ccode) s_ccode = @"US";
        s_ccode = [s_ccode uppercaseString];
        s_headline = headline;
        if(NULL == s_headline) s_headline = @"";

        if((nil != s_userId) && [s_userId isEqualToString:userId]) {
            NSLog(@"User already registered: %@ %@", s_userId, s_email);
        } else {
            s_userId = userId;
            s_watchList = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];
            s_watchItems = [[NSMutableArray alloc] initWithCapacity:MAX_USER_WATCH];
            s_hobby = @"";
        }
        
        [self doRegister];
    }
    else
    {
        NSLog(@"No user profile or cancelled?");
        
        // lets go back to home
        [_controller onSignout:false];
    }
}*/


@end
