//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "iPhone6.h"


@implementation iPhone6 {

}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.model) {
        dictionary[@"model"] = self.model;
    }
    if (self.finish) {
        dictionary[@"finish"] = self.finish;
    }
    if (self.carrier) {
        dictionary[@"carrier"] = self.carrier;
    }
    if (self.storage > 0) {
        dictionary[@"storage"] = @(self.storage);
    }
    if (self.lastCheckTime) {
        dictionary[@"lastCheckTime"] = self.lastCheckTime;
    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    self.model = dictionary[@"model"];
    self.finish = dictionary[@"finish"];
    self.carrier = dictionary[@"carrier"];
    if (dictionary[@"storage"]) {
        self.storage = [dictionary[@"storage"] intValue];
    }

    self.lastCheckTime = dictionary[@"lastCheckTime"];
}

- (NSString *)detailString {
    return [NSString stringWithFormat:@"%@, %@, %dGB", self.carrier, self.finish, self.storage];
}

- (NSString *)signature {
    return [[NSString stringWithFormat:@"%@_%@_%@_%03d", self.model, self.carrier, self.finish, self.storage] lowercaseString];
}


- (NSComparisonResult)compare:(iPhone6 *)otherObject {
    return [self.signature compare:otherObject.signature];
}

- (NSString *)modelNumber {
    if ([self.model isEqualToString:@"iPhone 6"]) {
        if ([self.finish isEqualToString:@"Silver"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MG4P2LL/A";
                else if (self.storage == 64)
                    return @"MG4X2LL/A";
                else if (self.storage == 128)
                    return @"MG4U2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MG6A2LL/A";
                else if (self.storage == 64)
                    return @"MG6H2LL/A";
                else if (self.storage == 128)
                    return @"MG6E2LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MG5X2LL/A";
                else if (self.storage == 64)
                    return @"MG642LL/A";
                else if (self.storage == 128)
                    return @"MG612LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MG552LL/A";
                else if (self.storage == 64)
                    return @"MG5C2LL/A";
                else if (self.storage == 128)
                    return @"MG582LL/A";
            }
        } else if ([self.finish isEqualToString:@"Gold"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MG4Q2LL/A";
                else if (self.storage == 64)
                    return @"MG502LL/A";
                else if (self.storage == 128)
                    return @"MG4V2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MG6C2LL/A";
                else if (self.storage == 64)
                    return @"MG6J2LL/A";
                else if (self.storage == 128)
                    return @"MG6F2LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MG5Y2LL/A";
                else if (self.storage == 64)
                    return @"MG652LL/A";
                else if (self.storage == 128)
                    return @"MG622LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MG562LL/A";
                else if (self.storage == 64)
                    return @"MG5D2LL/A";
                else if (self.storage == 128)
                    return @"MG592LL/A";
            }
        } else if ([self.finish isEqualToString:@"Space Gray"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MG4N2LL/A";
                else if (self.storage == 64)
                    return @"MG4W2LL/A";
                else if (self.storage == 128)
                    return @"MG4R2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MG692LL/A";
                else if (self.storage == 64)
                    return @"MG6G2LL/A";
                else if (self.storage == 128)
                    return @"MG6D2LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MG5W2LL/A";
                else if (self.storage == 64)
                    return @"MG632LL/A";
                else if (self.storage == 128)
                    return @"MG602LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MG542LL/A";
                else if (self.storage == 64)
                    return @"MG5A2LL/A";
                else if (self.storage == 128)
                    return @"MG572LL/A";
            }
        }
    } else if ([self.model isEqualToString:@"iPhone 6 Plus"]) {
        if ([self.finish isEqualToString:@"Silver"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MGAM2LL/A";
                else if (self.storage == 64)
                    return @"MGAV2LL/A";
                else if (self.storage == 128)
                    return @"MGAQ2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MGCW2LL/A";
                else if (self.storage == 64)
                    return @"MGD32LL/A";
                else if (self.storage == 128)
                    return @"MGD02LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MGCL2LL/A";
                else if (self.storage == 64)
                    return @"MGCT2LL/A";
                else if (self.storage == 128)
                    return @"MGCP2LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MGC02LL/A";
                else if (self.storage == 64)
                    return @"MGC62LL/A";
                else if (self.storage == 128)
                    return @"MGC32LL/A";
            }
        } else if ([self.finish isEqualToString:@"Gold"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MGAN2LL/A";
                else if (self.storage == 64)
                    return @"MGAW2LL/A";
                else if (self.storage == 128)
                    return @"MGAR2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MGCX2LL/A";
                else if (self.storage == 64)
                    return @"MGD42LL/A";
                else if (self.storage == 128)
                    return @"MGD12LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MGCM2LL/A";
                else if (self.storage == 64)
                    return @"MGCU2LL/A";
                else if (self.storage == 128)
                    return @"MGCQ2LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MGC12LL/A";
                else if (self.storage == 64)
                    return @"MGC72LL/A";
                else if (self.storage == 128)
                    return @"MGC42LL/A";
            }
        } else if ([self.finish isEqualToString:@"Space Gray"]) {
            if ([self.carrier isEqualToString:@"AT&T"]) {
                if (self.storage == 16)
                    return @"MGAL2LL/A";
                else if (self.storage == 64)
                    return @"MGAU2LL/A";
                else if (self.storage == 128)
                    return @"MGAP2LL/A";
            } else if ([self.carrier isEqualToString:@"Sprint"]) {
                if (self.storage == 16)
                    return @"MGCV2LL/A";
                else if (self.storage == 64)
                    return @"MGD22LL/A";
                else if (self.storage == 128)
                    return @"MGCY2LL/A";
            } else if ([self.carrier isEqualToString:@"Verizon"]) {
                if (self.storage == 16)
                    return @"MGCK2LL/A";
                else if (self.storage == 64)
                    return @"MGCR2LL/A";
                else if (self.storage == 128)
                    return @"MGCN2LL/A";
            } else if ([self.carrier isEqualToString:@"T-Mobile"]) {
                if (self.storage == 16)
                    return @"MGAX2LL/A";
                else if (self.storage == 64)
                    return @"MGC52LL/A";
                else if (self.storage == 128)
                    return @"MGC22LL/A";
            }
        }
    }

    return nil;
}

