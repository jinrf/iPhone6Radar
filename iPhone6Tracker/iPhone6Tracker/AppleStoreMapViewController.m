//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import "AppleStoreMapViewController.h"
#import "AppDelegate.h"
#import "AppleStore.h"
#import "AppleStoreLocationCache.h"

@interface AppleStoreMapViewController ()

@property CLGeocoder *geocoder;
@property CLLocation *storeLocation;

@end;

@implementation AppleStoreMapViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.loadingView startAnimating];

    self.geocoder = [[CLGeocoder alloc] init];

    __weak AppleStoreMapViewController *controller = self;
    __weak AppleStoreLocationCache *cache = [AppleStoreLocationCache cacheInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSDictionary *addressDict = @{
                (NSString *) kABPersonAddressCityKey : controller.store.city,
                (NSString *) kABPersonAddressCountryKey : @"United States",
                (NSString *) kABPersonAddressCountryCodeKey : @"us",
                (NSString *) kABPersonAddressStreetKey : controller.store.address,
                (NSString *) kABPersonAddressZIPKey : controller.store.zipcode
        };

        CLLocationCoordinate2D storeLocation = [[AppleStoreLocationCache cacheInstance] getLocationForAppleStore:self.store.storeId];
        if (storeLocation.latitude != 0 && storeLocation.longitude != 0) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:storeLocation.latitude longitude:storeLocation.longitude];
            [controller updateStoreLocation:location];
        } else {
            [controller.geocoder geocodeAddressDictionary:addressDict
                                        completionHandler:^(NSArray *placemarks, NSError *error) {
                                            if (error) {
                                                NSLog(@"failed to geocode apple store address: %@, error: %@", addressDict, error.localizedDescription);
                                            }

                                            if ([placemarks count] > 0) {
                                                CLPlacemark *placemark = [placemarks firstObject];

                                                [cache setLocation:placemark.location.coordinate forAppleStore:controller.store.storeId];
                                                [controller updateStoreLocation:placemark.location];
                                            }
                                        }
            ];
        }
    });

    self.title = self.store.name;
}

- (void) updateStoreLocation:(CLLocation *)storeLocation {
    __weak AppleStoreMapViewController *controller = self;

    controller.storeLocation = storeLocation;

    CLLocationCoordinate2D location1 = [AppDelegate sharedDelegate].location.coordinate;
    CLLocationCoordinate2D location2 =storeLocation.coordinate;

    CLLocationCoordinate2D min = CLLocationCoordinate2DMake(MIN(location1.latitude, location2.latitude), MIN(location1.longitude, location2.longitude));
    CLLocationCoordinate2D max = CLLocationCoordinate2DMake(MAX(location1.latitude, location2.latitude), MAX(location1.longitude, location2.longitude));

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((max.latitude + min.latitude) / 2.0, (max.longitude + min.longitude) / 2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake((max.latitude - min.latitude) * 1.25, (max.longitude - min.longitude) * 1.25);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

    CLLocationDistance dist = [controller.storeLocation distanceFromLocation:[AppDelegate sharedDelegate].location];
    dispatch_async(dispatch_get_main_queue(), ^{
        controller.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f miles", dist / 1609.34];

        [controller.mapView setRegion:[controller.mapView regionThatFits:region] animated:YES];

        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = storeLocation.coordinate;
        point.title = @"Apple Store";
        point.subtitle = controller.store.name;
        [controller.mapView addAnnotation:point];

        MKPointAnnotation *point2 = [[MKPointAnnotation alloc] init];
        point2.coordinate = [AppDelegate sharedDelegate].location.coordinate;
        point2.title = @"You Are Here";
        [controller.mapView addAnnotation:point2];

        [controller.loadingView stopAnimating];
        [controller.loadingView removeFromSuperview];
    });
}

- (IBAction)showDrivingDirection {
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:self.storeLocation.coordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:place];
    destination.name = [NSString stringWithFormat:@"Apple Store, %@", self.store.name];
    NSArray *items = @[destination];
    NSDictionary *options = @{
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
    };
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *annotationIdentifier = @"annotationIdentifier";
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];

    if ([annotation.title isEqualToString:@"Apple Store"]) {
        pinView.pinColor = MKPinAnnotationColorRed;
    } else {
        pinView.pinColor = MKPinAnnotationColorGreen;
    }

    pinView.canShowCallout = YES;
    return pinView;
}
@end