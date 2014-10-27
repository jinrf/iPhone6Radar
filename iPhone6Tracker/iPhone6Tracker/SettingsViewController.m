//
//  SettingsViewController
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/6/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+iOS7Colors.h"
#import "AppDelegate.h"

@interface SettingsViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) UISlider *searchRadiusSlider;
@property (nonatomic, weak) UILabel *searchRadiusLabel;
@property (nonatomic, weak) UILabel *frequencyLabel;
@property (nonatomic, weak) UILabel *frequencyDescLabel;
@property (nonatomic, weak) UISwitch *notificationSwitch;
@property (nonatomic, weak) UITextField *emailField;

@property NSArray *runIntervals;
@property UIView *pickerBackgroundView;
@property UIPickerView *pickerView;
@property int pickerSelectedRow;
@property NSString *emailPassword;
@property NSString *userEnteredEmail;

@end

static inline NSString* userEnteredEmailAddress(NSString *emailFieldText) {
    NSString *email = emailFieldText == nil ? nil : [emailFieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return email == nil || email.length == 0 ? nil : [[NSString stringWithFormat:@"%@@gmail.com", email] lowercaseString];
}

@implementation SettingsViewController {

}

+ (BOOL) settingsAvailable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"settingsSearchRadius"] != nil;
}

+ (float)searchRadius {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [defaults objectForKey:@"settingsSearchRadius"];
    if (number) {
        return [number floatValue];
    } else {
        [defaults setFloat:100.0f forKey:@"settingsSearchRadius"];
        return 100.0f;
    }
}

+ (float)runInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [defaults objectForKey:@"settingsRunInterval"];
    if (number) {
        return [number floatValue];
    } else {
        [defaults setFloat:30.0f forKey:@"settingsRunInterval"];
        return 30.0f;
    }
}

+ (BOOL)receivePushNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [defaults objectForKey:@"settingsReceivePushNotification"];
    if (number) {
        return [number boolValue];
    } else {
        [defaults setBool:NO forKey:@"settingsReceivePushNotification"];
        return NO;
    }
}

+ (NSString *)emailAddress {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"settingsEmailAddress"];
}

+ (NSString *)emailPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"settingsEmailPassword"];
}

+ (void) setReceiveNotification:(BOOL)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:notification forKey:@"settingsReceivePushNotification"];
    [defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.doneButton setBackgroundColor:[UIColor iOS7darkBlueColor]];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    self.doneButton.layer.cornerRadius = 5.0f;

    self.runIntervals = @[@5, @10, @20, @30, @60, @120, @240];

    self.userEnteredEmail = [SettingsViewController emailAddress];
    self.emailPassword = [SettingsViewController emailPassword];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localNotificationPermissionChanged:)
                                                 name:kLocalNotificationPermissionChanged
                                               object:nil
    ];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (void) localNotificationPermissionChanged:(NSNotification *)notification {
    BOOL accepted = [(notification.userInfo)[@"accepted"] boolValue];
    NSLog(@"local notification permission change detected, accept = %d", accepted);

    [SettingsViewController setReceiveNotification:accepted];

    if (self.notificationSwitch.on != accepted) {
        self.notificationSwitch.on = accepted;
    }
}

- (IBAction)buttonClicked:(id)sender {
    if (sender == self.doneButton) {
        [self saveSettings:self.emailField];

        if ([CLLocationManager locationServicesEnabled]) {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                [[AppDelegate sharedDelegate] startTrackingLocation];
            } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                                    message:@"This app cannot check iPhone 6 inventory without knowing your location.\n\nPlease go to \"Settings/Privacy/Location Services\" to enable location access for iPhone 6 Radar."
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
    }

    __weak SettingsViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.delegate) {
            [weakSelf.delegate settingsViewControllerDidDismissed];
        }
    }];
}

