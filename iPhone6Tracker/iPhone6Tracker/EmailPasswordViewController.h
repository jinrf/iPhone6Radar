//
// EmailPasswordViewController
// iPhone6Tracker
//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 10/25/14
// Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//


#import <UIKit/UIkit.h>

@protocol EmailPasswordViewControllerDelegate

@required
- (void)dismissPasswordViewControllerWithPassword:(NSString *)password;

@end

@interface EmailPasswordViewController : UIViewController<UITextFieldDelegate>

@property IBOutlet UITextField *emailPasswordField;
@property IBOutlet UIButton *cancelButton;
@property IBOutlet UIButton *doneButton;
@property IBOutlet UILabel *titleLabel;

@property NSString *emailAddress;
@property (nonatomic, weak) id<EmailPasswordViewControllerDelegate> delegate;

- (IBAction) buttonClicked:(id)sender;

@end