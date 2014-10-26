//
//  AppleStoreLocationCache
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/4/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface AppleStoreLocationCache : NSObject

+ (id)cacheInstance;

- (void)setLocation:(CLLocationCoordinate2D)coordinate forAppleStore:(NSString *)storeId;
- (CLLocationCoordinate2D) getLocationForAppleStore:(NSString *)storeId;

@end