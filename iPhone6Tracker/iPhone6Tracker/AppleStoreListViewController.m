//
//  AppleStoreListViewController.m
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 9/25/14.
//  Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/ABPerson.h>
#import "AppleStoreListViewController.h"
#import "AppleStoreTableViewCell.h"
#import "AppleStore.h"
#import "AppDelegate.h"
#import "AppleStoreMapViewController.h"

@interface AppleStoreListViewController ()

@end

@implementation AppleStoreListViewController


#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *label = (UILabel *) self.navigationItem.titleView;
    [label setMinimumScaleFactor:0.6];
    label.adjustsFontSizeToFitWidth = YES;

    [self setTitle:self.modelDetails];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMapViewId"]) {
        AppleStoreMapViewController *mapViewController = (AppleStoreMapViewController *)segue.destinationViewController;

        AppleStore *store = [self.appleStores objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        mapViewController.store = store;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appleStores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppleStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appleStoreTableViewCellId" forIndexPath:indexPath];

    AppleStore *store = [self.appleStores objectAtIndex:indexPath.row];

    [cell.storeNameButton setTitle:store.name forState:UIControlStateNormal];
    [cell.storeNameButton setTitle:store.name forState:UIControlStateSelected];
    [cell.storeNameButton setTitle:store.name forState:UIControlStateHighlighted];
    cell.storeNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    cell.addressLabel.text = store.address;
    cell.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@ %@", store.city, store.state, store.zipcode];

    cell.hour1Label.text = store.hours.count > 0 ? store.hours[0] : @"";
    cell.hour2Label.text = store.hours.count > 1 ? store.hours[1] : @"";
    cell.hour3Label.text = store.hours.count > 2 ? store.hours[2] : @"";

    cell.phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cell.phoneButton setTitle:store.phoneNumber forState:UIControlStateHighlighted];
    [cell.phoneButton setTitle:store.phoneNumber forState:UIControlStateSelected];
    [cell.phoneButton setTitle:store.phoneNumber forState:UIControlStateNormal];
    cell.phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    cell.storeUrl = store.storeUrl;
//
//    cell.storeNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [cell.storeNameButton setTitle:store.storeUrl forState:UIControlStateHighlighted];
//    [cell.storeNameButton setTitle:store.storeUrl forState:UIControlStateSelected];
//    [cell.storeNameButton setTitle:store.storeUrl forState:UIControlStateNormal];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 32)];
    label.backgroundColor = [UIColor colorWithWhite:0.35 alpha:0.85];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:17.0];
    label.textColor = [UIColor whiteColor];

    label.text = @"    Available In Following Apple Stores:";

    return label;
}

@end
