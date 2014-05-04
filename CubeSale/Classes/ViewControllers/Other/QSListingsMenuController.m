//
//  QSListingsMenuController.m
//  CubeSale
//
//  Created by Sushant Kumar on 2/6/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSListingsMenuController.h"
#import "QSPostController.h"
#import "QSApiConstants.h"

@interface QSListingsMenuController () <UITableViewDelegate, UITableViewDataSource>
{    
    NSArray *_menuData;
    
    QSRootViewController *_controller;
    QSPostController *_postController;
}

@end

@implementation QSListingsMenuController

@synthesize menuTable;
@synthesize menuCell;

- (QSRootViewController *) getController
{
    return _controller;
}

- (void) setController:(QSRootViewController *)controller
{
    _controller = controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    // Do any additional setup after loading the view from its nib.
    _menuData = [[NSArray alloc] initWithObjects:@"Home", @"Post an Item", @"My Listings",
                 @"Settings", @"Sign Out", nil];    
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

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"QSListingsMenuCell" owner:self options:nil];        
        cell = self.menuCell;
        self.menuCell = nil;        
    }
    
    NSUInteger row = [indexPath row];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [_menuData objectAtIndex:row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
    
    switch(indexPath.row) {
        case 0: {
            [self onBack];
        }
        break;
        case 1: {
        }
        break;    
        case 4: {
            [self onSignout];
        }
        break;
    }
}

- (void) onBack {
    
}

- (void) onSignout {
    [_controller onSignout:true];
}

@end
