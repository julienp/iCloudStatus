//
//  JPTimelineViewController.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPTimelineViewController.h"
#import "JPICloudStatus.h"


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
    [refresh addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update)
                                                 name:JPStatusUpdatedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    self.events = [JPICloudStatus sharedICloudStatus].events;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (IBAction)reload:(id)sender
{
    [[JPICloudStatus sharedICloudStatus] update];
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
