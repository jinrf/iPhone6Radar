//
//  EmailSender
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/9/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EmailSender : NSObject

+ (id)sharedSender;

- (NSString *) htmlContentForModelNumbers:(NSArray *)modelNumbers;
- (void)sendEmailTo:(NSString *)toEmail
               from:(NSString *)fromEmail
           password:(NSString *)fromEmailPassword
            subject:(NSString *)subject
            content:(NSString *)htmlContent;

@end