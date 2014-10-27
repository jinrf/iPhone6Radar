//
//  AppDelegate.m
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 9/25/14.
//  Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "AppDelegate.h"
#import "InventoryCheckManager.h"
#import "iPhone6.h"
#import "AppleStore.h"
#import "SettingsViewController.h"
#import "EmailSender.h"
#import "iPhoneListViewController.h"
#import "BackgroundTaskManager.h"

// tod-o: update permission languages
// to-do: make sure background works
// to-do: send notification email
// to-do: save newly available iphones to local disk, and show them when the app is open
// tod-o: settings view -- radius, set email, receive notification, run frequency

static NSString *iPhoneListKey = @"track_list";
static NSString *inventoryListKey = @"inventory_list";

static const CLLocationDistance kRefetchDistanceThreashroldMeters = 5000;

@interface AppDelegate () <CLLocationManagerDelegate> {
    CLLocation *_lastFetchLocation;
    NSDate *_lastRefreshTime;
}

@property NSTimer *relaunchLocationUpdateTimer;
@property NSTimer *stopLocationUpdateTimer;
@property CLLocationManager *locationManager;

+ (void)saveStoreInventory:(NSDictionary *)storeInventory;

- (void)fetchStockInfo;

@end

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[EmailSender sharedSender] sendEmailTo:@"cosm2000@gmail.com"
//                                       from:@"cosm2000@gmail.com"
//                                   password:@"abCD!@34"
//                                    subject:@"iPhone 6/+ In Stock Alert"
//                                    content:@"<html><body><h2>Test Email</h2><p></p>Looks good!</body></html>"
//    ];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"entering background");

    _lastRefreshTime = [NSDate date];
    _lastFetchLocation = _location;

    [AppDelegate saveStoreInventory:self.listViewController.storeInventoryInfo];

//    UIApplication *app = [UIApplication sharedApplication];
//    _timerBgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:_timerBgTask];
//        _timerBgTask = UIBackgroundTaskInvalid;
//    }];

    // Start the long-running task and return immediately.
//    if (self.relaunchLocationUpdateTimer) {
//        [self.relaunchLocationUpdateTimer invalidate];
//    }
//    self.relaunchLocationUpdateTimer = nil;
//    NSLog(@"remaining time: %.0f", application.backgroundTimeRemaining);
//    self.relaunchLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(backgroundLocationUpdate) userInfo:nil repeats:YES];
//    [self.locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;

    if (self.relaunchLocationUpdateTimer) {
        [self.relaunchLocationUpdateTimer invalidate];
    }
    if ([self.stopLocationUpdateTimer isValid]) {
        [self.stopLocationUpdateTimer invalidate];
    }
    self.relaunchLocationUpdateTimer = nil;
    self.stopLocationUpdateTimer = nil;

    [[BackgroundTaskManager sharedBackgroundTaskManager] drainBGTaskList:YES];

    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"registered notification settings");
    if (notificationSettings.types == UIUserNotificationTypeNone) {
        // denied
        [SettingsViewController setReceiveNotification:NO];
    } else {
        [SettingsViewController setReceiveNotification:YES];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNotificationPermissionChanged object:nil userInfo:@{@"accepted" : @(notificationSettings.types != UIUserNotificationTypeNone)}];
}

- (void)startTrackingLocation {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [_locationManager requestAlwaysAuthorization];
        }

        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
}

