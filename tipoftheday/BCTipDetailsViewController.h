//
//  BCTipDetailsViewController.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/14/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCTip.h"

@interface BCTipDetailsViewController : UITableViewController

@property (nonatomic, strong) BCTip *hotTipOfTheDay;
@property (nonatomic, weak) IBOutlet UIButton *helpPopupTopLeft;

@end
