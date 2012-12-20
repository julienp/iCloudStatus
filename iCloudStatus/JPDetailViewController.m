//
//  JPDetailViewController.m
//  iCloudStatus
//
//  Created by Julien Poissonnier on 12/20/12.
//  Copyright (c) 2012 Julien Poissonnier. All rights reserved.
//

#import "JPDetailViewController.h"

@interface JPDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *usersLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;
@end

@implementation JPDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.event.title;
    self.messageLabel.text = self.event.message;
    self.usersLabel.text = self.event.usersAffected;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;

    self.startDateLabel.text = [formatter stringFromDate:self.event.startDate];
    if (self.event.endDate) {
        self.endDateLabel.text = [formatter stringFromDate:self.event.endDate];
    } else {
        self.endDateLabel.text = @" - ";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pop:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
