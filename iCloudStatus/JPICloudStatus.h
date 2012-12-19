//
//  JPICloudStatus.h
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JPServiceStatus : NSObject

@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSArray *events;

@end


@interface JPEvent : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSString *usersAffected;
@property (nonatomic, strong) NSString *statusType;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end


extern NSString * const JPStatusUpdatedNotification;


@interface JPICloudStatus : NSObject

@property (nonatomic, strong, readonly) NSDictionary *statuses; //dictionary of sectionName -> array of JPServiceStatus
@property (nonatomic, strong, readonly) NSArray *events;

+ (JPICloudStatus *)sharedICloudStatus;
- (void)update;

@end
