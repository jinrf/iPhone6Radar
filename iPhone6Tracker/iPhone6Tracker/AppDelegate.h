//
//  AppDelegate.h
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 9/25/14.
//  Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class iPhoneListViewController;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

static NSString *kLocalNotificationPermissionChanged = @"kLocalNotificationPermissionChanged";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) CLLocation *location;
@property (readonly, nonatomic) NSDictionary *reporters;
@property (weak, nonatomic) iPhoneListViewController *listViewController;

+ (AppDelegate *) sharedDelegate;

+ (NSArray *)readTrackedPhones;
+ (void)saveTrackedPhones:(NSDictionary *)iphones;
+ (NSDictionary *)readStoreInventory;
+ (BOOL)saveStoreInventory:(NSArray *)stores forModelNumber:(NSString *)modelNumber;

- (void) startTrackingLocation;

- (NSArray *) getRunStatus;

@end

