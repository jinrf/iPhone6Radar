//
//  iPhoneListViewController.m
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 9/25/14.
//  Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "iPhoneListViewController.h"
#import "AppleStoreListViewController.h"
#import "iPhone6.h"
#import "iPhoneTableViewCell.h"
#import "AppDelegate.h"
#import "InventoryCheckManager.h"
#import "UIColor+HexString.h"
#import "SettingsViewController.h"
#import "UIColor+iOS7Colors.h"
#import "CSNotificationView.h"

static const NSTimeInterval kManualRefetchThreshold = 300.0;

@interface iPhoneListViewController ()<SettingsViewControllerDelegate>

@property NSMutableDictionary *iPhoneDict;
@property NSMutableDictionary *statusDict;
@property NSDateFormatter *dateFormatter;
@property NSDate *lastManualRefreshDate;

@end

@implementation iPhoneListViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [AppDelegate sharedDelegate].listViewController = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    self.lastManualRefreshDate = [NSDate dateWithTimeIntervalSince1970:0];

    NSArray *array = [AppDelegate readTrackedPhones];
    self.iPhoneDict = [NSMutableDictionary dictionary];
    if (array != nil && array.count > 0) {
        for (iPhone6 *iphone in array) {
            NSMutableArray *phones = self.iPhoneDict[iphone.model];
            if (!phones) {
                phones = [NSMutableArray array];
                self.iPhoneDict[iphone.model] = phones;
            }

            [phones addObject:iphone];
        }

        for (NSString *model in self.iPhoneDict.allKeys) {
            NSMutableArray *phones = self.iPhoneDict[model];
            self.iPhoneDict[model] =  [[phones sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        }
    }

    self.statusDict = [NSMutableDictionary dictionary];

    if ([CLLocationManager locationServicesEnabled]) {
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
                ) {
            [[AppDelegate sharedDelegate] startTrackingLocation];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                                message:@"This app cannot check iPhone 6 inventory without knowing your location.\n\nPlease got to \"Settings/Privacy/Location Services\" to enable location access for iPhone 6 Radar."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];

            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                            message:@"This app cannot check iPhone 6 inventory without knowing your location.\n\nPlease turn on your Location Services at \"Settings/Privacy/Location Services\"."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];

        [alertView show];
    }

    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd hh:mm a"];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    [self printBackgroundRunStatus];

    if (![SettingsViewController settingsAvailable] || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
        [self performSegueWithIdentifier:@"showSettingsSegueId" sender:self];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil
    ];
}

- (void)receivedNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        if (self.iPhoneDict.count > 0 && [[NSDate date] timeIntervalSinceDate:self.lastManualRefreshDate] > kManualRefetchThreshold) {
            if ([AppDelegate sharedDelegate].location) {
                [self refreshTable];
            } else {
                [self.statusDict removeAllObjects];
                [self.tableView reloadData];

                __weak iPhoneListViewController *controller = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    //Background Thread
                    [NSThread sleepForTimeInterval:5.0f];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [controller refreshTable];
                    });
                });
            }
        }
    }
}

- (IBAction)printBackgroundRunStatus {
    NSArray *array = [[AppDelegate sharedDelegate] getRunStatus];
    for (NSDictionary *dict in array) {
        NSLog(@"%@", dict);
    }
}

- (NSDictionary *)storeInventoryInfo {
    return [NSDictionary dictionaryWithDictionary:self.statusDict];
}