- (void)setupNotificationWithUpdatedPhones:(NSArray *)phones {
    if (phones.count > 0) {
        if ([SettingsViewController receivePushNotification]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];

            NSString *text = nil;
            if (phones.count == 1) {
                text = [NSString stringWithFormat:@"\U0001F4F1 %@ is available near you.", [iPhone6 descriptionFromModelNumber:phones[0]]];
            } else {
                text = [NSString stringWithFormat:@"\U0001F4F1 %@ and %d other models are available near you.", [iPhone6 descriptionFromModelNumber:phones[0]], (int) phones.count - 1];
            }
            [notification setAlertBody:text];
            [notification setAlertAction:@"Open"];
            notification.applicationIconBadgeNumber = phones.count;
            notification.soundName = UILocalNotificationDefaultSoundName;
            [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [notification setTimeZone:[NSTimeZone defaultTimeZone]];
            [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
        }

        if ([SettingsViewController emailAddress]) {
            [[EmailSender sharedSender] sendEmailTo:[SettingsViewController emailAddress]
                                               from:[SettingsViewController emailAddress]
                                           password:[SettingsViewController emailPassword]
                                            subject:@"iPhone 6/+ In Stock Alert"
                                            content:[[EmailSender sharedSender] htmlContentForModelNumbers:phones]
            ];
        }
    }
}

- (void)restartLocationUpdate {
    if (self.relaunchLocationUpdateTimer) {
        [self.relaunchLocationUpdateTimer invalidate];
        self.relaunchLocationUpdateTimer = nil;
    }

    [_locationManager startUpdatingLocation];
}

- (void)stopLocationUpdate {
    if (self.stopLocationUpdateTimer) {
        [self.stopLocationUpdateTimer invalidate];
        self.stopLocationUpdateTimer = nil;
    }
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _location = [locations lastObject];
    NSLog(@"got new location: %@", _location);

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        if ([SettingsViewController receivePushNotification] || [SettingsViewController emailAddress]) {
            // only do it in background
            // moved more than 5KM
            CLLocationDistance dist = _lastFetchLocation == nil ? 0.0 : [_location distanceFromLocation:_lastFetchLocation];
            NSTimeInterval sinceLastRefresh = _lastRefreshTime == nil ? 0.0 : [[NSDate date] timeIntervalSinceDate:_lastRefreshTime];

            NSLog(@"current location: %@, last location: %@", _location, _lastFetchLocation);
            NSLog(@"since last refresh: %.0f, run interval: %.0f, distance: %.0f, distance threashrold: %.0f", sinceLastRefresh, [SettingsViewController runInterval], dist, kRefetchDistanceThreashroldMeters);
            if (dist >= kRefetchDistanceThreashroldMeters || sinceLastRefresh > ([SettingsViewController runInterval] * 60.0)) {
                NSLog(@"fetching stock info");
                [self fetchStockInfo];

//                [[EmailSender sharedSender] sendEmailTo:[SettingsViewController emailAddress]
//                                                   from:[SettingsViewController emailAddress]
//                                               password:[SettingsViewController emailPassword]
//                                                subject:@"Test Email Alert"
//                                                content:[NSString stringWithFormat:@"<html><body><h2>This Works!</h2>fetching stock info: distance from prev location: %.0f meters, %.0f seconds</body></html>", dist, sinceLastRefresh]];
            } else {
                NSLog(@"skip fetching stock info: distance from prev location: %.0f meters, %.0f seconds", dist, sinceLastRefresh);
            }

            if (_lastFetchLocation == nil) {
                _lastFetchLocation = _location;
            }
            if (_lastRefreshTime == nil) {
                _lastRefreshTime = [NSDate date];
            }
        }

        if (self.relaunchLocationUpdateTimer) {
            NSLog(@"background timer still live ...");
            return;
        }

        NSLog(@"remaining background time: %.0f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        [[BackgroundTaskManager sharedBackgroundTaskManager] beginNewBackgroundTask];

        NSLog(@"remaining background time: %.0f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        self.relaunchLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                                            target:self
                                                                          selector:@selector(restartLocationUpdate)
                                                                          userInfo:nil
                                                                           repeats:NO];

        //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        //The location manager will only operate for 10 seconds to save battery
        self.stopLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                        target:self
                                                                      selector:@selector(stopLocationUpdate)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.domain == kCLErrorDomain && error.code == kCLErrorDenied) {
        NSLog(@"access to location denied");
    }
}

- (void)fetchStockInfo {
    _lastRefreshTime = [NSDate date];
    _lastFetchLocation = _location;

    NSLog(@"find zipcode for current location ...");

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSArray *iPhone6Array = [AppDelegate readTrackedPhones];
    NSMutableArray *modelNumbers = [@[] mutableCopy];
    for (iPhone6 *iphone6 in iPhone6Array) {
        [modelNumbers addObject:iphone6.modelNumber];
    }

    NSMutableDictionary *runStatus = [NSMutableDictionary dictionary];
    runStatus[@"run_time"] = [NSDate date];
    if (modelNumbers.count == 0) {
        runStatus[@"result"] = @"Skipped: no phone was tracked.";
        [self logRunStatus:runStatus];
    } else {
        NSMutableDictionary *stockInfo = [[AppDelegate readStoreInventory] mutableCopy];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (NSString *modelNumber in stockInfo.allKeys) {
            if (![modelNumbers containsObject:modelNumber]) {
                [defaults setObject:nil forKey:modelNumber];
                [stockInfo removeObjectForKey:modelNumber];
            }
        }
        [defaults synchronize];

        __weak AppDelegate *weakDelegate = self;
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks lastObject];

                NSLog(@"refresh local inventroy for zipcode %@", placemark.postalCode);

                NSMutableArray *updatedPhones = [NSMutableArray array];
                [[InventoryCheckManager sharedManager]
                        addTaskWithModelNumbers:modelNumbers
                                        zipcode:placemark.postalCode
                                   searchRadius:[SettingsViewController searchRadius]
                                        success:^(NSDictionary *modelNumberToInStockStores) {
                                            for (NSString *modelNumber in modelNumberToInStockStores.allKeys) {
                                                BOOL updated = [AppDelegate saveStoreInventory:modelNumberToInStockStores[modelNumber] forModelNumber:modelNumber];
                                                if (updated) {
                                                    [updatedPhones addObject:modelNumber];
                                                }
                                            }

                                            if (updatedPhones.count > 0) {
                                                [[AppDelegate sharedDelegate] setupNotificationWithUpdatedPhones:updatedPhones];
                                            }

                                            NSLog(@"%lu phones were updated", (unsigned long)updatedPhones.count);

                                            runStatus[@"result"] = [NSString stringWithFormat:@"Success: %d phones were updated.", (int) updatedPhones.count];
                                            [weakDelegate logRunStatus:runStatus];
                                        }
                                         failed:^(NSError *err) {
                                             NSLog(@"failed to update inventory: %@", err.localizedDescription);
                                             runStatus[@"result"] = [NSString stringWithFormat:@"Error: failed to check inventory due to error -- %@", err.localizedDescription];
                                             [weakDelegate logRunStatus:runStatus];

                                             for (NSString *modelNumber in modelNumbers) {
                                                 [AppDelegate saveStoreInventory:@[] forModelNumber:modelNumber];
                                             }
                                         }
                ];
            } else {
                runStatus[@"result"] = @"Error: failed reverse geocoding.";
                [weakDelegate logRunStatus:runStatus];
            }
        }];
    }
}

