//
//  SettingsViewController
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/6/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailPasswordViewController.h"

@protocol SettingsViewControllerDelegate

- (void) settingsViewControllerDidDismissed;

@end;


@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EmailPasswordViewControllerDelegate>

@property IBOutlet UITableView *settingsTableView;
@property IBOutlet UIButton *doneButton;

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

- (IBAction) buttonClicked:(id)sender;

+ (float) searchRadius;
+ (float) runInterval;
+ (BOOL) receivePushNotification;
+ (NSString *) emailAddress;
+ (NSString *)emailPassword;
+ (BOOL) settingsAvailable;
+ (void) setReceiveNotification:(BOOL)notification;

@end