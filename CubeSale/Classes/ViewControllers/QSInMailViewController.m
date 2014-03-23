//
//  QSInMailViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

//#import "SBJson.h"
//#import "OAuthLoginView.h"
#import "QSUtil.h"
#import "QSInMailViewController.h"
#import "QSLoginController.h"

@implementation QSInMailViewController
{
    NSDictionary *_item;
}

@synthesize cellProfileImage;
@synthesize cellName;
@synthesize cellLocation;
@synthesize cellCompany;

@synthesize textSubject;
@synthesize textBody;

- (void) setItem:(NSDictionary *)item
{
    _item = item;
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
    
    [QSUtil updateItemCell:_item 
                          :nil :cellProfileImage :cellName :nil :nil :cellLocation :cellCompany :nil :nil :nil :nil];
    NSString *body = NULL;//[NSString stringWithFormat:@"Hello, \n\n\n\n%@", [QSLoginController getUserName]];
    textBody.text = body;
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

- (IBAction) btnSend:(id) sender
{
    if([textBody.text isEqualToString:@""]) {
        return;
    }
    
//    OAConsumer *consumer = [OAuthLoginView getConsumer];
//    OAToken *token = [QSLoginController getToken];
//
//    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/mailbox"];
//    OAMutableURLRequest *request = 
//    [[OAMutableURLRequest alloc] initWithURL:url
//                                    consumer:consumer
//                                       token:token
//                                    callback:nil
//                           signatureProvider:nil];
//
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    //[request setHTTPShouldHandleCookies:NO];
//    [request setTimeoutInterval:30];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
//    
//    NSString *cuserid = (NSString *)[_item valueForKey:@"email"];
//    NSString *people = [NSString stringWithFormat:@"/people/%@", cuserid];
//    NSDictionary *person = [NSDictionary dictionaryWithObjectsAndKeys:
//                            people, @"_path", nil];
//    NSDictionary *recp = [NSDictionary dictionaryWithObjectsAndKeys:
//                            person, @"person", nil];
//    NSArray *values = [NSArray arrayWithObject:recp];
//    NSDictionary *recps = [NSDictionary dictionaryWithObjectsAndKeys:
//                          values, @"values", nil];
//
//    NSDictionary *messageParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   textSubject.text, @"subject",
//                                   textBody.text, @"body", 
//                                   recps, @"recipients", nil];
//    
//    NSString *message = [messageParams JSONRepresentation];    
//    //[request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];
//    [request setHTTPBodyWithString:message];
//    
//    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
//    [fetcher fetchDataWithRequest:request delegate:self
//                didFinishSelector:@selector(inmailApiCallResult:didFinish:)
//                didFailSelector:@selector(inmailApiCallResult:didFail:)];    
}

//- (void)inmailApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
//{
//    NSString *responseBody = [[NSString alloc] initWithData:data
//                                                   encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"response body: %@", responseBody);
//    NSDictionary *response = [responseBody objectFromJSONString];
//    NSLog(@"response: %@", response);
//    
//        // [QSUtil showAlert:@"Your message has been delivered!"];
//    
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)inmailApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error 
//{
//    NSLog(@"%@",[error description]);
//    
//    NSString *message = [NSString stringWithFormat:@"Failed to deliver the message. Error: %@", [error description]];
//        // [QSUtil showAlert:message];
//}

- (IBAction) btnCancel:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
}
- (void)textFieldDidEndEditing:(UITextField *)textField 
{
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
     [QSUtil animateView:self.view :125 up:YES];
}
- (void)textViewDidEndEditing:(UITextField *)textView
{
     [QSUtil animateView:self.view :125 up:NO];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
@end
