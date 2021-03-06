//
//  QSAppDelegate.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/8/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSAppDelegate.h"

#import "QSRootViewController.h"
#import "QSProductViewController.h"
#import "QSPostViewController.h"
#import "QSPostController.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation QSAppDelegate
{
    QSRootViewController *_root;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application launched");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _root = [[QSRootViewController alloc] initWithNibName:@"QSRootViewController" bundle:NULL];
    self.window.rootViewController = _root;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    NSLog(@"application::openURL: %@ from %@", url, sourceApplication);
    
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [_root onStop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [_root onStart];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
