//
//  QSProfileViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 5/16/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "QSLazyImage.h"

@interface QSProfileViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property bool signedOut;

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;

@property (nonatomic, strong) IBOutlet UITextView *hobbyView;
@property (nonatomic, strong) IBOutlet UITextField *emailView;
@property (nonatomic, strong) IBOutlet UITextField *locationView;
@property (nonatomic, strong) IBOutlet UITextField *companyEmailView;

@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction) btnBack:(id) sender;
- (IBAction) btnUpdate:(id) sender;
- (IBAction) btnSignout:(id) sender;

- (IBAction) btnLocation:(id) sender;

- (void) setLocation:(NSString *)city :(NSString *)zip :(NSString *)ccode;

@end
