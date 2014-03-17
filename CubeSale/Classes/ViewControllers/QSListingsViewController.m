//
//  QSListingsViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 2/1/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "iCarousel.h"

#import "QSUtil.h"
#import "QSLoginController.h"
#import "QSPostController.h"

#import "QSProductViewController.h"
#import "QSListingsViewController.h"
#import "QSProfileViewController.h"

@interface QSListingsViewController () <iCarouselDataSource, iCarouselDelegate, UITableViewDelegate, UITableViewDataSource, QSHttpClientDelegate>
{
    NSMutableArray *_menuData;
    NSMutableArray *_filterData;

    bool _firstLoad;
    bool _reloadView;
    int _curLCount;
    int _totalLCount;
    int _curPage;
    bool _scrolling;

    QSHttpClient *_httpMycmp;
    QSHttpClient *_httpMyl;
    QSHttpClient *_httpWatch;
    QSHttpClient *_httpMy;
    QSHttpClient *_httpUd;
    NSArray *_mycmpItems;
    NSArray *_mylItems;
    NSArray *_myItems;

    iCarousel *_carouselMycmp;
    iCarousel *_carouselMyl;
    iCarousel *_carouselMy;
    iCarousel *_carouselWatch;
    
    __unsafe_unretained QSRootViewController *_controller;

    QSProductViewController *_productController;
    
    QSPostController *_postController;
    QSProfileViewController *_profileController;

    int _gridReusableCellCount;
}

- (NSArray *) getCarouselItems:(iCarousel *)carousel;
- (iCarousel *) addCarousel:(int)index :(NSString *)noTextStr;
- (void) addCarouselToPage:(iCarousel *)carousel :(NSString *)filterStr;

- (void) getListings:(NSString *)filter :(QSHttpClient *)http;
- (void) setupGrids;
- (void)scrollGrid:(BOOL)animated;
- (void) updateHeader;

@end

@implementation QSListingsViewController

@synthesize gridCellHolder;
@synthesize gridPageView;
@synthesize filterLabel;

@synthesize cellProductImage;
@synthesize cellProfileImage;
@synthesize cellPrice;
@synthesize cellPriceImage;
@synthesize cellTime;
@synthesize cellName;
@synthesize cellLocation;
@synthesize cellCommentCount;
@synthesize cellViewCount;
@synthesize cellWatch;
@synthesize cellSold;
@synthesize cellDescription;
@synthesize cellDescriptionImage;
@synthesize cellEdit;
@synthesize cellShare;

@synthesize menuView;
@synthesize menuButton;
@synthesize menuTable;
@synthesize menuCell;

@synthesize activityView;
@synthesize activityIndicator;

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
        _firstLoad = true;
        _reloadView = false;
        _curPage = 0;
        _gridReusableCellCount = 0;      
        _filterData = nil;
        _menuData = nil;
        _scrolling = false;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSListingsViewController");
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
    NSLog(@"loadView: QSListingsViewController");
    
    [super loadView];    
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad: QSListingsViewController");
    
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload: QSListingsViewController");
    _reloadView = true;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_profileController && _profileController.signedOut) {
        _profileController = nil;
        [self onSignout];
        return;
    }
    
    bool loadGrid = false;
    bool fetchGrid = _firstLoad;
    if(_postController) {
        if(WORKING == _postController.postStatus) {
            return;
        }
        
        fetchGrid = (POSTED == _postController.postStatus);
    }
    
    if(_productController) {
        loadGrid = _productController.reloadGrid;
        fetchGrid = _productController.refetchGrid;        
    }
    
    _postController = nil;
    _productController = nil;
    _profileController = nil;
    
    if(fetchGrid) {
        _curLCount = 0;
        _totalLCount = 4;

        _mylItems = _mycmpItems = _myItems = nil;
        
        activityView.hidden = NO;
        [activityIndicator startAnimating];

        _httpMycmp = [[QSHttpClient alloc] init];
        [self getListings:@"mycmp" :_httpMycmp];
        _httpMyl = [[QSHttpClient alloc] init];
        [self getListings:@"mycmpl" :_httpMyl];
        _httpMy = [[QSHttpClient alloc] init];
        [self getListings:@"my" :_httpMy];
        NSMutableArray *pids = [QSLoginController getUserWatchList];
        if(pids.count > 0) {
            _httpWatch = [[QSHttpClient alloc] init];
            [self getListings:@"watch" :_httpWatch];
        } else {
            _totalLCount--;
        }
        _httpUd = [[QSHttpClient alloc] init];
        [self getListings:@"ud" :_httpUd];
    } else if(_reloadView) {
        [self setupGrids];        
    } else if(loadGrid) {
        [_carouselMycmp reloadData];
        [_carouselMyl reloadData];
        [_carouselWatch reloadData];
        [_carouselMy reloadData];
    }
    
    _reloadView = false;
}

