//
// This software is licensed under MIT License. See https://github.com/ychw/iPhone6Radar for more details.
//
// Created by Yuchen Wang on 9/25/14.
// Copyright (c) 2014 clingmarks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface iPhoneTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *iPhoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIView *finishView;
@property (nonatomic, weak) IBOutlet UIImageView *carrierLogoImageView;

@end