- (void) valueChanged:(id)sender {
    if (sender == self.searchRadiusSlider) {
        self.searchRadiusLabel.text = [NSString stringWithFormat:@"%.0f miles", self.searchRadiusSlider.value];
    } else if (sender == self.notificationSwitch) {
        BOOL notificationAsked = ([[NSUserDefaults standardUserDefaults] objectForKey:@"notificationAsked"] != nil);

        if (self.notificationSwitch.on) {
            if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
                if (!notificationAsked) {
                    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notificationAsked"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [self saveSettings:self.notificationSwitch];
                } else if ([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"You have denied notification previously.\n\nTo re-enable it, please go to \"Settings/Notifications/iPhone 6 Radar\"."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];

                    [alertView show];

                    self.notificationSwitch.on = NO;
                }
            } else {
                [self saveSettings:self.notificationSwitch];
            }
        } else {
            [self saveSettings:self.notificationSwitch];
        }
    }
}

- (void) saveSettings:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (sender == self.searchRadiusSlider) {
        [defaults setFloat:self.searchRadiusSlider.value forKey:@"settingsSearchRadius"];
    } else if (sender == self.notificationSwitch) {
        [defaults setBool:self.notificationSwitch.on forKey:@"settingsReceivePushNotification"];
    } else if (sender == self.emailField) {
        NSString *newEmail = self.userEnteredEmail;

        if (newEmail == nil || newEmail.length == 0) {
            [defaults removeObjectForKey:@"settingsEmailAddress"];
            [defaults removeObjectForKey:@"settingsEmailPassword"];
        } else {
            [defaults setObject:newEmail forKey:@"settingsEmailAddress"];
            [defaults setObject:self.emailPassword forKey:@"settingsEmailPassword"];
        }
    }
    [defaults synchronize];
}

- (void) showPickerView {
    float currentInterval = [SettingsViewController runInterval];
    NSUInteger idx = 0;
    for (;idx < self.runIntervals.count; idx++) {
        if (currentInterval == [self.runIntervals[idx] floatValue]) {
            break;
        }
    }
    [self.pickerView selectRow:idx inComponent:0 animated:NO];
    self.pickerSelectedRow = (int) idx;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.pickerBackgroundView.center = CGPointMake(self.pickerBackgroundView.center.x, self.pickerBackgroundView.center.y - self.pickerBackgroundView.bounds.size.height);
                         }
        ];
    });
}