- (void) getListings:(NSString *)filter :(QSHttpClient *)http
{
    NSString *apiBase = [QSUtil getApiBase];

    if([filter isEqualToString:@"watch"]) {
        NSMutableArray *pids = [QSLoginController getUserWatchList];
        NSString *joinedString = [pids componentsJoinedByString:@","];
        NSString *url = [NSString stringWithFormat:@"%@/getProductDetails?prod_id=%@", apiBase, joinedString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [http submitRequest:request :url :self :self :@"" :filter];
    } else if([filter isEqualToString:@"ud"]) {
        NSString *userId = [QSLoginController getUserId];
        NSString *url = [NSString stringWithFormat:@"%@/getUserInfo?user_id=%@", apiBase, userId];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [http submitRequest:request :url :self :self :@"" :filter];
    } else {
        NSString *userId = [QSLoginController getUserId];
        NSString *url = [NSString stringWithFormat:@"%@/getUserListings?user_id=%@&filter_type=%@", apiBase, userId, filter];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [http submitRequest:request :url :self :self :@"" :filter];        
    }
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    NSLog(@"listings: %@", userData);

    if(success) {
        if([(NSString *)userData isEqualToString:@"mycmp"]) {
            _mycmpItems = [response valueForKey:@"response_data"];
        } else if([(NSString *)userData isEqualToString:@"myl"]) {
            _mylItems = [response valueForKey:@"response_data"];
        }  else if([(NSString *)userData isEqualToString:@"watch"]) {
            NSArray *watchItems = [response valueForKey:@"response_data"];
            if(watchItems) [QSLoginController initUserWatchItems:watchItems];
        } else if([(NSString *)userData isEqualToString:@"my"]) {
            _myItems = [response valueForKey:@"response_data"];
        } else if([(NSString *)userData isEqualToString:@"ud"]) {
            NSDictionary *ud = [response valueForKey:@"response_data"];
            NSString *company = [ud valueForKey:@"company"];
            bool isVerified = [[ud valueForKey:@"verified"] boolValue];
            
            [QSLoginController setUserCompany:company];
            [QSLoginController setUserValidation:isVerified];
            
            // reset the company
            [_filterData setObject:company atIndexedSubscript:0];
        }
    }
    
    _curLCount++;
    if(_curLCount != _totalLCount) {
        return;
    }
    
    // lets get rid of http clients
    _httpMyl = _httpMycmp = _httpWatch = _httpMy = _httpUd = nil;
    
    // add more to menu

    _firstLoad = false; 
    [self setupGrids];
}

- (void) setupGrids
{
    [activityIndicator stopAnimating];
    activityView.hidden = TRUE;

    _menuData = [[NSMutableArray alloc] initWithCapacity:10];
    _filterData = [[NSMutableArray alloc] initWithCapacity:10];

    [[gridPageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _carouselMyl = _carouselMycmp = _carouselWatch = _carouselMy = nil;

    int gIndex = 0;

    NSString *company = [QSLoginController getUserCompany];
    NSString *city = [QSLoginController getUserCompanyCity];
    
    _carouselMycmp = [self addCarousel:gIndex++ :@"Be the first to post in your company."];
    [self addCarouselToPage:_carouselMycmp :company];

    _carouselMyl = [self addCarousel:gIndex++ :@"Be the first to post in your location."];
    [self addCarouselToPage:_carouselMyl :city];
    
    _carouselMy = [self addCarousel:gIndex++ :@"You have no postings."];
    [self addCarouselToPage:_carouselMy :@"My Listings"];
    
    _carouselWatch = [self addCarousel:gIndex++ :@"You don't have any favorites."];
    [self addCarouselToPage:_carouselWatch :@"Favorites"];
    
    [_menuData addObject:@"Settings"];
    [_menuData addObject:@"My Listings"];
    [_menuData addObject:@"Favorites"];
    [_menuData addObject:@"Feedback"];
    [menuTable reloadData];
    
    self.gridPageView.contentSize = CGSizeMake(self.gridPageView.frame.size.width * gIndex, self.gridPageView.frame.size.height);

    filterLabel.text = company;
    // filterLabel.text =  [_filterData objectAtIndex:_curPage];
    [self scrollGrid:NO];
}

- (iCarousel *) addCarousel:(int)index :(NSString *)noTextStr
{
    //NSInteger spacing = 5;
    //NSInteger inset = 0;
    
    CGRect frame;
    frame.origin.x = self.gridPageView.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = self.gridPageView.frame.size;
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:frame];
    
    carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    carousel.backgroundColor = [UIColor clearColor];
    
    carousel.type = iCarouselTypeLinear;
    carousel.vertical = TRUE;
    carousel.bounces = YES;
    carousel.bounceDistance = 0.25;
    carousel.delegate = self;
    
    frame.size.width -= 50;
    frame.size.height -= 50;
    frame.origin.x += 20;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 8;
    label.text = noTextStr;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.tag = (NSInteger)carousel;
    label.hidden = YES;
    [self.gridPageView addSubview:label];
    
    return carousel;
}

- (void) addCarouselToPage:(iCarousel *)carousel :(NSString *)filterStr
{
        // [_filterData addObject:filterStr];
    // [_menuData addObject:filterStr];
    
    carousel.dataSource = self;
    [self.gridPageView addSubview:carousel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) btnProfile:(id) sender
{
    _profileController = [[QSProfileViewController alloc] initWithNibName:@"QSProfileViewController" bundle:nil];
    [self.navigationController pushViewController:_profileController animated:YES];
}

- (IBAction) btnMenu:(id) sender
{
    int height = menuView.frame.size.height;
    if(0 == menuButton.tag) { // go down
        menuButton.tag = 1;
        menuTable.allowsSelection = YES;
        [QSUtil animateView:menuView :height up:NO];
    } else {
        [self updateHeader];

        menuButton.tag = 0;        
        menuTable.allowsSelection = NO;
        [QSUtil animateView:menuView :height up:YES];
    }
}

- (void) updateHeader
{
    filterLabel.text = [_filterData objectAtIndex:_curPage];
}

- (void) onBack
{
}

- (void) onSignout
{
    [_controller onSignout:true];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSArray *) getCarouselItems:(iCarousel *)carousel
{
    if(carousel == _carouselMycmp) return _mycmpItems;
    else if(carousel == _carouselMyl) return _mylItems;
    else if(carousel == _carouselWatch) return [QSLoginController getUserWatchItems];
    else if(carousel == _carouselMy) return _myItems;
    
    return nil;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSInteger count = 0;
    NSArray *items = [self getCarouselItems:carousel];
    if(items) count = items.count;
    
    UILabel *noItemLabel = (UILabel *)[self.gridPageView viewWithTag:(NSInteger)carousel];
    noItemLabel.hidden = (count > 0);
    
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    // NSLog(@"Creating view indx %d", index);
    NSArray *items = [self getCarouselItems:carousel];
    if(!items) return nil;
    NSDictionary *item = [items objectAtIndex:index];
    NSString *userId = [QSLoginController getUserId];
    NSString *iuserId = [item valueForKey:@"user_id"];
    
    UIView *cell = view;
    if (!cell)
    {
        CGSize size = CGSizeMake(291, 375);
        cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        NSLog(@"reusable grid: %d", ++_gridReusableCellCount);
    }
    
    cell.tag = (NSInteger)((__bridge void *)item);
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[NSBundle mainBundle] loadNibNamed:@"QSListingsItemView" owner:self options:nil];

    if([userId isEqualToString:iuserId]) {
        cellWatch.hidden = YES;
        cellEdit.hidden = NO;
        cellEdit.tag = (NSInteger)((__bridge void *)item);
    } else {
        cellEdit.hidden = YES;
        cellWatch.hidden = NO;
        cellWatch.tag = (NSInteger)((__bridge void *)item);
        [self setWatchState:cellWatch :item];
    }
    cellShare.tag = (NSInteger)((__bridge void *)cellProductImage);
    cellProductImage.tag = (NSInteger)((__bridge void *)item);
    
    if(_firstLoad) {
        [cellProductImage setFadeIn];
    }
    [QSUtil updateItemCell:item :cellProductImage :cellProfileImage :cellName :cellPrice :cellPriceImage :cellLocation :nil :cellTime :cellCommentCount :cellViewCount :cellSold];
    NSObject *desc = [item valueForKey:@"description"];
    if(desc && ([NSNull null] != desc) && !([(NSString *)desc isEqualToString:@""])) {
        cellDescription.text = (NSString *)desc;
        cellDescriptionImage.hidden = NO;
    } else {
        cellDescription.text = @"";
        cellDescriptionImage.hidden = YES;
    }

    [cell addSubview:gridCellHolder];
    
    self.gridCellHolder = nil;
    self.cellProductImage = nil;
    self.cellProfileImage = nil;
    self.cellPrice = nil;
    self.cellPriceImage = nil;
    self.cellTime = nil;
    self.cellName = nil;
    self.cellLocation = nil;
    self.cellCommentCount = nil;
    self.cellViewCount = nil;
    self.cellWatch = nil;
    self.cellSold = nil;
    self.cellDescription = nil;
    self.cellDescriptionImage = nil;
    
    return cell;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionVisibleItems)
    {
        return 3.0f;
    }
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Did tap at index %d", index);
    
    NSArray *items = [self getCarouselItems:carousel];
    if(!items) return;
    NSDictionary *item = [items objectAtIndex:index];
    
    _productController = [[QSProductViewController alloc] initWithNibName:@"QSProductViewController" bundle:nil];
    [_productController setItem:item];
    [self.navigationController pushViewController:_productController animated:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!_menuData) {
        return 0;
    }

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

    if(indexPath.row == 0) {
        [self btnProfile:nil];
    } else if(indexPath.row == 1) { // My
        _curPage = 2;
        [self scrollGrid:YES];
    } else if(indexPath.row == 2) { // Favs
        _curPage = 3;
        [self scrollGrid:YES];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:feedback@cubesales.com?subject=CubeSales%20feedback"]];        
    }
    
    [self btnMenu:nil];
}

- (IBAction) btnPost:(id) sender
{
    bool checkUser = true;
    if(checkUser && ![QSLoginController getUserValidation]) {
        [QSUtil showAlert:@"Work email not verified" :@"Please verify your work email or update it on the Settings screen to resend the link"];
        return;
    }

    _postController = [[QSPostController alloc] init];
    [_postController start:self.navigationController :NO :nil];    
}

- (IBAction) btnEdit:(id) sender
{
    UIButton *button = (UIButton *) sender;
    NSDictionary *item = (__bridge NSDictionary *)((void *)button.tag);
    
    _postController = [[QSPostController alloc] init];
    [_postController start:self.navigationController :YES :item];
}

- (IBAction) btnShare:(id) sender
{
    UIButton *button = (UIButton *) sender;
    UIImageView *productImage = (__bridge UIImageView *)((void *)button.tag);
    NSDictionary *item = (__bridge NSDictionary *)((void *)productImage.tag);
    
    NSString *text = @"Checkout this item on CubeOut!";
    NSString *linkStr = [NSString stringWithFormat:@"%@?pid=%@", [QSUtil getFEProductLanding],[item valueForKey:@"id"]];
    NSURL *link = [[NSURL alloc] initWithString:linkStr];
    UIImage *image = productImage.image;
    NSArray *activityItems = nil;
    if (image != nil) {
        activityItems = @[text, image, link];
    } else {
        activityItems = @[text, link];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation: QSListingsViewController: %@", scrollView);

    _scrolling = false;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // NSLog(@"scrollViewDidScroll: QSListingsViewController: %@", sender);
    
    if(_scrolling) return;

    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.gridPageView.frame.size.width;
    int page = floor((self.gridPageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if((page >= 0) && (page < _filterData.count)) {
        //filterLabel.text =  [_filterData objectAtIndex:page];
        if(_curPage != page) {
            _curPage = page;
            [self updateHeader];
        }
    }
}

- (void)scrollGrid:(BOOL)animated
{
    if(animated) {
        CGFloat pageWidth = self.gridPageView.frame.size.width;
        int page = floor((self.gridPageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if(page != _curPage) {
            _scrolling = true;
        }
    }

    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.gridPageView.frame.size.width * _curPage;
    frame.origin.y = 0;
    frame.size = self.gridPageView.frame.size;
    [self.gridPageView scrollRectToVisible:frame animated:animated];    
}

- (IBAction) toggleWatch:(id) sender
{
    UIButton *button = (UIButton *) sender;
    NSDictionary *item = (__bridge NSDictionary *)((void *)button.tag);
    NSString *pid = [item valueForKey:@"id"];

    if([QSLoginController isInUserWatch:pid]) {
        [QSLoginController removeUserWatch:pid];
    } else {
        [QSLoginController addUserWatch:item];
    }
    
    [self setWatchState:button :item];
}

- (void) setWatchState:(UIButton *)button :(NSDictionary *)item
{
    NSString *pid = [item valueForKey:@"id"];

    if([QSLoginController isInUserWatch:pid]) {
        [button setImage:[UIImage imageNamed:@"liked.png"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    }
}

@end
