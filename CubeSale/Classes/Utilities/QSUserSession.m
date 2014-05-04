//
//  QSUserSession.m
//  CubeSale
//
//  Created by Ankit Jain on 23/03/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSUserSession.h"
#import "QSDataStore.h"
#import "QSUtil.h"


@implementation QSUserSession

- (NSString*)getUserToken {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    NSString *token = [userInfoDict objectForKey:KFBTOKEN];
    return token;
}

-(NSString*)getUserId {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSERID]];
}

-(NSString*)getUserEmail {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_EMAIL]];
}

-(NSString*)getUserFirstName {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_FIRSTNAME]];
}

-(NSString*)getUserLastName {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_LASRNAME]];
}

-(NSString*)getUserImageUrl {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_FB_PICTUREURL]];
}

-(NSString*)getUserProfileUrl {
    return [QSUtil getEscapeString:[QSDataStore retrieveObjectForKey:KUSER_FB_PROFILEURL]];
}

-(NSString*)getUserHobby {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_COMPANYHOBBY]];
}

-(NSString*)getUserCompanyEmail {
    NSDictionary *userInfoDict = [self getUserInfoDict];
    return [QSUtil getEscapeString:[userInfoDict objectForKey:KUSER_COMPANYEMAIL]];
}

-(NSDictionary*)getUserInfoDict {
    NSDictionary *userInfoDict = [QSDataStore retrieveObjectForKey:KUSERINFODICT];
    return userInfoDict;
}

@end
