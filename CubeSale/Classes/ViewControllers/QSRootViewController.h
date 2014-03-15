//
//  QSRootViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSRootViewController : UIViewController<UITabBarControllerDelegate>

- (void) onStart;
- (void) onStop;
- (void) onLoggedIn;
- (void) onSignout:(bool)partial;

@end
