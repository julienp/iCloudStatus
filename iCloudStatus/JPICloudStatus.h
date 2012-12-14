//
//  JPICloudStatus.h
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JPCompletionBlock)(NSDictionary *data, NSError *error);

@interface JPICloudStatus : NSObject

- (void)fetchStatus:(JPCompletionBlock)completionBlock;

@end
