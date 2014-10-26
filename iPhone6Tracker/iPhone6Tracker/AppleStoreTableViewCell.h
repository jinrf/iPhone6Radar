//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppleStoreTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityStateZipLabel;
@property (nonatomic, weak) IBOutlet UILabel *hour1Label;
@property (nonatomic, weak) IBOutlet UILabel *hour2Label;
@property (nonatomic, weak) IBOutlet UILabel *hour3Label;
@property (nonatomic, weak) IBOutlet UIButton *phoneButton;
@property (nonatomic, weak) IBOutlet UIButton *storeNameButton;

@property NSString *storeUrl;

- (IBAction) buttonClicked:(id)sender;

@end