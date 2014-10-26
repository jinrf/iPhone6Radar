//
//  EmailSender
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/9/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import "EmailSender.h"
#import "AppDelegate.h"
#import "iPhone6.h"
#import "AppleStore.h"
#import "SKPSMTPMessage.h"

@interface EmailSender () <SKPSMTPMessageDelegate>

@end

@implementation EmailSender {

}

+ (id)sharedSender {
    static EmailSender *sharedSender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSender = [[self alloc] init];
    });
    return sharedSender;
}

- (void)sendEmailTo:(NSString *)toEmail
               from:(NSString *)fromEmail
           password:(NSString *)fromEmailPassword
            subject:(NSString *)subject
            content:(NSString *)htmlContent  {
    @try {
        SKPSMTPMessage *alertEmail = [[SKPSMTPMessage alloc] init];
        alertEmail.delegate = self;

        [alertEmail setFromEmail:fromEmail];
        [alertEmail setToEmail:toEmail];
        [alertEmail setRelayHost:@"smtp.gmail.com"];
        [alertEmail setRequiresAuth:YES];
        [alertEmail setLogin:fromEmail];
        [alertEmail setPass:fromEmailPassword];
        [alertEmail setSubject:subject];
        [alertEmail setWantsSecure:YES];
        [alertEmail setDelegate:self];

        NSDictionary *htmlPart = @{kSKPSMTPPartContentTypeKey : @"text/html", kSKPSMTPPartMessageKey : htmlContent, kSKPSMTPPartContentTransferEncodingKey : @"8bit"};
        [alertEmail setParts:@[htmlPart]];
        [alertEmail send];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to send email to: %@, exception: %@, %@", toEmail, exception, [exception userInfo]);
    }
}

- (NSString *) htmlContentForModelNumbers:(NSArray *)modelNumbers {
    NSDictionary *dict = [AppDelegate readStoreInventory];
    NSMutableString *htmlContent = [NSMutableString stringWithString:@""];

    [htmlContent appendString:@"<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\"><body><table>"];
    [htmlContent appendString:@"<tr><td>Hi there,</td></tr>"];
    [htmlContent appendString:@"<tr><td><span style=\"padding-left:20px\"></span></td></tr>"];
    [htmlContent appendString:@"<tr><td>Great News! We just found following iPhone 6/6+ in stock near you:</td></tr>"];
    [htmlContent appendString:@"<tr><td><ul>"];
    for (NSString *mn in modelNumbers) {
        NSString *phoneDesc = [iPhone6 descriptionFromModelNumber:mn];

        NSArray *stores = dict[mn];
        NSMutableArray *storeLinks = [NSMutableArray array];
        for (AppleStore *store in stores) {
            [storeLinks addObject:[NSString stringWithFormat:@"<a href='%@'>%@</a>", store.storeUrl, store.name]];
        }

        [htmlContent appendString:[NSString stringWithFormat:@"<li>%@: %@</li>", phoneDesc, [storeLinks componentsJoinedByString:@", "]]];
    }
    [htmlContent appendString:@"</ul></td><tr>"];

    [htmlContent appendString:@"<tr><td><i>Please NOTE that iPhone 6/6+ sell very quickly. Make sure to verify with Apple Stores before going there.</i></td></tr>"];
    [htmlContent appendString:@"<tr><td><span style=\"padding-left:20px\"></span></td></tr>"];
    [htmlContent appendString:@"<tr><td>Good Luck!</td></tr>"];
    [htmlContent appendString:@"<tr><td><span style=\"padding-left:20px\"></span></td></tr>"];
    [htmlContent appendString:@"<tr><td>Sent by <a href='iphone6radar://'>iPhone 6 Radar</a></td></tr>"];
    [htmlContent appendString:@"<tr><td><div style=\"font-size:xx-small;\">To unsubscribe, remove your email address from iPhone 6 Radar app.</div></td></tr>"];
    [htmlContent appendString:@"</table></body></html>"];

    return htmlContent;
}


- (void)messageSent:(SKPSMTPMessage *)message {
    NSLog(@"Message Sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    NSLog(@"Message Failed With Error(s): %@", [error description]);
}
@end