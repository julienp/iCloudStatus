//
//  JPTimelineViewController.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPTimelineViewController.h"
#import "JPICloudStatus.h"

@interface JPEvent : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@end

@implementation JPEvent
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", self.title, self.message];
}
@end

@interface JPTimelineViewController ()
@property (nonatomic, strong) NSArray *events;
@end

@implementation JPTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    JPICloudStatus *status = [[JPICloudStatus alloc] init];
    [status fetchStatus:^(NSDictionary *json, NSError *error) {
        if (json) {
            NSMutableArray *events = [[NSMutableArray alloc] init];
            NSDictionary *timeline = json[@"detailedTimeline"];
            for (NSDictionary *item in timeline) {
                JPEvent *event = [[JPEvent alloc] init];
                event.title = item[@"messageTitle"];
                event.message = item[@"message"];
                [events addObject:event];
            }
            self.events = events;
            //TODO: sort by start date
        } else {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to retrieve iCloud status"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            self.events = nil;
        }
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    JPEvent *event = self.events[indexPath.row];
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = event.message;
    
    return cell;
}

@end
