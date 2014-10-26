//
//  AppleStoreLocationCache
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/4/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppleStoreLocationCache.h"

static NSString *kAppleStoreLocationCacheKey = @"kAppleStoreLocationCacheKey";

@interface AppleStoreLocationCache ()

@property NSMutableDictionary *appleStoreLocationCache;

@end

@implementation AppleStoreLocationCache {

}

+ (id)cacheInstance {
    static AppleStoreLocationCache *cacheInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[self alloc] init];
        cacheInstance.appleStoreLocationCache = [NSMutableDictionary dictionary];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [cacheInstance.appleStoreLocationCache addEntriesFromDictionary:(NSDictionary *) [defaults objectForKey:kAppleStoreLocationCacheKey]];
    });
    return cacheInstance;
}

- (void)setLocation:(CLLocationCoordinate2D)coordinate forAppleStore:(NSString *)storeId {
    NSDictionary *coord = @{@"latitude" : @(coordinate.latitude), @"longitude" : @(coordinate.longitude)};
    (self.appleStoreLocationCache)[storeId] = coord;

    [[NSUserDefaults standardUserDefaults] setObject:self.appleStoreLocationCache forKey:kAppleStoreLocationCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationCoordinate2D)getLocationForAppleStore:(NSString *)storeId {
    NSDictionary *coord = self.appleStoreLocationCache[storeId];

    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [coord[@"latitude"] doubleValue];
    coordinate.longitude = [coord[@"longitude"] doubleValue];

    return coordinate;
}

@end