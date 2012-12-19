//
//  JPICloudStatus.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPICloudStatus.h"

@implementation JPICloudStatus

- (void)fetchStatus:(JPCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = @"http://www.apple.com/support/systemstatus/data/system_status_en_US.js";
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data) {
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"status_error" ofType:@"json"];
//            NSData *dummyData = [NSData dataWithContentsOfFile:path];
//            data = dummyData;
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (json) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(json, nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil, jsonError);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, error);
            });
        }
    });
}

@end
