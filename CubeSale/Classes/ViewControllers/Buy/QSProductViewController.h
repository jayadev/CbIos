//
//  QSProductViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/11/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QSLazyImage.h"

@interface QSProductViewController : UIViewController<AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
}



@property (nonatomic, strong) IBOutlet QSLazyImage *cellProductImage;
@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellPrice;
@property (nonatomic, strong) IBOutlet UIImageView *cellPriceImage;
@property (nonatomic, strong) IBOutlet UILabel *cellTime;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;
@property (nonatomic, strong) IBOutlet UIButton *cellWatch;
@property (nonatomic, strong) IBOutlet UIScrollView *cellFullView;
@property (nonatomic, strong) IBOutlet QSLazyImage *cellFullImageView;
@property (nonatomic, strong) IBOutlet UILabel *cellDescription;
@property (nonatomic, strong) IBOutlet UIImageView *cellBubble;
@property (nonatomic, strong) IBOutlet UIButton *cellFullExit;

//@property (nonatomic, strong) IBOutlet UITableView *commentTable;
@property (nonatomic, assign) IBOutlet UITableViewCell *commentCell;

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIProgressView *playProgress;

@property (nonatomic, strong) IBOutlet QSLazyImage *commentProfileImage;
@property (nonatomic, strong) IBOutlet UITextField *commentField;
@property (nonatomic, strong) IBOutlet UIButton *commentCancelButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *commentActivity;

@property (nonatomic, strong) IBOutlet UIView *descView;
@property (nonatomic, strong) IBOutlet UIView *profileView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary*)item;

- (IBAction) btnFullScreen:(id) sender;
- (IBAction) btnFullScreenExit:(id) sender;
- (IBAction) btnDone:(id) sender;

- (IBAction) btnCancelComment:(id) sender;

@end
