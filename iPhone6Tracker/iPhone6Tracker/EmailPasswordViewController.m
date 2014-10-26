//
// EmailPasswordViewController
// iPhone6Tracker
//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 10/25/14
// Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//


#import "EmailPasswordViewController.h"
#import "UIColor+iOS7Colors.h"


@implementation EmailPasswordViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.doneButton.enabled = NO;

    [self.doneButton setBackgroundColor:[UIColor iOS7darkGrayColor]];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.doneButton.layer.cornerRadius = 5.0f;

    [self.cancelButton setBackgroundColor:[UIColor iOS7redColor]];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.cancelButton.layer.cornerRadius = 5.0f;

    self.titleLabel.text = [NSString stringWithFormat:@"Enter Password of %@", self.emailAddress];
}

- (IBAction)buttonClicked:(id)sender {
    __weak EmailPasswordViewController *controller = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender == self.cancelButton) {
            [controller.delegate dismissPasswordViewControllerWithPassword:nil];
        } else if (sender == self.doneButton) {
            [controller.delegate dismissPasswordViewControllerWithPassword:controller.emailPasswordField.text];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newPassword = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneButton.enabled = newPassword.length > 0;
    if (self.doneButton.enabled) {
        [self.doneButton setBackgroundColor:[UIColor iOS7darkBlueColor]];
    } else {
        [self.doneButton setBackgroundColor:[UIColor iOS7darkGrayColor]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.emailPasswordField resignFirstResponder];

    return YES;
}

@end