- (void) dismissPickerView:(id) sender {
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;

    if ([barButtonItem.title isEqualToString:@"Done"]) {
        float runInterval = [self.runIntervals[(NSUInteger) self.pickerSelectedRow] floatValue];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:runInterval forKey:@"settingsRunInterval"];

        [defaults synchronize];

        self.frequencyLabel.text = [NSString stringWithFormat:@"%.0f mins", runInterval];
        if (runInterval < 30) {
            self.frequencyDescLabel.textColor = [UIColor redColor];
            self.frequencyDescLabel.text = @"may impact battery life";
        } else {
            self.frequencyDescLabel.textColor = [UIColor blackColor];
            self.frequencyDescLabel.text = @"runs in background once every ...";
        }
    }

    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.pickerBackgroundView.center = CGPointMake(self.pickerBackgroundView.center.x, self.pickerBackgroundView.center.y + self.pickerBackgroundView.bounds.size.height);
                     }
    ];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"idShowEmailPasswordView"]) {
        EmailPasswordViewController *vc = segue.destinationViewController;
        vc.emailAddress = userEnteredEmailAddress(self.emailField.text);
        vc.delegate = self;
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"settingsTableViewCellId-%ld", (long)indexPath.row]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"settingsTableViewCellId"];
    }

    if (indexPath.row == 0 && self.searchRadiusSlider == nil) {
        self.searchRadiusLabel = (UILabel *) [cell.contentView viewWithTag:1001];
        self.searchRadiusSlider = (UISlider *) [cell.contentView viewWithTag:1002];
        [self.searchRadiusSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.searchRadiusSlider addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];

        self.searchRadiusSlider.value = [SettingsViewController searchRadius];
        self.searchRadiusLabel.text = [NSString stringWithFormat:@"%.0f miles", [SettingsViewController searchRadius]];
    } else if (indexPath.row == 1 && self.frequencyLabel == nil) {
        self.frequencyLabel = (UILabel *) [cell.contentView viewWithTag:1003];
        self.frequencyDescLabel = (UILabel *) [cell.contentView viewWithTag:1004];

        float runInterval = [SettingsViewController runInterval];
        self.frequencyLabel.text = [NSString stringWithFormat:@"%.0f mins", runInterval];
        if (runInterval < 30) {
            self.frequencyDescLabel.textColor = [UIColor redColor];
            self.frequencyDescLabel.text = @"may impact battery life";
        } else {
            self.frequencyDescLabel.textColor = [UIColor blackColor];
            self.frequencyDescLabel.text = @"runs in background once every ...";
        }
    } else if (indexPath.row == 2 && self.notificationSwitch == nil) {
        self.notificationSwitch = (UISwitch *) [cell.contentView viewWithTag:1005];
        [self.notificationSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

        self.notificationSwitch.on = [SettingsViewController receivePushNotification];
    } else if (indexPath.row == 3 && self.emailField == nil) {
        self.emailField = (UITextField *) [cell.contentView viewWithTag:1006];
        self.emailField.delegate = self;

        if ([SettingsViewController emailAddress]) {
            self.emailField.text = [[SettingsViewController emailAddress] componentsSeparatedByString:@"@"][0];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.settingsTableView.frame.size.width, 44)];
    label.backgroundColor = [UIColor colorWithWhite:0.35 alpha:0.85];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:22.0];
    label.textColor = [UIColor whiteColor];

    label.text = @"Settings For iPhone 6 Radar";

    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if (self.pickerBackgroundView == nil) {
            self.pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 194.0f)];
            self.pickerBackgroundView.backgroundColor = [UIColor whiteColor];

            UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, self.pickerBackgroundView.bounds.size.height - 150.0f, self.pickerBackgroundView.bounds.size.width, 150.0f)];
            myPickerView.delegate = self;
            myPickerView.dataSource = self;
            myPickerView.showsSelectionIndicator = YES;

            [self.pickerBackgroundView addSubview:myPickerView];
            self.pickerView = myPickerView;

            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPickerView:)];
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPickerView:)];
            UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.pickerBackgroundView.bounds.size.width, 44.0f)];
            [toolBar setBarStyle:UIBarStyleDefault];
            [toolBar setItems:@[cancelButton, flexibleItem, doneButton]];

            [self.pickerBackgroundView addSubview:toolBar];

            [self.view addSubview:self.pickerBackgroundView];
        }

        if (self.pickerBackgroundView.center.y > self.view.bounds.size.height) {
            [self showPickerView];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480 || height == 960) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.settingsTableView.center = CGPointMake(self.settingsTableView.center.x, self.settingsTableView.center.y + 100.0f);
                         }];
    }

    NSString *newEmail = userEnteredEmailAddress(self.emailField.text);

    if (newEmail == nil && newEmail.length == 0) {
        self.userEnteredEmail = nil;
        self.emailPassword = nil;
    } else if (![newEmail isEqualToString:self.userEnteredEmail]) {
        self.userEnteredEmail = newEmail;
        [self performSegueWithIdentifier:@"idShowEmailPasswordView" sender:self];
//        UIAlertView *passwordAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Email Password"
//                                                                    message:@"Why need email password?\n\n1. This app use your email to send notification to yourself. So it has to know the password;"
//                                                                            "\n\n2. Your password is only saved in this phone and never sent to anywhere. Check source code for details."
//                                                                            "\n\n3. Make sure this gmail account does NOT has two-step verification; otherwise you need an application specific password."
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"Cancel"
//                                                          otherButtonTitles:@"OK", nil
//        ];
//        passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
//
//        [passwordAlertView show];
    }


    [textField resignFirstResponder];

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480 || height == 960) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.settingsTableView.center = CGPointMake(self.settingsTableView.center.x, self.settingsTableView.center.y - 100.0f);
                         }];
    }
    return YES;
}

#pragma mark - UIPickerView

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSLog(@"selected run interval: %ld", (long)row);
    self.pickerSelectedRow = (int) row;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.runIntervals.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d mins", [self.runIntervals[(NSUInteger) row] intValue]];
}

#pragma mark - EmailPasswordViewControllerDelegate

- (void)dismissPasswordViewControllerWithPassword:(NSString *)password {
    if (password == nil) {
        self.emailField.text = @"";
        self.userEnteredEmail = nil;
        self.emailPassword = nil;
    } else {
        self.emailPassword = password;
    }
}

@end