//
//  QSRootViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSLoginController.h"
#import "QSRootViewController.h"
#import "QSListingsViewController.h"

@implementation QSRootViewController
{
    QSLoginController *_loginController;
    
    UINavigationController *_navController;
    QSListingsViewController *_listingsController;
    
    bool _autoStart;
    bool _loggedIn;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _autoStart = false;
        _loggedIn = false;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"Root::viewDidAppear");
    
    if(_autoStart) {
        _autoStart = false;
        [self onStart];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void) onStart
{
    NSLog(@"Root::onStart");
    
    if(_loginController != nil) {
        NSLog(@"Login controller is live, noop");
        return;
    }
    
    if(!_loggedIn) {
        // auto login
        if(QS_LOGGED_IN == [QSLoginController autoLogin]) {
            _loggedIn = true;
        }
    }
    
    if(_loggedIn) {
        NSLog(@"Logged in, main app flow");
        
        _listingsController = [[QSListingsViewController alloc] initWithNibName:@"QSListingsViewController" bundle:nil];
        [_listingsController setController:self];
        
        _navController = [[UINavigationController alloc] initWithRootViewController:_listingsController];
        _navController.navigationBarHidden = YES;

        [self presentModalViewController:_navController animated:YES];
    } else {
        NSLog(@"Not logged in, login flow");

        _loginController = [[QSLoginController alloc] init];
        [_loginController setController:self];
        [_loginController start:self];
    }
}

- (void) onStop
{
    NSLog(@"onStop");
    _loggedIn = false;
    if(_navController) {
        [self dismissModalViewControllerAnimated:NO];
        _navController = nil;
    }
}

- (void) onLoggedIn
{
    NSLog(@"onLoggedIn");
    [self dismissModalViewControllerAnimated:YES];
    _loginController = nil;
    
    _autoStart = true;
    _loggedIn = true;
}

- (void) onSignout:(bool)partial
{
    NSLog(@"onSignout");
    
    _autoStart = true;
    _loggedIn = false;
    
    [QSLoginController doUnregister:partial];     
    [self dismissModalViewControllerAnimated:NO];
    _navController = nil;
}

@end
