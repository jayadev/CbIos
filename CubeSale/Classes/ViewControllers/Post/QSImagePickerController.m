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
}

@end

@implementation QSImagePickerController

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
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) btnClick:(id) sender
{
    if(self.delegate) {
        [self.delegate takePicture];
    }
}

- (IBAction) btnCancel:(id) sender
{
    if(self.delegate){
        [self.delegate dismissImagePickerController];
    }
}

- (IBAction) btnLibrary:(id) sender
{
    if(self.delegate){
        [self.delegate showImagePickerWithPhotoAlbum];
    }
}




@end
