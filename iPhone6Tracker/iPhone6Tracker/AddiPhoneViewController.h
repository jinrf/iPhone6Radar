//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPhone6;

@protocol AddiPhoneViewControllerDelegate

- (void) trackPhone:(iPhone6 *)newPhone;

@end

@interface AddiPhoneViewController : UIViewController

@property (nonatomic, weak) id<AddiPhoneViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UISegmentedControl *modelSegmt;
@property (nonatomic, weak) IBOutlet UISegmentedControl *finishSegmt;
@property (nonatomic, weak) IBOutlet UISegmentedControl *carrierSegmt;
@property (nonatomic, weak) IBOutlet UISegmentedControl *storageSegmt;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

- (IBAction) trackiPhone;
- (IBAction) cancel;

@end