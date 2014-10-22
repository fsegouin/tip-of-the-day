//
//  BCLineupTableViewController.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/18/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCTeam.h"
#import "BCEvent.h"

@interface BCLineupTableViewController : UITableViewController

@property (nonatomic, strong) BCTeam *selectedTeam;
@property (nonatomic, strong) BCEvent *event;

@end
