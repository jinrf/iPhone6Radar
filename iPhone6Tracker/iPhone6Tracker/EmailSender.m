//
//  EmailSender
//  iPhone6Tracker
//
//  Created by Yuchen Wang on 10/9/14.
//  Copyright (c) 2014 www.clingmarks.com. All rights reserved.
//

#import <MailCore/mailcore.h>
#import "EmailSender.h"
#import "AppDelegate.h"
#import "iPhone6.h"
#import "AppleStore.h"

@interface EmailSender ()

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
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = fromEmail;
    smtpSession.password = fromEmailPassword;
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;

    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:nil
                                                  mailbox:fromEmail];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:toEmail];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:htmlContent];
    NSData * rfc822Data = [builder data];

    MCOSMTPSendOperation *sendOperation =
       [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@, %@", [error localizedDescription], error.userInfo);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
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

@end