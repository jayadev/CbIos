//
//  QSLoginViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "QSLoginController.h"

@protocol QSLoginViewControllerDelegate;

@interface QSLoginViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, QSLoginControllerDelegate>

@property (nonatomic, weak)id<QSLoginViewControllerDelegate> delegate;

- (IBAction)btnLogin:(UIButton *)sender;

@end

@protocol QSLoginViewControllerDelegate <NSObject>

-(void)loginCompletedWithStatus:(BOOL)loginStatus withError:(NSError*)error;

@end