+ (NSString *) descriptionFromModelNumber:(NSString *)modelNumber {
    static NSDictionary *modelNumberToDescription = nil;
    if (modelNumberToDescription == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        dict[@"MG4P2LL/A"] = @"iPhone 6 AT&T, Silver, 16GB";
        dict[@"MG4X2LL/A"] = @"iPhone 6 AT&T, Silver, 64GB";
        dict[@"MG4U2LL/A"] = @"iPhone 6 AT&T, Silver, 128GB";
        dict[@"MG6A2LL/A"] = @"iPhone 6 Sprint, Silver, 16GB";
        dict[@"MG6H2LL/A"] = @"iPhone 6 Sprint, Silver, 64GB";
        dict[@"MG6E2LL/A"] = @"iPhone 6 Sprint, Silver, 128GB";
        dict[@"MG5X2LL/A"] = @"iPhone 6 Verizon, Silver, 16GB";
        dict[@"MG642LL/A"] = @"iPhone 6 Verizon, Silver, 64GB";
        dict[@"MG612LL/A"] = @"iPhone 6 Verizon, Silver, 128GB";
        dict[@"MG552LL/A"] = @"iPhone 6 T-Mobile, Silver, 16GB";
        dict[@"MG5C2LL/A"] = @"iPhone 6 T-Mobile, Silver, 64GB";
        dict[@"MG582LL/A"] = @"iPhone 6 T-Mobile, Silver, 128GB";
        dict[@"MG4Q2LL/A"] = @"iPhone 6 AT&T, Gold, 16GB";
        dict[@"MG502LL/A"] = @"iPhone 6 AT&T, Gold, 64GB";
        dict[@"MG4V2LL/A"] = @"iPhone 6 AT&T, Gold, 128GB";
        dict[@"MG6C2LL/A"] = @"iPhone 6 Sprint, Gold, 16GB";
        dict[@"MG6J2LL/A"] = @"iPhone 6 Sprint, Gold, 64GB";
        dict[@"MG6F2LL/A"] = @"iPhone 6 Sprint, Gold, 128GB";
        dict[@"MG5Y2LL/A"] = @"iPhone 6 Verizon, Gold, 16GB";
        dict[@"MG652LL/A"] = @"iPhone 6 Verizon, Gold, 64GB";
        dict[@"MG622LL/A"] = @"iPhone 6 Verizon, Gold, 128GB";
        dict[@"MG562LL/A"] = @"iPhone 6 T-Mobile, Gold, 16GB";
        dict[@"MG5D2LL/A"] = @"iPhone 6 T-Mobile, Gold, 64GB";
        dict[@"MG592LL/A"] = @"iPhone 6 T-Mobile, Gold, 128GB";
        dict[@"MG4N2LL/A"] = @"iPhone 6 AT&T, Space Gray, 16GB";
        dict[@"MG4W2LL/A"] = @"iPhone 6 AT&T, Space Gray, 64GB";
        dict[@"MG4R2LL/A"] = @"iPhone 6 AT&T, Space Gray, 128GB";
        dict[@"MG692LL/A"] = @"iPhone 6 Sprint, Space Gray, 16GB";
        dict[@"MG6G2LL/A"] = @"iPhone 6 Sprint, Space Gray, 64GB";
        dict[@"MG6D2LL/A"] = @"iPhone 6 Sprint, Space Gray, 128GB";
        dict[@"MG5W2LL/A"] = @"iPhone 6 Verizon, Space Gray, 16GB";
        dict[@"MG632LL/A"] = @"iPhone 6 Verizon, Space Gray, 64GB";
        dict[@"MG602LL/A"] = @"iPhone 6 Verizon, Space Gray, 128GB";
        dict[@"MG542LL/A"] = @"iPhone 6 T-Mobile, Space Gray, 16GB";
        dict[@"MG5A2LL/A"] = @"iPhone 6 T-Mobile, Space Gray, 64GB";
        dict[@"MG572LL/A"] = @"iPhone 6 T-Mobile, Space Gray, 128GB";
        dict[@"MGAM2LL/A"] = @"iPhone 6+ AT&T, Silver, 16GB";
        dict[@"MGAV2LL/A"] = @"iPhone 6+ AT&T, Silver, 64GB";
        dict[@"MGAQ2LL/A"] = @"iPhone 6+ AT&T, Silver, 128GB";
        dict[@"MGCW2LL/A"] = @"iPhone 6+ Sprint, Silver, 16GB";
        dict[@"MGD32LL/A"] = @"iPhone 6+ Sprint, Silver, 64GB";
        dict[@"MGD02LL/A"] = @"iPhone 6+ Sprint, Silver, 128GB";
        dict[@"MGCL2LL/A"] = @"iPhone 6+ Verizon, Silver, 16GB";
        dict[@"MGCT2LL/A"] = @"iPhone 6+ Verizon, Silver, 64GB";
        dict[@"MGCP2LL/A"] = @"iPhone 6+ Verizon, Silver, 128GB";
        dict[@"MGC02LL/A"] = @"iPhone 6+ T-Mobile, Silver, 16GB";
        dict[@"MGC62LL/A"] = @"iPhone 6+ T-Mobile, Silver, 64GB";
        dict[@"MGC32LL/A"] = @"iPhone 6+ T-Mobile, Silver, 128GB";
        dict[@"MGAN2LL/A"] = @"iPhone 6+ AT&T, Gold, 16GB";
        dict[@"MGAW2LL/A"] = @"iPhone 6+ AT&T, Gold, 64GB";
        dict[@"MGAR2LL/A"] = @"iPhone 6+ AT&T, Gold, 128GB";
        dict[@"MGCX2LL/A"] = @"iPhone 6+ Sprint, Gold, 16GB";
        dict[@"MGD42LL/A"] = @"iPhone 6+ Sprint, Gold, 64GB";
        dict[@"MGD12LL/A"] = @"iPhone 6+ Sprint, Gold, 128GB";
        dict[@"MGCM2LL/A"] = @"iPhone 6+ Verizon, Gold, 16GB";
        dict[@"MGCU2LL/A"] = @"iPhone 6+ Verizon, Gold, 64GB";
        dict[@"MGCQ2LL/A"] = @"iPhone 6+ Verizon, Gold, 128GB";
        dict[@"MGC12LL/A"] = @"iPhone 6+ T-Mobile, Gold, 16GB";
        dict[@"MGC72LL/A"] = @"iPhone 6+ T-Mobile, Gold, 64GB";
        dict[@"MGC42LL/A"] = @"iPhone 6+ T-Mobile, Gold, 128GB";
        dict[@"MGAL2LL/A"] = @"iPhone 6+ AT&T, Space Gray, 16GB";
        dict[@"MGAU2LL/A"] = @"iPhone 6+ AT&T, Space Gray, 64GB";
        dict[@"MGAP2LL/A"] = @"iPhone 6+ AT&T, Space Gray, 128GB";
        dict[@"MGCV2LL/A"] = @"iPhone 6+ Sprint, Space Gray, 16GB";
        dict[@"MGD22LL/A"] = @"iPhone 6+ Sprint, Space Gray, 64GB";
        dict[@"MGCY2LL/A"] = @"iPhone 6+ Sprint, Space Gray, 128GB";
        dict[@"MGCK2LL/A"] = @"iPhone 6+ Verizon, Space Gray, 16GB";
        dict[@"MGCR2LL/A"] = @"iPhone 6+ Verizon, Space Gray, 64GB";
        dict[@"MGCN2LL/A"] = @"iPhone 6+ Verizon, Space Gray, 128GB";
        dict[@"MGAX2LL/A"] = @"iPhone 6+ T-Mobile, Space Gray, 16GB";
        dict[@"MGC52LL/A"] = @"iPhone 6+ T-Mobile, Space Gray, 64GB";
        dict[@"MGC22LL/A"] = @"iPhone 6+ T-Mobile, Space Gray, 128GB";

        modelNumberToDescription = [NSDictionary dictionaryWithDictionary:dict];
    }

    return modelNumberToDescription[modelNumber];
}

@end