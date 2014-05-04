//
//  QSRootViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSRootViewController.h"
    //#import "QSRegistrationViewController.h"
#import "QSRegisterViewController.h"
#import "QSListingsViewController.h"
#import "QSPostViewController.h"
#import "QSDataStore.h"
#import "QSMenuViewController.h"
#import "SWRevealViewController.h"



#define TOPVIEW_HEIGHT_STANDARD  44
#define TOPVIEW_HEIGHT_EXTENDED  76 //29-SEGMENT CONTROL HEIGHT+ 3 PT GAP AFTER SEGMENT CONTROL

@interface QSRootViewController ()

@property (nonatomic, strong)IBOutlet UIView *topView;
@property (nonatomic, strong)IBOutlet UIView *contentView;
@property (nonatomic,strong)UILabel *companyTitle;
@property (nonatomic, strong)QSRegisterViewController *registerViewCon;
@property (nonatomic, strong)QSPostViewController *postViewCon;
@property (nonatomic, strong)QSListingsViewController *listViewCon;
@property (nonatomic, strong) QSLoginViewController *loginViewCon;
@property (nonatomic, strong)SWRevealViewController *revealController;
@end


@implementation QSRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.topView.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1];
    self.contentView.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1];


    BOOL loginStatus = FALSE;
    if(QS_LOGGED_IN == [QSLoginController autoLogin]) {
        loginStatus = true;
    }
    if(loginStatus) {
        BOOL isUserRegistered = [[QSDataStore retrieveObjectForKey:KUSER_REGISTERED] boolValue];
        if(isUserRegistered) {
            [self showListingView];
        }
        else {
            self.registerViewCon = [[QSRegisterViewController alloc] initWithNibName:@"QSRegisterViewController" bundle:nil];
            self.registerViewCon.delegate = self;
            [self presentViewController:self.registerViewCon animated:NO completion:^{
                
            }];
        }

    } else {
        QSLoginViewController *loginViewCon = [[QSLoginViewController alloc] initWithNibName:@"QSLoginViewController" bundle:nil];
        loginViewCon.delegate = self;
        [self.navigationController pushViewController:loginViewCon animated:YES];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)showListingView {

    QSMenuViewController *menuViewController = [[QSMenuViewController alloc] initWithNibName:@"QSMenuViewController" bundle:nil];
    QSListingsViewController *listingViewCon = [[QSListingsViewController alloc] initWithNibName:@"QSListingsViewController" bundle:nil];

    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:listingViewCon];
    frontNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1];
    frontNavigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.revealController = [[SWRevealViewController alloc] initWithRearViewController:menuViewController frontViewController:frontNavigationController];
    //revealController.delegate = self;
    [self.navigationController pushViewController:self.revealController animated:NO];
    //[self.view addSubview:self.revealController.view];
}


#pragma mark - LoginViewController delegate handler
-(void)loginCompletedWithStatus:(BOOL)loginStatus withError:(NSError*)error {
    if(loginStatus == TRUE) {
        //show register viewcontroller
        self.registerViewCon = [[QSRegisterViewController alloc] initWithNibName:@"QSRegisterViewController" bundle:nil];
        self.registerViewCon.delegate = self;
        [self presentViewController:self.registerViewCon animated:NO completion:^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
    }
    else {
        
    }
}

#pragma mark - RegistrationViewController delegate handler
-(void)registrationCompletedWithStatus:(BOOL)registrationStatus withError:(NSError*)error {
    if(registrationStatus == TRUE) {
        [self showListingView];
        [self.registerViewCon dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        [self.registerViewCon dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