- (void)logRunStatus:(NSDictionary *)status {
    NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundRunStatus"] mutableCopy];
    if (array == nil) {
        array = [NSMutableArray array];
    }
    [array addObject:status];

    if (array.count > 720) {
        for (int i = 0; i < array.count - 720; i++) {
            [array removeObjectAtIndex:0];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"backgroundRunStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundRunStatus"]);
}

- (NSArray *)getRunStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundRunStatus"];
}

+ (NSArray *)readTrackedPhones {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSArray *iphonesTracked = [defaults objectForKey:iPhoneListKey];
    NSMutableArray *iphones = [NSMutableArray array];
    for (NSDictionary *dict in iphonesTracked) {
        iPhone6 *phone = [[iPhone6 alloc] init];
        [phone fromDictionary:dict];

        [iphones addObject:phone];
    }

    return [NSArray arrayWithArray:iphones];
}

+ (void)saveTrackedPhones:(NSDictionary *)iphones {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *objects = [NSMutableArray array];
    for (NSMutableArray *models in iphones.allValues) {
        [objects addObjectsFromArray:models];
    }

    NSMutableArray *array = [NSMutableArray array];
    for (iPhone6 *iphone in objects) {
        [array addObject:[iphone toDictionary]];
    }

    [defaults setObject:[NSArray arrayWithArray:array] forKey:iPhoneListKey];
    [defaults synchronize];
}

+ (NSDictionary *)readStoreInventory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults objectForKey:inventoryListKey];

    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    for (NSString *modelNumber in dict.allKeys) {
        NSArray *stores = dict[modelNumber];

        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in stores) {
            [array addObject:[AppleStore fromDictionary:d]];
        }

        retDict[modelNumber] = [NSArray arrayWithArray:array];
    }

    return [NSDictionary dictionaryWithDictionary:retDict];
}

+ (BOOL)saveStoreInventory:(NSArray *)stores forModelNumber:(NSString *)modelNumber {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary *inventory = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:inventoryListKey]];
    NSArray *existingStores = inventory[modelNumber];

    BOOL updated = ((existingStores == nil || existingStores.count == 0) && stores.count > 0);

    if (stores == nil) {
        [inventory removeObjectForKey:modelNumber];
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (AppleStore *store in stores) {
            [array addObject:[store toDictionary]];
        }
        inventory[modelNumber] = array;
        [defaults setObject:[NSDictionary dictionaryWithDictionary:inventory] forKey:inventoryListKey];
    }

    [defaults synchronize];

    return updated;
}

+ (void)saveStoreInventory:(NSDictionary *)storeInventory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:nil forKey:inventoryListKey];

    NSMutableDictionary *inventory = [NSMutableDictionary dictionary];
    for (NSString *modelNumber in storeInventory.allKeys) {
        NSArray *stores = storeInventory[modelNumber];
        NSMutableArray *array = [NSMutableArray array];
        for (AppleStore *store in stores) {
            [array addObject:[store toDictionary]];
        }

        inventory[modelNumber] = array;
    }

    [defaults setObject:inventory forKey:inventoryListKey];
    [defaults synchronize];
}

@end
