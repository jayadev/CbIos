//
//  QSImagePickerController.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/10/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "QSPostController.h"
#import "QSImagePickerController.h"

@interface QSImagePickerController ()
{
    __unsafe_unretained QSPostController *_controller;
}
@end

@implementation QSImagePickerController

@synthesize imagePicker;

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

- (void) dealloc
{
    NSLog(@"dealloc: QSImagePickerController");
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

- (IBAction) btnClick:(id) sender
{
    [imagePicker takePicture];
}

- (IBAction) btnCancel:(id) sender
{
    [_controller onPickerCancel];
}

- (IBAction) btnLibrary:(id) sender
{
    [_controller onShowLibrary];
}

- (void)setupImagePicker:(BOOL)useLibrary
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = _controller;

    if(!useLibrary && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = NO;
        if([[imagePicker.cameraOverlayView subviews] count] == 0) {
            [imagePicker.cameraOverlayView addSubview:self.view];
        }
    } else {
        
    }
}

@end
