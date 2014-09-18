//
//  BCHotTipAnalysisViewTableViewCell.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/15/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCHotTipAnalysisViewTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;

- (void)updateFonts;

@end
