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
#import "QSLoginController.h"

@interface QSRegisterViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;

@property (nonatomic, strong) IBOutlet UITextView *hobbyView;
@property (nonatomic, strong) IBOutlet UITextField *emailView;
@property (nonatomic, strong) IBOutlet UITextField *locationView;
@property (nonatomic, strong) IBOutlet UITextField *companyEmailView;

@property (nonatomic, strong) IBOutlet UIButton *consentButton;
@property (nonatomic, strong) IBOutlet UIButton *noConsentButton;

@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction) btnConsent:(id) sender;
- (IBAction) btnNoConsent:(id) sender;
- (IBAction) btnRegister:(id) sender;
- (IBAction) btnLocation:(id) sender;

- (QSLoginController *) getController;
- (void) setController:(QSLoginController *)controller;

- (void) setLocation:(NSString *)city :(NSString *)zip :(NSString *)ccode;

@end
