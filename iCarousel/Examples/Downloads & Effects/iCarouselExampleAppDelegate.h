//
//  iCarouselExampleAppDelegate.h
//  iCarouselExample
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iCarouselExampleViewController;

@interface iCarouselExampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet iCarouselExampleViewController *viewController;

@end
