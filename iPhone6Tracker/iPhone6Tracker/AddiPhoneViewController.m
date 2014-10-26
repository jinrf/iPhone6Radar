//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "AddiPhoneViewController.h"
#import "iPhone6.h"
#import "UIColor+iOS7Colors.h"
#import "CSNotificationView.h"


@implementation AddiPhoneViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modelSegmt.selectedSegmentIndex = 0;
    self.finishSegmt.selectedSegmentIndex = 0;
    self.carrierSegmt.selectedSegmentIndex = 0;
    self.storageSegmt.selectedSegmentIndex = 0;

    [self.addButton setBackgroundColor:[UIColor iOS7greenColor]];
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    [self.cancelButton setBackgroundColor:[UIColor iOS7redColor]];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    self.addButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.cornerRadius = 5.0f;
}

- (IBAction)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)trackiPhone {
    iPhone6 *iphone = [[iPhone6 alloc] init];

    iphone.model = [self.modelSegmt titleForSegmentAtIndex:self.modelSegmt.selectedSegmentIndex];
    iphone.finish = [self.finishSegmt titleForSegmentAtIndex:self.finishSegmt.selectedSegmentIndex];
    iphone.carrier = [self.carrierSegmt titleForSegmentAtIndex:self.carrierSegmt.selectedSegmentIndex];

    if (self.storageSegmt.selectedSegmentIndex == 0) {
        iphone.storage = 16;
    } else if (self.storageSegmt.selectedSegmentIndex == 1) {
        iphone.storage = 64;
    } else if (self.storageSegmt.selectedSegmentIndex == 2) {
        iphone.storage = 128;
    }

    if ([iphone modelNumber]) {
        [self.delegate trackPhone:iphone];

        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.delegate trackPhone:nil];

        [CSNotificationView showInViewController:self
                                           style:CSNotificationViewStyleError
                                         message:@"Data incomplete. Please make a selection in all sections."
        ];
    }
}

@end