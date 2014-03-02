//
//  QSMyListingsViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/2/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSLazyImage.h"

#import "QSRootViewController.h"

@interface QSMyListingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *gridCellHolder;
@property (nonatomic, strong) IBOutlet UIScrollView *gridPageView;

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProductImage;
@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellPrice;
@property (nonatomic, strong) IBOutlet UILabel *cellTime;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;
@property (nonatomic, strong) IBOutlet UILabel *cellCommentCount;
@property (nonatomic, strong) IBOutlet UIImageView *cellWatch;

@property (nonatomic, strong) IBOutlet UIView *activityView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noItemLabel;

- (IBAction) btnBack:(id) sender;

@end
