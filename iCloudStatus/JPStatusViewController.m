//
//  JPViewController2ViewController.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPStatusViewController.h"
#import "JPICloudStatus.h"


@interface JPStatusViewController ()
@property (nonatomic, strong) NSDictionary *statuses;
@property (nonatomic, strong) NSArray *sections;
@end

@implementation JPStatusViewController

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
    self.sections = [JPICloudStatus sharedICloudStatus].sections;
    self.statuses = [JPICloudStatus sharedICloudStatus].statuses;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    
    //find first issue and scroll to it
    NSIndexPath *issue;
    for (int i = 0; i < [self.sections count]; i++) {
        NSString *sectionName = self.sections[i];
        for (int j = 0; j < [self.statuses[sectionName] count]; j++) {
            JPServiceStatus *status = self.statuses[sectionName][j];
            if (status.events) {
                issue = [NSIndexPath indexPathForRow:j inSection:i];
                break;
            }
        }
        if (issue) {
            break;
        }
    }
    if (issue) {
        [self.tableView scrollToRowAtIndexPath:issue atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (IBAction)reload:(id)sender
{
    [[JPICloudStatus sharedICloudStatus] update];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.sections[section];
    return [self.statuses[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *key = self.sections[indexPath.section];

    JPServiceStatus *status = self.statuses[key][indexPath.row];
    cell.textLabel.text = status.service;
    cell.imageView.contentMode = UIViewContentModeCenter;
    if (status.events.count > 0) {
        //TODO:
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
//                                     status.events[0][@"statusType"],
//                                     status.events[0][@"usersAffected"]];
        cell.imageView.image = [UIImage imageNamed:@"down.png"];
    } else {
        cell.detailTextLabel.text = nil;
        cell.imageView.image = [UIImage imageNamed:@"up.png"];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section];
}

@end
