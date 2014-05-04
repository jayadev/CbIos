//
//  QSUtil.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/8/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSDataStore.h"
#import "QSUserSessionConstants.h"


@implementation QSUtil

#pragma mark -
#pragma mark String Util Methods -

+ (NSString*)getEscapeString:(NSString*)str
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)str, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
}
+ (BOOL)isEmptyString:(NSString*)inputStr {
    if( (!inputStr) || (![inputStr isKindOfClass:[NSString class]]) ) {
        return TRUE;
    }
    NSString *trimStr = [inputStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ( (!trimStr.length) || [trimStr isEqualToString:@""]);
}
+ (BOOL)isValidEmailId:(NSString*)emailId {
    return ![self isEmptyString:emailId];
}

+ (void)animateView:(UIView *)view :(int)distance up:(BOOL)up
{
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -distance : distance); 
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}

+ (void) updateItemCell:(NSDictionary *)item 
                       :(QSLazyImage *)productImage 
                       :(QSLazyImage *)profileImage :(UILabel *)userLabel 
                       :(UILabel *)priceLabel :(UIImageView *)priceImage
                       :(UILabel *)locationLabel :(UILabel *)companyLabel
                       :(UILabel *)timeLabel 
                       :(UILabel *)commentLabel :(UILabel *)viewLabel
                       :(UIImageView *)soldImage
{
    [QSUtil updateProductImageCell:item :productImage];
    [QSUtil updateProfileImageCell:item :profileImage];
    
    if(userLabel) {
        userLabel.text = [item valueForKey:@"username"];
    }

    NSString *price = [item valueForKey:@"price"];
    int intPrice = [price intValue];
    if(priceLabel && priceImage) {
        priceImage.hidden = NO;
        priceLabel.text = @"";

        if([price isEqualToString:@"free"]) {
            priceImage.image = [UIImage imageNamed:@"tag_free.png"];
        }
        else if([price isEqualToString:@"coffee"]) {
            priceImage.image = [UIImage imageNamed:@"tag_coffee.png"];
        }
        else if([price isEqualToString:@"lunch"]) {
            priceImage.image = [UIImage imageNamed:@"tag_lunch.png"];
        }
        else {
            priceImage.hidden = YES;
            if(0 == intPrice) priceLabel.text = price;
            else priceLabel.text = [NSString stringWithFormat:@"$%@", price];
        }
    } else if(priceLabel) {
        if(0 == intPrice) priceLabel.text = price;
        else priceLabel.text = [NSString stringWithFormat:@"$%@", price];        
    }
    
    if(locationLabel) {
        NSObject *location = [item valueForKey:@"city"];
        if(location && ([NSNull null] != location)) locationLabel.text = (NSString *)location;
    }
    
    if(companyLabel) {
        NSObject *company = [item valueForKey:@"company"];
        if(company && ([NSNull null] != company)) companyLabel.text = (NSString *)company;
    }
    
    [self updateProductTimeCell:item :timeLabel];
    
    if(commentLabel) {
        NSObject *ccount = [item valueForKey:@"comments_count"];
        if(ccount && ([NSNull null] != ccount)) commentLabel.text = (NSString *)ccount;
    }
    if(viewLabel) {
        NSObject *ccount = [item valueForKey:@"num_views"];
        if(ccount && ([NSNull null] != ccount)) viewLabel.text = (NSString *)ccount;
    }

    if(soldImage) {
        soldImage.hidden = TRUE;
        
        NSObject *sold = [item valueForKey:@"posting_status"];
        if(sold && ([NSNull null] != sold)) {
            NSString *ssold = (NSString *)sold;
            int isold = [ssold intValue];
            if(1 == isold) {
                soldImage.hidden = FALSE;
            }
        }
    }
}

+ (void) updateProductImageCell:(NSDictionary *)item 
                               :(QSLazyImage *)productImage
{
    if(productImage) {
        NSObject *imgSmallString = [item valueForKey:@"photo_url_small"];
        if(imgSmallString && ([NSNull null] != imgSmallString) && (((NSString *)imgSmallString).length > 0)) {
            NSURL *imgUrl = [[NSURL alloc] initWithString:(NSString *)imgSmallString];
            [productImage loadFromUrl:imgUrl];
        } else {
            NSObject *imgString = [item valueForKey:@"photo_url"];
            if(imgString && ([NSNull null] != imgString) && (((NSString *)imgString).length > 0)) {
                NSURL *imgUrl = [[NSURL alloc] initWithString:(NSString *)imgString];
                [productImage loadFromUrl:imgUrl];
            }
        }
    }
}

+ (void) updateProductFullImageCell:(NSDictionary *)item 
                               :(QSLazyImage *)productImage
{
    if(productImage) {
        NSObject *imgString = [item valueForKey:@"photo_url"];
        if(imgString && ([NSNull null] != imgString) && (((NSString *)imgString).length > 0)) {
            NSURL *imgUrl = [[NSURL alloc] initWithString:(NSString *)imgString];
            [productImage loadFromUrl:imgUrl];
        }
    }
}

+ (void) updateProfileImageCell:(NSDictionary *)item 
                               :(QSLazyImage *)profileImage
{
    if(profileImage) {
        NSObject *imgString = [item valueForKey:@"img_url"];
        if(imgString && ([NSNull null] != imgString) && (((NSString *)imgString).length > 0)) {
            NSURL *imgUrl = [[NSURL alloc] initWithString:(NSString *)imgString];
            [profileImage loadFromUrl:imgUrl];
        }
    }
}

