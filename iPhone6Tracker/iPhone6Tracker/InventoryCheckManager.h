//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/26/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InventoryCheckManager : NSObject

+ (id)sharedManager;
//- (void) addTaskWithModelNumber:(NSString *)modelNumber
//                        zipcode:(NSString *)zipcode
//                        success:(void (^)(NSArray *inStockStores))success
//                         failed:(void (^)(NSError *))failure;
- (void)addTaskWithModelNumbers:(NSArray *)modelNumbers
                        zipcode:(NSString *)zipcode
                   searchRadius:(double)miles
                        success:(void (^)(NSDictionary *modelNumberToInStockStores))success
                         failed:(void (^)(NSError *))failure;

@end