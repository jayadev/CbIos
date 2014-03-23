//
//  QSRegisterViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/21/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "QSLazyImage.h"
#import "QSHttpClient.h"

@protocol QSRegisterViewControllerDelegate;

@interface QSRegisterViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, QSHttpClientDelegate>

@property (nonatomic, weak)id<QSRegisterViewControllerDelegate>delegate;

- (void) setLocation:(NSString *)city :(NSString *)zip :(NSString *)ccode;

@end

@protocol QSRegisterViewControllerDelegate <NSObject>

-(void)registrationCompletedWithStatus:(BOOL)registrationStatus withError:(NSError*)error;

@end
