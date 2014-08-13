//
//  BCDetailViewController.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