- (void)refreshTable {
//    __weak iPhoneListViewController *controller = self;
    self.lastManualRefreshDate = [NSDate date];
    [self.refreshControl endRefreshing];

    [self.statusDict removeAllObjects];
    if ([AppDelegate sharedDelegate].location) {
        [self.tableView reloadData];

        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        __weak iPhoneListViewController *controller = self;
        [geocoder reverseGeocodeLocation:[AppDelegate sharedDelegate].location completionHandler:^(NSArray *placemarks, NSError *error) {
            NSMutableArray *modelNumbers = [@[] mutableCopy];
            for (NSArray *phones in controller.iPhoneDict.allValues) {
                for (iPhone6 *iphone6 in phones) {
                    [modelNumbers addObject:iphone6.modelNumber];
                }
            }

            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks lastObject];

                [[InventoryCheckManager sharedManager]
                        addTaskWithModelNumbers:modelNumbers
                                        zipcode:placemark.postalCode
                                   searchRadius:[SettingsViewController searchRadius]
                                        success:^(NSDictionary *modelNumberToInStockStores) {
                                            controller.statusDict = [modelNumberToInStockStores mutableCopy];
                                            for (NSArray *phones in controller.iPhoneDict.allValues) {
                                                for (iPhone6 *iphone6 in phones) {
                                                    iphone6.lastCheckTime = [NSDate date];
                                                    [modelNumbers addObject:iphone6.modelNumber];
                                                }
                                            }

                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [controller.tableView reloadData];
                                            });
                                        }
                                         failed:^(NSError *err) {
                                             for (NSString *mn in modelNumbers) {
                                                 controller.statusDict[mn] = @[];
                                             }

                                             for (NSArray *phones in controller.iPhoneDict.allValues) {
                                                 for (iPhone6 *iphone6 in phones) {
                                                     iphone6.lastCheckTime = [NSDate date];
                                                     [modelNumbers addObject:iphone6.modelNumber];
                                                 }
                                             }

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [controller.tableView reloadData];
                                             });
                                         }
                ];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                                    message:@"Couldn't identify your location. Please try again later."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];

                [alertView show];

                for (NSString *mn in modelNumbers) {
                    controller.statusDict[mn] = @[];
                }

                for (NSArray *phones in controller.iPhoneDict.allValues) {
                    for (iPhone6 *iphone6 in phones) {
                        iphone6.lastCheckTime = [NSDate date];
                        [modelNumbers addObject:iphone6.modelNumber];
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller.tableView reloadData];
                });
            }
        }];
    }
}

