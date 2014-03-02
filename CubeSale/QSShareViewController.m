//
//  QSShareViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 6/2/13.
//  Copyright (c) 2013 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSShareViewController.h"

@interface QSShareViewController ()

@end

@implementation QSShareViewController
{
    NSDictionary *_item;
    NSString *_pid;
}

@synthesize cellProductImage;
@synthesize cellProfileImage;
@synthesize cellPrice;
@synthesize cellPriceImage;
@synthesize cellTime;
@synthesize cellName;
@synthesize cellLocation;

- (void) setItem:(NSDictionary *)item
{
    _item = item;
    _pid = [item valueForKey:@"id"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [QSUtil updateItemCell:_item :cellProductImage :cellProfileImage :cellName :cellPrice :cellPriceImage :cellLocation :nil :cellTime :nil :nil :nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) btnDone:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
