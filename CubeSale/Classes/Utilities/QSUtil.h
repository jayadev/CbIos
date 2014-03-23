//
//  QSUtil.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/8/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSLazyImage.h"
#import "QSUserSession.h"

#define CONST_PI   3.141592653589793
#define CONST_2PI  6.283185307179586
#define CONST_PI2  1.570796326794896

@interface QSUtil : NSObject

+ (QSUserSession*)getUsetSession;

+ (NSString*)geteEscapeString:(NSString*)str;
+ (BOOL)isEmptyString:(NSString*)inputStr;
+ (BOOL)isValidEmailId:(NSString*)emailId;

+ (void)animateView:(UIView *)view :(int)distance up:(BOOL)up;

+ (void) updateItemCell:(NSDictionary *)item 
                       :(QSLazyImage *)productImage :(QSLazyImage *)profileImage 
                       :(UILabel *)userLabel 
                       :(UILabel *)priceLabel :(UIImageView *)priceImage
                       :(UILabel *)locationLabel :(UILabel *)companyLabel
                       :(UILabel *)timeLabel 
                       :(UILabel *)commentLabel :(UILabel *)viewLabel
                       :(UIImageView *)soldImage;
+ (void) updateProductImageCell:(NSDictionary *)item 
                               :(QSLazyImage *)productImage;
+ (void) updateProductFullImageCell:(NSDictionary *)item 
                                   :(QSLazyImage *)productImage;
+ (void) updateProfileImageCell:(NSDictionary *)item 
                               :(QSLazyImage *)profileImage;
+ (void) updateProductTimeCell:(NSDictionary *)item 
                              :(UILabel *)timeLabel;

+ (NSString *)fuzzyTime:(NSString *)datetime;

+ (UIImage *) scaleImage:(UIImage *)image :(int) kMaxResolution;
    
+ (void)showAlert:(NSString *)title :(NSString *)error;

+ (UIDeviceOrientation) updateOrientation:(UIDeviceOrientation)curOrientation :(UIView *)view;
+ (UIDeviceOrientation) updateOrientation:(UIDeviceOrientation)curOrientation :(UIDeviceOrientation)newOrientation :(UIView *)view;
    
+ (NSInteger) minutesAfterDate:(NSDate *)date :(NSDate *)otherDate;
+ (NSInteger) hoursAfterDate:(NSDate *)date :(NSDate *)otherDate;
+ (NSInteger) daysAfterDate:(NSDate *)date :(NSDate *)otherDate;

+ (void)initialize;
+ (NSArray *)countryNames;
+ (NSDictionary *)countryNamesByCode;
+ (NSDictionary *)countryCodesByName;

@end
