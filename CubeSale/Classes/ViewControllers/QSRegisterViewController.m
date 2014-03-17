//
//  QSRegisterViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/21/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSRegisterViewController.h"
#import "QSUtil.h"
#import "QSLocationViewController.h"

@implementation QSRegisterViewController
{
    __unsafe_unretained QSLoginController *_controller;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    
    NSString *_ccode;
    NSString *_city;
    NSString *_zip;
}

@synthesize cellProfileImage;
@synthesize cellName;
@synthesize cellLocation;

@synthesize hobbyView;
@synthesize emailView;
@synthesize locationView;
@synthesize companyEmailView;

@synthesize consentButton;
@synthesize noConsentButton;

@synthesize locationButton;
@synthesize submitButton;

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
    NSLog(@"QSRegisterViewController dealloc");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        geocoder = [[CLGeocoder alloc] init];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
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

    _city = [QSLoginController getUserCompanyCity];
    _zip = [QSLoginController getUserCompanyCity];
    _ccode = [QSLoginController getUserCompanyCcode];
    
    NSString *profileStr = [QSLoginController getUserProfilerImage];
    if(profileStr.length > 0) {
        NSURL *profileUrl = [[NSURL alloc] initWithString:profileStr];
        [cellProfileImage loadFromUrl:profileUrl];
    }
    
    cellName.text = [QSLoginController getUserName];
    cellLocation.text = [QSLoginController getUserLocation];
    
    emailView.text = [QSLoginController getUserEmail];
    companyEmailView.text = [QSLoginController getUserCompanyEmail];
    locationView.text = [QSLoginController getUserLocation];

    NSString *hobby = [QSLoginController getUserHobby];
    if(nil != hobby) {
        hobbyView.text = hobby;
    }    
    
    [hobbyView setDelegate:self];
    [locationView setDelegate:self];
    [emailView setDelegate:self];
    [companyEmailView setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [locationManager stopMonitoringSignificantLocationChanges];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [locationManager stopMonitoringSignificantLocationChanges];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:
     ^(NSArray* placemarks, NSError* error) {
         [self onLocationFetch:false];

         if([placemarks count] > 0) {
             NSLog(@"location: %@", placemarks);
             CLPlacemark *placemark = [placemarks objectAtIndex:0];

             [self setLocation:[placemark locality] :[placemark postalCode] :[placemark ISOcountryCode]];
         }
     }];
    
    [locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationEntered:(NSString *)location
{
    if(location.length == 0) {
        return;
    }
    
    [self onLocationFetch:true];

    [geocoder geocodeAddressString:location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if([placemarks count] > 0) {
             NSLog(@"location: %@", placemarks);
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             MKCoordinateRegion region;
             region.center.latitude = placemark.region.center.latitude;
             region.center.longitude = placemark.region.center.longitude;
             
             MKCoordinateSpan span;
             double radius = placemark.region.radius / 1000; // convert to km
             span.latitudeDelta = radius / 112.0;
             region.span = span;
             
             CLLocation *location = [[CLLocation alloc] initWithLatitude:placemark.region.center.latitude longitude:placemark.region.center.longitude];
             
             [geocoder reverseGeocodeLocation:location completionHandler:
              ^(NSArray* placemarks, NSError* error) {
                  [self onLocationFetch:false];
                  
                  if([placemarks count] > 0) {
                      NSLog(@"address: %@", placemarks);
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      
                      [self setLocation:[placemark locality] :[placemark postalCode] :[placemark ISOcountryCode]];
                  }
              }];
         } else {
            [self onLocationFetch:false];
         }
     }];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
	[textField resignFirstResponder];
    
    if(textField == locationView) {
        [self locationEntered:locationView.text];
    }
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    if(textField == locationView) {
        [QSUtil animateView:self.view :125 up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    if(textField == locationView) {
        [QSUtil animateView:self.view :125 up:NO];
    }
}

- (IBAction) btnConsent:(id) sender
{
    consentButton.hidden = NO;
    noConsentButton.hidden = YES;
}

- (IBAction) btnNoConsent:(id) sender
{
    consentButton.hidden = YES;
    noConsentButton.hidden = NO;    
}

- (IBAction) btnRegister:(id) sender
{
    NSLog(@"email: %@, location: %@", emailView.text, locationView.text);

    if(0 == emailView.text.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your email id"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    if(0 == companyEmailView.text.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your work email id"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    if(_ccode.length == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your work location"
//                                                        message:nil
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;        
//    }
    
    bool consent = !consentButton.hidden;
    [_controller onRegisterDone:emailView.text :companyEmailView.text :_zip :_city :@"bangalore" :hobbyView.text :consent];
}

- (IBAction) btnLocation:(id) sender
{
    if(locationView.text.length == 0) {
        [self onLocationFetch:true];
    }
    [locationManager startMonitoringSignificantLocationChanges];

/*    QSLocationViewController *locationController = [[QSLocationViewController alloc] initWithNibName:@"QSLocationViewController" bundle:nil];
    [locationController setController:self :_city :_zip :_ccode];
    [self presentViewController:locationController animated:YES completion:
     ^() {
     }];*/
}

- (void)onLocationFetch:(bool)start
{
    submitButton.enabled = !start;
    locationButton.enabled = !start;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = start;
}

- (void) setLocation:(NSString *)city :(NSString *)zip :(NSString *)ccode
{
    _city = city;
    _zip = zip;
    _ccode = ccode;
    
    locationView.text = [NSString stringWithFormat:@"%@, %@", _city, _zip];
}

+ (QSHttpClient *) postRegistration:(NSString *)email :(NSString *)companyEmail :(NSString *)zip :(NSString *)city :(NSString *)ccode :(NSString *)hobby :(bool)update :(bool)consent :(UIViewController *)parent :(id <QSHttpClientDelegate>)delegate
{
    s_email = email;
    s_companyEmail = companyEmail;
    s_companyZip = zip;
    s_companyCity = city;
    s_companyCcode = ccode;
    s_location = [NSString stringWithFormat:@"%@, %@", city, zip];
    s_hobby = hobby;
    
        // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *bodyString = [NSString stringWithFormat:
                            @"user_id=%@&email=%@&firstname=%@&lastname=%@&username=%@&img_url=%@&profile_url=%@&hobby=%@&company_email=%@&company_zip=%@&company_city=%@&company_ccode=%@&update=%@&consent=%@",
                            escapeString(s_userId), escapeString(s_email),
                            escapeString(s_firstName), escapeString(s_lastName), escapeString(s_formattedName),
                            escapeString(s_pictureUrl), escapeString(s_profileUrl),
                            escapeString(s_hobby),
                            escapeString(s_companyEmail), escapeString(s_companyZip),
                            escapeString(s_companyCity), escapeString(s_companyCcode),
                            (update ? @"1" : @"0"), (consent ? @"1" : @"0")];
    NSLog(@"Submitting registration: %@", bodyString);
    
    NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSString *apiBase = [QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/registerUser", apiBase];
    
    QSHttpClient *http = [[QSHttpClient alloc] init];
    http.disableUI = true;
    [http submitRequest:request :url :parent :delegate :@"" :nil];
    
    return http;
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    if(!success) {
        return;
    }
    
    _registered = true;
    
    [QSLoginController storeUserData];
    
    [_controller onLoggedIn];
}

+ (void) storeUserData
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              s_token, @"token",
                              s_userId, @"id",
                              s_email, @"email",
                              s_firstName, @"first",
                              s_lastName, @"last",
                              s_formattedName, @"formatted",
                              s_profileUrl, @"profileUrl",
                              s_pictureUrl, @"pictureUrl",
                              s_companyEmail, @"companyEmail",
                              s_companyZip, @"companyZip",
                              s_companyCity, @"companyCity",
                              s_companyCcode, @"companyCcode",
                              s_location, @"location",
                              s_hobby, @"hobby",
                              nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:DATA_VERSION forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults] setObject:s_watchList forKey:@"userwatch"];    
}

@end
