//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/26/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "InventoryCheckManager.h"
#import "iPhoneAvailabilityOperation.h"
#import "AppleStore.h"
#import "AppleStoreLocationCache.h"
#import "AppDelegate.h"

@interface InventoryCheckManager ()

@property NSOperationQueue *statusOperationQueue;

@end

@implementation InventoryCheckManager {

}

+ (id)sharedManager {
    static InventoryCheckManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.statusOperationQueue = [[NSOperationQueue alloc] init];
    });
    return sharedMyManager;
}

- (void)addTaskWithModelNumbers:(NSArray *)modelNumbers
                        zipcode:(NSString *)zipcode
                   searchRadius:(double)miles
                        success:(void (^)(NSDictionary *modelNumberToInStockStores))success
                         failed:(void (^)(NSError *))failure {
    iPhoneAvailabilityOperation *operation = [[iPhoneAvailabilityOperation alloc] initWithModelNumbers:modelNumbers andZipCode:zipcode];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *oper, id response) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *modelNumberToStores = [NSMutableDictionary dictionary];
        if (dict) {
            NSArray *appleStores = dict[@"body"][@"stores"];

            double radius = miles * 1609.34;
            __block NSUInteger appleStoreCount = appleStores.count;
            __block int finishedAppleStores = 0;
            for (NSDictionary *store in appleStores) {
                AppleStore *appleStore = [[AppleStore alloc] init];

                appleStore.storeId = store[@"storeNumber"];
                appleStore.name = store[@"storeName"];
                appleStore.address = store[@"address"][@"address2"];
                appleStore.city = store[@"city"];
                appleStore.state = store[@"state"];
                appleStore.zipcode = store[@"address"][@"postalCode"];
                appleStore.email = store[@"storeEmail"];
                appleStore.phoneNumber = store[@"phoneNumber"];
                appleStore.storeUrl = store[@"directionsUrl"];

                NSArray *hours = store[@"storeHours"][@"hours"];
                NSMutableArray *hoursArray = [NSMutableArray array];
                for (NSDictionary *d in hours) {
                    NSString *timings = [[d[@"storeTimings"] stringByReplacingOccurrencesOfString:@" AM" withString:@"AM"] stringByReplacingOccurrencesOfString:@" PM" withString:@"PM"];
                    [hoursArray addObject:[NSString stringWithFormat:@"%@ %@", d[@"storeDays"], timings]];
                }
                appleStore.hours = [NSArray arrayWithArray:hoursArray];

                CLLocationCoordinate2D coordinate = [[AppleStoreLocationCache cacheInstance] getLocationForAppleStore:appleStore.storeId];
                __block BOOL outOfRange = NO;
                if (fabs(coordinate.latitude - 0) > 0.00000000001 && fabs(coordinate.longitude - 0) > 0.00000000001) {
                    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                    outOfRange = [loc distanceFromLocation:[AppDelegate sharedDelegate].location] > radius;

                    if (!outOfRange) {
                        NSDictionary *parts = store[@"partsAvailability"];
                        for (NSString *modelNumber in modelNumbers) {
                            NSString *status = parts[modelNumber][@"pickupDisplay"];

                            NSMutableArray *stores = modelNumberToStores[modelNumber];
                            if (!stores) {
                                stores = [NSMutableArray array];
                                modelNumberToStores[modelNumber] = stores;
                            }
                            if ([status isEqualToString:@"available"]) {
                                [stores addObject:appleStore];
                            }
                        }
                    }

                    @synchronized (appleStores) {
                        finishedAppleStores++;

                        if (finishedAppleStores >= appleStoreCount) {
                            if (success) {
                                success([NSDictionary dictionaryWithDictionary:modelNumberToStores]);
                            }
                        }
                    }
                } else {
                    NSDictionary *addressDict = @{
                            (NSString *) kABPersonAddressCityKey : appleStore.city,
                            (NSString *) kABPersonAddressCountryKey : @"United States",
                            (NSString *) kABPersonAddressCountryCodeKey : @"us",
                            (NSString *) kABPersonAddressStreetKey : appleStore.address,
                            (NSString *) kABPersonAddressZIPKey : appleStore.zipcode
                    };

                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                    [geocoder geocodeAddressDictionary:addressDict
                                     completionHandler:^(NSArray *placemarks, NSError *err) {
                                         if (placemarks.count > 0) {
                                             CLPlacemark *placemark = [placemarks lastObject];
                                             [[AppleStoreLocationCache cacheInstance] setLocation:placemark.location.coordinate forAppleStore:appleStore.storeId];
                                             outOfRange = [placemark.location distanceFromLocation:[AppDelegate sharedDelegate].location] > radius;
                                         }

                                         if (!outOfRange) {
                                             NSDictionary *parts = store[@"partsAvailability"];
                                             for (NSString *modelNumber in modelNumbers) {
                                                 NSString *status = parts[modelNumber][@"pickupDisplay"];

                                                 NSMutableArray *stores = modelNumberToStores[modelNumber];
                                                 if (!stores) {
                                                     stores = [NSMutableArray array];
                                                     modelNumberToStores[modelNumber] = stores;
                                                 }
                                                 if ([status isEqualToString:@"available"]) {
                                                     [stores addObject:appleStore];
                                                 }
                                             }
                                         }

                                         @synchronized (appleStores) {
                                             finishedAppleStores++;

                                             if (finishedAppleStores >= appleStoreCount) {
                                                 if (success) {
                                                     success([NSDictionary dictionaryWithDictionary:modelNumberToStores]);
                                                 }
                                             }
                                         }
                                     }
                    ];
                }
            }
        }
    }                                failure:^(AFHTTPRequestOperation *oper, NSError *error) {
        NSLog(@"failed HTTP call: %@, error: %@", oper.request.URL.absoluteString, error.localizedDescription);
        if (failure) {
            failure(error);
        }
    }];

    [self.statusOperationQueue addOperation:operation];
}
@end