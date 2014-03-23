//
//  QSRootViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSRootViewController.h"
#import "QSRegisterViewController.h"
#import "QSListingsViewController.h"


#define TOPVIEW_HEIGHT_STANDARD  44
#define TOPVIEW_HEIGHT_EXTENDED  76 //29-SEGMENT CONTROL HEIGHT+ 3 PT GAP AFTER SEGMENT CONTROL

@interface QSRootViewController ()

@property (nonatomic, strong)IBOutlet UIView *topView;
@property (nonatomic, strong)IBOutlet UIView *contentView;

@property (nonatomic, strong)QSRegisterViewController *registerViewCon;


@end


@implementation QSRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        BOOL loginStatus = FALSE;
        if(QS_LOGGED_IN == [QSLoginController autoLogin]) {
            loginStatus = true;
        }
        if(loginStatus) {
            QSListingsViewController *listViewCon = [[QSListingsViewController alloc] initWithNibName:@"QSListingsViewController" bundle:nil];
            [self pushViewController:listViewCon];
        } else {
            QSLoginViewController *loginViewCon = [[QSLoginViewController alloc] initWithNibName:@"QSLoginViewController" bundle:nil];
            loginViewCon.delegate = self;
            [self pushViewController:loginViewCon];
        }
        
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
    // Do any additional setup after loading the view from its nib.
    
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

-(void)pushViewController:(UIViewController*)viewController {
    [self.view addSubview:viewController.view];
    
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}



- (void) onStop {
    NSLog(@"onStop");
}

- (void) onLoggedIn
{
    NSLog(@"onLoggedIn");
//    [self dismissModalViewControllerAnimated:YES];
//    _loginController = nil;
//    
//    _autoStart = true;
//    _loggedIn = true;
}

- (void) onSignout:(bool)partial
{
    NSLog(@"onSignout");
    
//    _autoStart = true;
//    _loggedIn = false;
//    
//    [QSLoginController doUnregister:partial];     
//    [self dismissModalViewControllerAnimated:NO];
//    _navController = nil;
}


#pragma mark - LoginViewController delegate handler
-(void)loginCompletedWithStatus:(BOOL)loginStatus withError:(NSError*)error {
    if(loginStatus == TRUE) {
        //remove loginviewcontroller
//        [self.loginViewCon dismissViewControllerAnimated:NO completion:nil];
//        self.loginViewCon = nil;
        
        //show register viewcontroller
        self.registerViewCon = [[QSRegisterViewController alloc] initWithNibName:@"QSRegisterViewController" bundle:nil];
        self.registerViewCon.delegate = self;
        [self presentViewController:self.registerViewCon animated:YES completion:nil];
    }
    else {
        
    }
}

#pragma mark - RegistrationViewController delegate handler

-(void)registrationCompletedWithStatus:(BOOL)registrationStatus withError:(NSError*)error {
    if(registrationStatus == TRUE) {
        
    }
    else {
        
    }
}


@end
