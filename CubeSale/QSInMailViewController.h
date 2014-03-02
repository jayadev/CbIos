//
//  QSInMailViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSInMailViewController : UIViewController

- (void) setItem:(NSDictionary *)item;

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;
@property (nonatomic, strong) IBOutlet UILabel *cellCompany;

@property (nonatomic, strong) IBOutlet UITextField *textSubject;
@property (nonatomic, strong) IBOutlet UITextView *textBody;

- (IBAction) btnSend:(id) sender;
- (IBAction) btnCancel:(id) sender;

@end