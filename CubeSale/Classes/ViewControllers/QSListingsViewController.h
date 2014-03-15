//
//  QSListingsViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 2/1/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSLazyImage.h"
#import "QSHttpClient.h"

#import "QSRootViewController.h"

@interface QSListingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *gridCellHolder;
@property (nonatomic, strong) IBOutlet UIScrollView *gridPageView;
@property (nonatomic, strong) IBOutlet UILabel *filterLabel;

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProductImage;
@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellPrice;
@property (nonatomic, strong) IBOutlet UIImageView *cellPriceImage;
@property (nonatomic, strong) IBOutlet UILabel *cellTime;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;
@property (nonatomic, strong) IBOutlet UILabel *cellCommentCount;
@property (nonatomic, strong) IBOutlet UILabel *cellViewCount;
@property (nonatomic, strong) IBOutlet UIButton *cellWatch;
@property (nonatomic, strong) IBOutlet UIImageView *cellSold;
@property (nonatomic, strong) IBOutlet UILabel *cellDescription;
@property (nonatomic, strong) IBOutlet UIImageView *cellDescriptionImage;
@property (nonatomic, strong) IBOutlet UIButton *cellEdit;
@property (nonatomic, strong) IBOutlet UIButton *cellShare;

@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIView *menuView;
@property (nonatomic, strong) IBOutlet UITableView *menuTable;
@property (nonatomic, assign) IBOutlet UITableViewCell *menuCell;

@property (nonatomic, strong) IBOutlet UIView *activityView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction) btnProfile:(id) sender;
- (IBAction) btnMenu:(id) sender;
- (IBAction) btnPost:(id) sender;
- (IBAction) btnEdit:(id) sender;
- (IBAction) btnShare:(id) sender;
- (IBAction) toggleWatch:(id) sender;

- (void) onBack;
- (void) onSignout;
- (QSRootViewController *) getController;
- (void) setController:(QSRootViewController *)controller;

@end