- (void)trackPhone:(iPhone6 *)newPhone {
    NSString *modelNumber = [newPhone modelNumber];

    NSArray *sameModels = self.iPhoneDict[newPhone.model];
    for (iPhone6 *phone in sameModels) {
        if ([[phone modelNumber] isEqualToString:modelNumber]) {
            [CSNotificationView showInViewController:self
                                           tintColor:[UIColor iOS7orangeColor]
                                               image:[UIImage imageNamed:@"exclamationMark.png"]
                                             message:@"Device is already tracked."
                                            duration:2.0f
            ];

            return;
        }
    }

    NSMutableArray *phones = self.iPhoneDict[newPhone.model];
    if (!phones) {
        phones = [NSMutableArray array];
        self.iPhoneDict[newPhone.model] = phones;
    }

    [phones addObject:newPhone];
    self.iPhoneDict[newPhone.model] = [[phones sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

    [AppDelegate saveTrackedPhones:self.iPhoneDict];

    if ([AppDelegate sharedDelegate].location) {
        [self.tableView reloadData];

        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        __weak iPhoneListViewController *controller = self;
        [geocoder reverseGeocodeLocation:[AppDelegate sharedDelegate].location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks lastObject];

                NSMutableArray *modelNumbers = [@[newPhone.modelNumber] mutableCopy];
                [[InventoryCheckManager sharedManager]
                        addTaskWithModelNumbers:modelNumbers
                                        zipcode:placemark.postalCode
                                   searchRadius:[SettingsViewController searchRadius]
                                        success:^(NSDictionary *modelNumberToInStockStores) {
                                            [controller.statusDict addEntriesFromDictionary:modelNumberToInStockStores];
                                            newPhone.lastCheckTime = [NSDate date];

                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [controller.tableView reloadData];
                                            });
                                        }
                                         failed:^(NSError *err) {
                                             (controller.statusDict)[newPhone.modelNumber] = @[];
                                             newPhone.lastCheckTime = [NSDate date];

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [controller.tableView reloadData];
                                             });
                                         }
                ];
            }
        }];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addNewPhone"]) {
        AddiPhoneViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"showAppleStoreList"]) {
        AppleStoreListViewController *vc = (AppleStoreListViewController *) segue.destinationViewController;

        NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

        iPhone6 *iphone = [self.iPhoneDict[models[(NSUInteger) self.tableView.indexPathForSelectedRow.section]] objectAtIndex:(NSUInteger) self.tableView.indexPathForSelectedRow.row];
        vc.appleStores = self.statusDict[iphone.modelNumber];
        vc.modelDetails = iphone.detailString;
    } else if ([[segue identifier] isEqualToString:@"showSettingsSegueId"]) {
        SettingsViewController *svc = segue.destinationViewController;
        svc.delegate = self;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showAppleStoreList"]) {
        NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        iPhone6 *iphone = [self.iPhoneDict[models[(NSUInteger) self.tableView.indexPathForSelectedRow.section]] objectAtIndex:(NSUInteger) self.tableView.indexPathForSelectedRow.row];
        NSArray *stores = self.statusDict[iphone.modelNumber];
        return (stores != nil && stores.count > 0);
    } else if ([identifier isEqualToString:@"addNewPhone"]) {
        if ([AppDelegate sharedDelegate].location) {
            return YES;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                                message:@"This app cannot check iPhone 6 inventory without knowing your location.\n\nPlease got to \"Settings/Privacy/Location Services\" to enable location access for iPhone 6 Radar."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];

            [alertView show];

            return NO;
        }

        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.iPhoneDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return ((NSArray *) self.iPhoneDict[models[(NSUInteger) section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    iPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iPhoneTableViewCellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    iPhone6 *iphone = [self.iPhoneDict[models[(NSUInteger) indexPath.section]] objectAtIndex:(NSUInteger) indexPath.row];
    cell.iPhoneLabel.text = iphone.model;
    cell.detailLabel.text = [iphone detailString];

    NSArray *stores = self.statusDict[iphone.modelNumber];
    if (stores == nil) {
        UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = v;
        [v startAnimating];
    } else if (stores.count > 0) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"available.png"]];
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"not_available.png"]];
    }

    if ([iphone.finish isEqualToString:@"Gold"]) {
        cell.finishView.backgroundColor = [UIColor colorWithHexString:@"#e9d2c0"];
    } else if ([iphone.finish isEqualToString:@"Space Gray"]) {
        cell.finishView.backgroundColor = [UIColor colorWithHexString:@"#85858d"];
    } else if ([iphone.finish isEqualToString:@"Silver"]) {
        cell.finishView.backgroundColor = [UIColor colorWithHexString:@"#f0f2f1"];
    } else {
        cell.finishView.backgroundColor = [UIColor clearColor];
    }

    if ([iphone.carrier isEqualToString:@"AT&T"]) {
        cell.carrierLogoImageView.image = [UIImage imageNamed:@"att.png"];
    } else if ([iphone.carrier isEqualToString:@"Verizon"]) {
        cell.carrierLogoImageView.image = [UIImage imageNamed:@"verizon.png"];
    } else if ([iphone.carrier isEqualToString:@"T-Mobile"]) {
        cell.carrierLogoImageView.image = [UIImage imageNamed:@"tmobile.png"];
    } else if ([iphone.carrier isEqualToString:@"Sprint"]) {
        cell.carrierLogoImageView.image = [UIImage imageNamed:@"sprint.png"];
    } else {
        cell.carrierLogoImageView.image = nil;
    }

    cell.finishView.layer.cornerRadius = (CGFloat) (cell.finishView.bounds.size.width / 2.0);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return models[(NSUInteger) section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 32)];
    label.backgroundColor = [UIColor colorWithWhite:0.35 alpha:0.85];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];

    NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    label.text = [NSString stringWithFormat:@"    %@", models[(NSUInteger) section]];

    return label;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *models = [[[self.iPhoneDict allKeys] mutableCopy] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        iPhone6 *phone = [self.iPhoneDict[models[(NSUInteger) indexPath.section]] objectAtIndex:(NSUInteger) indexPath.row];

        [self.statusDict removeObjectForKey:phone.modelNumber];

        NSMutableArray *array = self.iPhoneDict[phone.model];
        [array removeObject:phone];
        if (array.count == 0) {
            [self.iPhoneDict removeObjectForKey:phone.model];
        }

        [AppDelegate saveStoreInventory:nil forModelNumber:phone.modelNumber];
        [AppDelegate saveTrackedPhones:self.iPhoneDict];

        __weak iPhoneListViewController *controller = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (array.count == 0) {
                [controller.tableView reloadData];
            } else {
                [controller.tableView beginUpdates];
                [controller.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [controller.tableView endUpdates];
            }
        });
    }
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidDismissed {
}

@end
