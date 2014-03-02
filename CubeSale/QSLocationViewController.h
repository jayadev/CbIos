//
//  QSLocationViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 8/26/13.
//  Copyright (c) 2013 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "QSRegisterViewController.h"
#import "QSProfileViewController.h"

@interface QSLocationViewController : UIViewController<UISearchBarDelegate, MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet MKMapView* mapView;

- (IBAction)btnContinue:(UIButton *)sender;

- (void) setController:(QSRegisterViewController *)controller :(NSString *)city :(NSString *)zip :(NSString *)ccode;
- (void) setProfileController:(QSProfileViewController *)controller :(NSString *)city :(NSString *)zip :(NSString *)ccode;

@end
