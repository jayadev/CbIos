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
#import "QSApiConstants.h"

@interface QSRegisterViewController ()

@property (nonatomic, strong) IBOutlet QSLazyImage *cellProfileImage;
@property (nonatomic, strong) IBOutlet UILabel *cellName;
@property (nonatomic, strong) IBOutlet UILabel *cellLocation;

@property (nonatomic, strong) IBOutlet UITextView *hobbyView;
@property (nonatomic, strong) IBOutlet UITextField *emailView;
@property (nonatomic, strong) IBOutlet UITextField *locationView;
@property (nonatomic, strong) IBOutlet UITextField *companyEmailView;

@property (nonatomic, strong) IBOutlet UIButton *consentButton;
@property (nonatomic, strong) IBOutlet UIButton *noConsentButton;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

@property (nonatomic,strong)QSHttpClient *httpClient;
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic,strong)CLGeocoder *geocoder;

- (IBAction) btnConsent:(id) sender;
- (IBAction) btnNoConsent:(id) sender;
- (IBAction) btnRegister:(id) sender;
- (IBAction) btnLocation:(id) sender;

@end

@implementation QSRegisterViewController

@synthesize cellProfileImage;
@synthesize cellName;
@synthesize cellLocation;
@synthesize locationView;
@synthesize hobbyView;
@synthesize emailView;
@synthesize companyEmailView;
@synthesize submitButton;
@synthesize consentButton;
@synthesize noConsentButton;
@synthesize locationButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.geocoder = [[CLGeocoder alloc] init];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)dealloc
{
    NSLog(@"QSRegisterViewController dealloc");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    _city = [QSLoginController getUserCompanyCity];
//    _zip = [QSLoginController getUserCompanyCity];
//    _ccode = [QSLoginController getUserCompanyCcode];
    
//    NSString *profileStr = [QSLoginController getUserProfilerImage];
//    if(profileStr.length > 0) {
//        NSURL *profileUrl = [[NSURL alloc] initWithString:profileStr];
//        [cellProfileImage loadFromUrl:profileUrl];
//    }
    
//    cellName.text = [QSLoginController getUserName];
//    cellLocation.text = [QSLoginController getUserLocation];
//    
//    emailView.text = [QSLoginController getUserEmail];
//    companyEmailView.text = [QSLoginController getUserCompanyEmail];
//    locationView.text = [QSLoginController getUserLocation];
//
//    NSString *hobby = [QSLoginController getUserHobby];
//    if(nil != hobby) {
//        hobbyView.text = hobby;
//    }    
    
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
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate -

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:
     ^(NSArray* placemarks, NSError* error) {
         [self onLocationFetch:false];

         if([placemarks count] > 0) {
             NSLog(@"location: %@", placemarks);
             CLPlacemark *placemark = [placemarks objectAtIndex:0];

             [self setLocation:[placemark locality] :[placemark postalCode] :[placemark ISOcountryCode]];
         }
     }];
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationEntered:(NSString *)location
{
    if(location.length == 0) {
        return;
    }
    
    [self onLocationFetch:true];

    [self.geocoder geocodeAddressString:location completionHandler:
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
             
             [self.geocoder reverseGeocodeLocation:location completionHandler:
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

- (void)onLocationFetch:(bool)start
{
    submitButton.enabled = !start;
    locationButton.enabled = !start;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = start;
}

- (void) setLocation:(NSString *)city :(NSString *)zip :(NSString *)ccode
{
//    _city = city;
//    _zip = zip;
//    _ccode = ccode;
    
        //locationView.text = [NSString stringWithFormat:@"%@, %@", _city, _zip];
}

#pragma mark UITextViewDelegate -

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

#pragma mark UITextFieldDelegate -

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

#pragma mark Buttom Action Handler -

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
    NSString *email = emailView.text;
    if(![QSUtil isValidEmailId:email]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your email id"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *companyEmail = companyEmailView.text;
    if(![QSUtil isValidEmailId:companyEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your work email id"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *workLocation =  locationView.text;
    if(![QSUtil isEmptyString:workLocation]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your work location"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;        
    }
    bool consent = !consentButton.hidden;
    NSString *consentStr = (consent ? @"1" : @"0");
    
    @try {
            //create post request data dict
        NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
        [postDict setObject:nil forKey:@"user_id"];
        [postDict setObject:[QSUtil geteEscapeString:email] forKey:@"email"];
        [postDict setObject:nil forKey:@"firstname"];
        [postDict setObject:nil forKey:@"lastname"];
        [postDict setObject:nil forKey:@"img_url"];
        [postDict setObject:nil forKey:@"profile_url"];
        [postDict setObject:nil forKey:@"hobby"];
        [postDict setObject:[QSUtil geteEscapeString:companyEmail] forKey:@"company_email"];
        [postDict setObject:nil forKey:@"company_zip"];
        [postDict setObject:nil forKey:@"company_city"];
        [postDict setObject:nil forKey:@"company_ccode"];
        [postDict setObject:nil forKey:@"update"];
        [postDict setObject:consentStr forKey:@"consent"];
        
        if(!self.httpClient){
            self.httpClient = [[QSHttpClient alloc] init];
            self.httpClient.delegate = self;
        }
        [self.httpClient executeNetworkRequest:RequestType_Post WithRelativeUrl:QS_API_REGISTERUSER parameters:postDict];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception While Reistering User:%@",exception);
    }
}

- (IBAction) btnLocation:(id) sender
{
    if(locationView.text.length == 0) {
        [self onLocationFetch:true];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];

/*    QSLocationViewController *locationController = [[QSLocationViewController alloc] initWithNibName:@"QSLocationViewController" bundle:nil];
    [locationController setController:self :_city :_zip :_ccode];
    [self presentViewController:locationController animated:YES completion:
     ^() {
     }];*/
}

#pragma mark QSHttpClient Delegate Handler -

- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {
    if(!error) {
        
    }
    else {
        
    }
}


//+ (void) storeUserData
//{
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                              s_token, @"token",
//                              s_userId, @"id",
//                              s_email, @"email",
//                              s_firstName, @"first",
//                              s_lastName, @"last",
//                              s_formattedName, @"formatted",
//                              s_profileUrl, @"profileUrl",
//                              s_pictureUrl, @"pictureUrl",
//                              s_companyEmail, @"companyEmail",
//                              s_companyZip, @"companyZip",
//                              s_companyCity, @"companyCity",
//                              s_companyCcode, @"companyCcode",
//                              s_location, @"location",
//                              s_hobby, @"hobby",
//                              nil];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:DATA_VERSION forKey:@"version"];
//    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"userinfo"];
//    [[NSUserDefaults standardUserDefaults] setObject:s_watchList forKey:@"userwatch"];    
//}

@end
