//
//  QSLocationViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 8/26/13.
//  Copyright (c) 2013 None. All rights reserved.
//

#import "QSLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>

@interface QSLocationViewController ()

@end

@implementation QSLocationViewController
{
    __unsafe_unretained QSRegisterViewController *_controller;
    __unsafe_unretained QSProfileViewController *_profileController;

    CLGeocoder *geocoder;
 
    NSString *newCity;
    NSString *newZip;
    NSString *newCcode;
}

@synthesize searchBar;
@synthesize mapView;

- (void) setController:(QSRegisterViewController *)controller :(NSString *)city :(NSString *)zip :(NSString *)ccode
{
    _controller = controller;
    
    newCity = city;
    newZip = zip;
    newCcode = ccode;
}

- (void) setProfileController:(QSProfileViewController *)controller :(NSString *)city :(NSString *)zip :(NSString *)ccode
{
    _profileController = controller;
    
    newCity = city;
    newZip = zip;
    newCcode = ccode;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        geocoder = [[CLGeocoder alloc] init];
        
        newCity = @"";
        newZip = @"";
        newCcode = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    searchBar.text = [NSString stringWithFormat:@"%@, %@", newCity, newZip];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self searchBarSearchButtonClicked:searchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /*MKCoordinateRegion region;
    region.center.latitude = userLocation.coordinate.latitude;
    region.center.longitude = userLocation.coordinate.longitude;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 100 / 112.0;
    region.span = span;
    
    [mapView setRegion:region animated:YES];*/
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
    [searchBar resignFirstResponder];
    NSString *text = searchBar.text;
    [geocoder geocodeAddressString:text completionHandler:
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
             
             [mapView setRegion:region animated:YES];
             
             CLLocation *location = [[CLLocation alloc] initWithLatitude:placemark.region.center.latitude longitude:placemark.region.center.longitude];

             [geocoder reverseGeocodeLocation:location completionHandler:
              ^(NSArray* placemarks, NSError* error){
                  if([placemarks count] > 0) {
                      NSLog(@"address: %@", placemarks);
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      
                      newCity = [placemark locality];
                      newZip = [placemark postalCode];
                      newCcode = [placemark ISOcountryCode];
                      
                      searchBar.text = [NSString stringWithFormat:@"%@, %@", newCity, newZip];
                  }
              }];
         }

/*             NSLog(@"address: %@", placemark.addressDictionary);
             NSString *city = [placemark.addressDictionary valueForKey:(NSString *)kABPersonAddressCityKey];
             NSString *zip = [placemark.addressDictionary valueForKey:(NSString *)kABPersonAddressZIPKey];
             
             if(zip == NULL) {
                 [[[UIAlertView alloc] initWithTitle:@"Cannot get the zipcode from the location"
                                            message:nil
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
             } else {
                 searchBar.text = [NSString stringWithFormat:@"%@, %@", city, zip];
             
                 newCity = city;
                 newZip = zip;
                 newCcode = [placemark.addressDictionary valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
             }
         }*/
    }];
    
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
}

- (IBAction)btnContinue:(UIButton *)sender
{
    if(![newCity isEqualToString:@""]) {
        [_controller setLocation:newCity :newZip :newCcode];
        [_profileController setLocation:newCity :newZip :newCcode];
    }

    [self dismissViewControllerAnimated:YES completion:
     ^() {
         
     }];
}

@end
