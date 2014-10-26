//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppleStore : NSObject

@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSArray *hours;
@property (nonatomic, copy) NSString *storeUrl;

- (NSDictionary *) toDictionary;
+ (AppleStore *) fromDictionary:(NSDictionary *)dict;

@end