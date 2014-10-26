//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iPhone6 : NSObject

@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *finish;
@property (nonatomic, copy) NSString *carrier;
@property (nonatomic, assign) int storage;
@property (nonatomic, strong) NSDate *lastCheckTime;

- (NSDictionary *) toDictionary;
- (void) fromDictionary:(NSDictionary *)dictionary;
- (NSString *)modelNumber;
- (NSString *)detailString;

- (NSString *) signature;
- (NSComparisonResult)compare:(iPhone6 *)otherObject;

+ (NSString *) descriptionFromModelNumber:(NSString *)modelNumber;

@end