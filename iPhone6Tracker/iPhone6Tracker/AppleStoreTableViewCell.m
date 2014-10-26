//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import "AppleStoreTableViewCell.h"
#import "UIColor+iOS7Colors.h"
#import "CSNotificationView.h"
#import "AppDelegate.h"


@implementation AppleStoreTableViewCell {

}

- (IBAction)buttonClicked:(id)sender {
    if (sender == self.storeNameButton) {
        if (self.storeUrl.length > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.storeUrl]];
        }
    } else if (sender == self.phoneButton) {
        if (self.phoneButton.titleLabel.text.length > 0) {
            NSString *phoneNumber = [[self.phoneButton.titleLabel.text
                    componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                    componentsJoinedByString:@""];
            phoneNumber = [NSString stringWithFormat:@"+%@", phoneNumber];

            NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNumber]];

            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                [[UIApplication sharedApplication] openURL:phoneUrl];
            } else {
                [CSNotificationView showInViewController:[AppDelegate sharedDelegate].window.rootViewController
                                                   style:CSNotificationViewStyleError
                                                 message:@"Oops, call functionality is not available."
                ];
            }
        }
    }
}

@end