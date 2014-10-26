//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "AppleStore.h"


@implementation AppleStore {

}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.storeId) {
        dict[@"storeId"] = self.storeId;
    }
    if (self.name) {
        dict[@"name"] = self.name;
    }
    if (self.address) {
        dict[@"address"] = self.address;
    }
    if (self.city) {
        dict[@"city"] = self.city;
    }
    if (self.state) {
        dict[@"state"] = self.state;
    }
    if (self.zipcode) {
        dict[@"zipcode"] = self.zipcode;
    }
    if (self.email) {
        dict[@"email"] = self.email;
    }
    if (self.phoneNumber) {
        dict[@"phoneNumber"] = self.phoneNumber;
    }
    if (self.storeUrl) {
        dict[@"storeUrl"] = self.storeUrl;
    }
    if (self.hours) {
        dict[@"hours"] = [self.hours componentsJoinedByString:@"|"];
    }

    return dict;
}

+ (AppleStore *)fromDictionary:(NSDictionary *)dict {
    AppleStore *store = [[AppleStore alloc] init];

    store.storeId = dict[@"storeId"];
    store.name = dict[@"name"];
    store.address = dict[@"address"];
    store.city = dict[@"city"];
    store.state = dict[@"state"];
    store.zipcode = dict[@"zipcode"];
    store.email = dict[@"email"];
    store.phoneNumber = dict[@"phoneNumber"];
    store.storeUrl = dict[@"storeUrl"];
    if (dict[@"hours"]) {
        store.hours = [((NSString *) dict[@"hours"]) componentsSeparatedByString:@"|"];
    }

    return store;
}

@end