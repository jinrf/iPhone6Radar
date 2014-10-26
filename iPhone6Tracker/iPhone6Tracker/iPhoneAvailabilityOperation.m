//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "iPhoneAvailabilityOperation.h"


//static const NSString *kAvailabilityCheckURL = @"http://store.apple.com/us/retailStore/availabilitySearch?parts.0=%@&zip=%@";
static const NSString *kAvailabilityCheckURL = @"http://store.apple.com/us/retailStore/availabilitySearch?zip=%@";

@implementation iPhoneAvailabilityOperation {
    NSString *_zipcode;
}

//- (instancetype)initWithModelNumber:(NSString *)iPhone6ModelNumber andZipCode:(NSString *)zipcode {
//    NSString *url = [NSString stringWithFormat:kAvailabilityCheckURL, [iPhone6ModelNumber stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"], zipcode];
//    self = [super initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0]];
//    if (self) {
//        _zipcode = zipcode;
//        _modelNumber = iPhone6ModelNumber;
//    }
//
//    return self;
//}
//
- (instancetype)initWithModelNumbers:(NSArray *)iPhone6ModelNumbers andZipCode:(NSString *)zipcode {
    NSString *url = [NSString stringWithFormat:(NSString *) kAvailabilityCheckURL, zipcode];
    NSMutableArray *array = [@[url] mutableCopy];
    for (int i = 0; i < iPhone6ModelNumbers.count; i++) {
        NSString *param = [NSString stringWithFormat:@"parts.%d=%@", i, [iPhone6ModelNumbers[i] stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]];
        [array addObject:param];
    }
    NSString *finalUrl = [array componentsJoinedByString:@"&"];
    self = [super initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0]];
    if (self) {
        _zipcode = zipcode;
        _modelNumbers = iPhone6ModelNumbers;
    }

    return self;
}

@end