//
//  QSRootViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSLoginViewController.h"
#import "QSRegisterViewController.h"

typedef enum{
    TopViewStyleStandard,
    TopViewStyleExpanded
}TopViewStyle;

@interface QSRootViewController : UIViewController <QSLoginViewControllerDelegate,QSRegisterViewControllerDelegate>

@property(nonatomic, assign)BOOL topViewHidden;
@property(nonatomic, assign)BOOL leftMenuButon;
@property(nonatomic, assign)TopViewStyle topViewStyle;

- (void) onStop;
- (void) onLoggedIn;
- (void) onSignout:(bool)partial;

@end
