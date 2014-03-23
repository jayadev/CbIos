//
//  QSMyListingsViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/2/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QSHttpClient.h"
#import "QSUtil.h"
#import "QSLoginController.h"

#import "GMGridView.h"
#import "QSPostController.h"
#import "QSProductViewController.h"
#import "QSMyListingsViewController.h"

@interface QSMyListingsViewController () <GMGridViewDataSource, GMGridViewActionDelegate, QSHttpClientDelegate>
{
    bool _firstLoad;
    
    QSHttpClient *_http;
    NSArray *_items;
    GMGridView *_gmGridView;
    int _curGridCell;
    
    QSPostController *_postController;    
}

- (GMGridView *) addGrid:(int)index;

@end

@implementation QSMyListingsViewController

@synthesize gridCellHolder;
@synthesize gridPageView;

@synthesize cellProductImage;
@synthesize cellProfileImage;
@synthesize cellPrice;
@synthesize cellTime;
@synthesize cellName;
@synthesize cellLocation;
@synthesize cellCommentCount;
@synthesize cellWatch;

@synthesize activityView;
@synthesize activityIndicator;
@synthesize noItemLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _firstLoad = true;
        _curGridCell = 0;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSMyListingsViewController");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
}

- (GMGridView *) addGrid:(int)index
{
    NSInteger spacing = 5;
    NSInteger inset = 0;
    
    CGRect frame;
    frame.origin.x = self.gridPageView.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = self.gridPageView.frame.size;
    
    GMGridView *grid = [[GMGridView alloc] initWithFrame:frame];
    
    grid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    grid.backgroundColor = [UIColor clearColor];
    
    grid.style = GMGridViewStyleSwap;
    grid.itemSpacing = spacing;
    grid.minEdgeInsets = UIEdgeInsetsMake(4, inset, inset, inset);
    grid.centerGrid = YES;
    grid.actionDelegate = self;
    grid.dataSource = self;    
    
    [self.gridPageView addSubview:grid];
    //[self.view sendSubviewToBack:gmGridView];
    
    return grid;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    bool reloadGrid = _firstLoad;
    if(_postController) {
        reloadGrid = (POSTED == _postController.postStatus);
    }
    _postController = nil;
    if(!reloadGrid) {
        return;
    }
    
    _items = nil;
    if(nil != _gmGridView) {
        [_gmGridView removeFromSuperview];
        _gmGridView = nil;
    }
    [activityIndicator startAnimating];
    activityView.hidden = NO;
    
    NSString *apiBase = NULL;//[QSUtil getApiBase];
    NSString *userId = NULL;//[QSLoginController getUserId];
    NSString *url = [NSString stringWithFormat:@"%@/getUserListings?user_id=%@&filter_type=my", apiBase, userId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    _http = [[QSHttpClient alloc] init];
//    [_http submitRequest:request :url :self :self :@"" :nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    _http = nil;
    [activityIndicator stopAnimating];
    
    if(!success) {
        [self btnBack:nil];
        return;
    }
    
    NSArray *items = [response valueForKey:@"response_data"];
    if((nil == items) || (0 == items.count)) {
        noItemLabel.hidden = FALSE;
        return;
    }

    _items = items;
    _gmGridView = [self addGrid:0];
    [_gmGridView scrollToObjectAtIndex:_curGridCell animated:NO];

    activityView.hidden = TRUE;
    _firstLoad = false;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _items.count;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(294, 275);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    NSDictionary *item = [_items objectAtIndex:index];
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];        
        cell.contentView = view;
    }    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[NSBundle mainBundle] loadNibNamed:@"QSListingsItemView" owner:self options:nil];
    
    if(_firstLoad) {
        [cellProductImage setFadeIn];
    }

    [QSUtil updateItemCell:item :cellProductImage :cellProfileImage :cellName :cellPrice :nil :cellLocation :nil :cellTime :cellCommentCount :nil :nil];
    
    [cell.contentView addSubview:gridCellHolder];
    
    self.gridCellHolder = nil;
    self.cellProductImage = nil;
    self.cellProfileImage = nil;
    self.cellPrice = nil;
    self.cellTime = nil;
    self.cellName = nil;
    self.cellLocation = nil;
    self.cellCommentCount = nil;
    self.cellWatch = nil;
    
    return cell;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position :(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"Did tap at index %d", position);
    _curGridCell = position;

    NSDictionary *item = [_items objectAtIndex:position];
    
    _postController = [[QSPostController alloc] init];
    [_postController start:self.navigationController :YES :item];
}

- (IBAction) btnBack:(id) sender;
{
    if(_http) {
        [_http cancelRequest];
        _http = nil;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end
