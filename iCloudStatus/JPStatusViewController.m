//
//  JPViewController2ViewController.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/14/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPStatusViewController.h"
#import "JPICloudStatus.h"

@interface JPServiceStatus : NSObject
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *message;
@end

@implementation JPServiceStatus
@end

@interface JPStatusViewController ()
@property (nonatomic, strong) NSDictionary *groups;
@property (nonatomic, strong) NSArray *groupNames;
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
            NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
            NSMutableArray *groupNames = [[NSMutableArray alloc] init];
            NSDictionary *dashboard = json[@"dashboard"];
            for (NSString *group in [dashboard allKeys]) {
                NSMutableArray *statuses = [[NSMutableArray alloc] init];
                for (NSString *service in [dashboard[group] allKeys]) {
                    NSArray *messages = dashboard[group][service];
                    JPServiceStatus *status = [[JPServiceStatus alloc] init];
                    status.service = service;
                    if (messages.count > 0) {
                        status.message = [messages componentsJoinedByString:@", "];
                    }
                    [statuses addObject:status];
                }

                NSSortDescriptor *descriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"message" ascending:YES];
                NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"service" ascending:YES];
                [statuses sortUsingDescriptors:@[ descriptor1, descriptor2 ]];
                groups[group] = statuses;
                [groupNames addObject:group];
            }
            self.groups = groups;
            self.groupNames = groupNames;
        } else {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to retrieve iCloud status"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            self.groups = nil;
            self.groupNames = nil;
        }
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];

        //find first issue and scroll to it
        NSIndexPath *issue;
        for (NSString *groupName in self.groupNames) {
            for (int i=0; i<[self.groups[groupName] count]; i++) {
                JPServiceStatus *status = self.groups[groupName][i];
                if (status.message) {
                    issue = [NSIndexPath indexPathForRow:i inSection:[self.groupNames indexOfObject:groupName]];
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
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.groupNames[section];
    return [self.groups[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *key = self.groupNames[indexPath.section];

    JPServiceStatus *status = self.groups[key][indexPath.row];
    cell.textLabel.text = status.service;
    cell.imageView.contentMode = UIViewContentModeCenter;
    if (status.message) {
        cell.detailTextLabel.text = status.message;
        cell.imageView.image = [UIImage imageNamed:@"down.png"];
    } else {
        cell.detailTextLabel.text = nil;
        cell.imageView.image = [UIImage imageNamed:@"up.png"];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.groupNames[section];
}

@end
