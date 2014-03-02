//
//  QSShareViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 6/2/13.
//  Copyright (c) 2013 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSLazyImage.h"

@interface QSShareViewController : UIViewController

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProductImage;
@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellPrice;
@property (nonatomic, strong) IBOutlet UIImageView *cellPriceImage;
@property (nonatomic, strong) IBOutlet UILabel *cellTime;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;

- (void) setItem:(NSDictionary *)item;

- (IBAction) btnDone:(id) sender;

@end
