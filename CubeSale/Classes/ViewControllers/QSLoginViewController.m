//
//  QSLoginViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/18/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSLoginViewController.h"

@implementation QSLoginViewController
{
    __unsafe_unretained QSLoginController *_controller;
}

@synthesize carousel;
@synthesize pageControl;

- (QSLoginController *) getController
{
    return _controller;
}

- (void) setController:(QSLoginController *)controller
{
    _controller = controller;
}

- (void)dealloc
{
    NSLog(@"QSLoginViewController dealloc");
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
    
    self.carousel.type = iCarouselTypeCoverFlow2;
    self.carousel.bounces = NO;
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

- (IBAction)btnLogin:(UIButton *)sender
{
    [_controller doLogin];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 4;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        NSLog(@"allocate %d", index);
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 326.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
    }
    else
    {
        imageView = (UIImageView *)view;
    }
    
    imageView.image =
        [UIImage imageNamed:[NSString stringWithFormat:@"reg_ill%d", (index + 1)]];
    return imageView;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionVisibleItems)
    {
        return 3.0f;
    }
    return value;
}

- (void)carouselDidScroll:(iCarousel *)thisCarousel
{
    [pageControl setCurrentPage:[thisCarousel currentItemIndex]];
}

@end
