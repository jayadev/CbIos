//
//  QSUserSession.h
//  CubeSale
//
//  Created by Ankit Jain on 23/03/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSUserSessionConstants.h"

@interface QSUserSession : NSObject

-(NSString*)getUserToken;
-(NSString*)getUserId;
-(NSString*)getUserEmail;
-(NSString*)getUserFirstName;
-(NSString*)getUserLastName;
-(NSString*)getUserImageUrl;
-(NSString*)getUserProfileUrl;
-(NSString*)getUserHobby;
-(NSString*)getUserCompanyEmail;

@end
