//
//  BCHotTipAnalysisViewTableViewCell.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/15/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCHotTipAnalysisViewTableViewCell.h"
#import "PureLayout.h"
#import "UIColor+Hex.h"

#define kLabelHorizontalInsets      17.0f
#define kLabelVerticalInsets        10.0f

@interface BCHotTipAnalysisViewTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation BCHotTipAnalysisViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        [self setBackgroundColor:[UIColor whiteColor]];
        self.titleLabel = [UILabel newAutoLayoutView];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
        [self.titleLabel setTextColor:[UIColor colorWithHex:0x28A5FF]];
        
        self.bodyLabel = [UILabel newAutoLayoutView];
        [self.bodyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.bodyLabel setNumberOfLines:0];
        [self.bodyLabel setTextAlignment:NSTextAlignmentLeft];
        [self.bodyLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [self.bodyLabel setTextColor:[UIColor colorWithHex:0x444444]];

        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.bodyLabel];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self updateFonts];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) {
        return;
    }
    
    // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
    // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
    //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
    // self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        
//    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//        [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//    }];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    
    // This is the constraint that connects the title and body labels. It is a "greater than or equal" inequality so that if the row height is
    // slightly larger than what is actually required to fit the cell's subviews, the extra space will go here. (This is the case on iOS 7
    // where the cell separator is only 0.5 points tall, but in the tableView:heightForRowAtIndexPath: method of the view controller, we add
    // a full 1.0 point in extra height to account for it, which results in 0.5 points extra space in the cell.)
    // See https://github.com/smileyborg/TableViewCellWithAutoLayout/issues/3 for more info.
    [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
//    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//        [self.bodyLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//    }];
    [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];

    self.didSetupConstraints = YES;

}

//- (void)awakeFromNib
//{
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);
//    NSLog(@"self.bodyLabel.frame height (layout subviews) : %.2f", CGRectGetHeight(self.bodyLabel.frame));
}

- (void)updateFonts
{
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    self.bodyLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
}

@end
