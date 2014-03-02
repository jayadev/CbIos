//
//  QSImagePreviewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSImagePreviewController.h"

@implementation QSImagePreviewController
{
    QSPostController *_controller;
}

@synthesize imageView;
@synthesize selectedImage;

- (QSPostController *) getController
{
    return _controller;
}

- (void) setController:(QSPostController *)controller
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

- (void)viewWillAppear:(BOOL)animated
{
    imageView.image = selectedImage;
    
    [super viewWillAppear:animated];
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


- (IBAction) btnDontUse:(id) sender
{
    //[_controller onPreviewDontUse];
}

- (IBAction) btnUse:(id) sender
{
    //[_controller onPreviewUse];    
}

@end
