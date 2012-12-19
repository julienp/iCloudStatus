//
//  JPICloudStatus.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPICloudStatus.h"


NSString * const JPStatusUpdatedNotification = @"JPStatusUpdatedNotification";


@implementation JPEvent

- (NSString *)description
{
    return [NSString stringWithFormat:@"JPEvent<%@: %@>", self.title, self.message];
}

@end


@implementation JPServiceStatus

- (NSString *)description
{
    return [NSString stringWithFormat:@"JPServiceStatus<%@: %@>", self.service, self.events];
}

@end


@interface JPICloudStatus ()

@property (nonatomic, strong) NSDictionary *statuses;
@property (nonatomic, strong) NSArray *events;

@end


typedef void (^JPCompletionBlock)(NSDictionary *data, NSError *error);


@implementation JPICloudStatus

+ (JPICloudStatus *)sharedICloudStatus
{
    static dispatch_once_t onceToken;
    static JPICloudStatus *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)update
{
    [self fetchStatus:^(NSDictionary *json, NSError *error) {
        if (json) {
            NSArray *eventsJson = json[@"detailedTimeline"];
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (NSDictionary *eventJson in eventsJson) {
                JPEvent *event = [[JPEvent alloc] init];
                event.title = eventJson[@"messageTitle"];
                event.message = eventJson[@"message"];
                event.messageId = [eventJson[@"messageId"] integerValue];
                [events addObject:event];
            }
            self.events = events;

            NSArray *serviceNames = [json[@"dashboard"] allKeys];
            NSMutableDictionary *statusesDictionary = [[NSMutableDictionary alloc] init];
            for (NSString *serviceName in serviceNames) {
                NSArray *statusNames = [json[@"dashboard"][serviceName] allKeys];
                NSMutableArray *statusArray = [[NSMutableArray alloc] init];
                for (NSString *statusName in statusNames) {
                    JPServiceStatus *status = [[JPServiceStatus alloc] init];
                    status.service = statusName;
                    NSArray *eventsJson = json[@"dashboard"][serviceName][statusName];
                    if (eventsJson.count > 0) {
                        NSMutableArray *events = [[NSMutableArray alloc] init];
                        for (NSDictionary *eventDictionary in eventsJson) {
                            NSInteger messageId = [eventDictionary[@"messageId"] integerValue];
                            NSUInteger index = [self.events indexOfObjectPassingTest:^BOOL(JPEvent *event, NSUInteger idx, BOOL *stop) {
                                if (event.messageId == messageId) {
                                    return YES;
                                }
                                return NO;
                            }];
                            [events addObject:self.events[index]];
                        }
                        status.events = events;
                    }
                    [statusArray addObject:status];
                }
                //TODO: caseInsentive sort
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"service" ascending:YES];
                [statusArray sortUsingDescriptors:@[ descriptor ]];
                statusesDictionary[serviceName] = statusArray;
            }
            self.statuses = statusesDictionary;
            [[NSNotificationCenter defaultCenter] postNotificationName:JPStatusUpdatedNotification object:self];
        } else {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to retrieve iCloud status"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }

    }];
}

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
