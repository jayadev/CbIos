//
//  QSListingsMenuController.h
//  CubeSale
//
//  Created by Sushant Kumar on 2/6/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSRootViewController.h"

@interface QSListingsMenuController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *menuTable;
@property (nonatomic, assign) IBOutlet UITableViewCell *menuCell;

- (IBAction) onBack;
- (IBAction) onSignout;

- (QSRootViewController *) getController;
- (void) setController:(QSRootViewController *)controller;

@end
