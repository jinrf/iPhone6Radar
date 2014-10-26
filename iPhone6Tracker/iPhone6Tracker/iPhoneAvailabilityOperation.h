//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"


@interface iPhoneAvailabilityOperation : AFHTTPRequestOperation

//- (instancetype) initWithModelNumber:(NSString *)iPhone6ModelNumber andZipCode:(NSString *)zipcode;
- (instancetype) initWithModelNumbers:(NSArray *)iPhone6ModelNumbers andZipCode:(NSString *)zipcode;

@property (nonatomic, readonly) NSArray *modelNumbers;
@end