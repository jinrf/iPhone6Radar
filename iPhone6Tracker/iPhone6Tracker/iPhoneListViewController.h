//
//  iPhoneListViewController.h
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 9/25/14.
//  Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddiPhoneViewController.h"

@interface iPhoneListViewController : UITableViewController<AddiPhoneViewControllerDelegate>

- (IBAction)printBackgroundRunStatus;
- (NSDictionary *)storeInventoryInfo;

@end