+ (void) updateProductTimeCell:(NSDictionary *)item 
                               :(UILabel *)timeLabel
{
    if(timeLabel) {
        NSObject *mtime = [item valueForKey:@"mtime"];        
        if(mtime && ([NSNull null] != mtime)) timeLabel.text = [QSUtil fuzzyTime:(NSString *)mtime];
    }
}

+ (NSString *)fuzzyTime:(NSString *)datetime {

    if(datetime == NULL){
        assert(@"datetime string null");
    }
    
    if([datetime isEqualToString:@""]) return @"a moment ago";
    
    NSString *formatted;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *date = [formatter dateFromString:datetime];
    NSDate *today = [NSDate date];
    
    NSInteger minutes = [self minutesAfterDate:today :date];
    NSInteger hours = [self hoursAfterDate:today :date];
    NSInteger days = [self daysAfterDate:today :date];
    
    NSString *period;
    if(days >= 365) {
        float years = round(days / 365) / 2.0f;
        period = (years > 1) ? @"years" : @"year";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)years, period];
    } else if(days < 365 && days >= 30) {
        float months = round(days / 30) / 2.0f;
        period = (months > 1) ? @"months" : @"month";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)months, period];
    } else if(days < 30 && days >= 2) {
        period = @"days";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)days, period];
    } else if(days == 1){
        period = @"day";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)days, period];
    } else if(days < 1 && minutes > 60) {
        period = (hours > 1) ? @"hours" : @"hour";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)hours, period];
    } else {
        period = (minutes < 60 && minutes > 1) ? @"minutes" : @"minute";
        formatted = [NSString stringWithFormat:@"%d %@ ago", (int)minutes, period];
        if(minutes < 1){
            formatted = @"a moment ago";
        }        
    }
    
    return formatted;    
}

+ (UIImage *) scaleImage:(UIImage *)image :(int) kMaxResolution {
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    NSLog(@"image: %d %d or %d %d", (int)width, (int)height, (int)image.size.width, (int)image.size.height);
    //if(image.size.width < image.size.height)
    //      kMaxResolution = 640; // 940;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    //CGFloat scaleRatio = 1.0;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (UIDeviceOrientation) updateOrientation:(UIDeviceOrientation)curOrientation :(UIView *)view
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    return [self updateOrientation:curOrientation :deviceOrientation :view];    
}

+ (UIDeviceOrientation) updateOrientation:(UIDeviceOrientation)curOrientation :(UIDeviceOrientation)newOrientation :(UIView *)view;
{
    NSLog(@"updateOrientation");

    if(newOrientation == curOrientation) {
        NSLog(@"No orientation change: %d", (int)curOrientation);
        return newOrientation;
    }
    
    CGAffineTransform ts;
    if((newOrientation == UIDeviceOrientationPortrait) || (newOrientation == UIDeviceOrientationPortraitUpsideDown)) {
        ts = CGAffineTransformIdentity;
    }
    else if (newOrientation == UIDeviceOrientationLandscapeLeft) {
        ts = CGAffineTransformMakeRotation(CONST_PI2);
    }
    else if (newOrientation == UIDeviceOrientationLandscapeRight) {
        ts = CGAffineTransformMakeRotation(-CONST_PI2);
    }  
    else
        return curOrientation; // may be unknown
    
    NSLog(@"new orientation: %d", (int)newOrientation);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    view.transform = ts;
    [UIView commitAnimations];
    
    return newOrientation;
}

+ (void)showAlert:(NSString *)title :(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (NSInteger) minutesAfterDate:(NSDate *)date :(NSDate *)otherDate
{
    NSTimeInterval ti = [date timeIntervalSinceDate:otherDate];
    return (NSInteger) (ti / 60);
}

+ (NSInteger) hoursAfterDate:(NSDate *)date :(NSDate *)otherDate
{
    NSTimeInterval ti = [date timeIntervalSinceDate:otherDate];
    return (NSInteger) (ti / 3600);
}

+ (NSInteger) daysAfterDate:(NSDate *)date :(NSDate *)otherDate
{
    NSTimeInterval ti = [date timeIntervalSinceDate:otherDate];
    return (NSInteger) (ti / 86400);
}

static NSArray *countryNames = nil;
static NSDictionary *countryNamesByCode = nil;
static NSMutableDictionary *countryCodesByName = nil;

+ (void)initialize
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
    countryNamesByCode = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    countryCodesByName = [NSMutableDictionary dictionary];
    for (NSString *code in [countryNamesByCode allKeys])
    {
        [countryCodesByName setObject:code forKey:[countryNamesByCode objectForKey:code]];
    }
    
    NSArray *names = [countryNamesByCode allValues];
    countryNames = [names sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];   
}

+ (NSArray *)countryNames
{
    return countryNames;
}

+ (NSDictionary *)countryNamesByCode
{
    return countryNamesByCode;
}

+ (NSDictionary *)countryCodesByName
{
    return countryCodesByName;
}
+ (NSString *)getFEProductLanding
{
    return @"http://www.cubesales.com/item";
}

@end
