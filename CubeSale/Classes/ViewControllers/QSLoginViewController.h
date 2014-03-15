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

@interface QSLoginViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

- (QSLoginController *) getController;
- (void) setController:(QSLoginController *)controller;

- (IBAction)btnLogin:(UIButton *)sender;

@end
