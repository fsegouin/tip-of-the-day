//
//  BCHotTipsHistoryStatsView.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/19/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCHotTipsHistoryStatsView.h"

@implementation BCHotTipsHistoryStatsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //// Color Declarations
    UIColor* greyLines = [UIColor colorWithRed: 0.875 green: 0.875 blue: 0.875 alpha: 1];
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(20, 80, 300, 1)];
    [greyLines setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 36, 320, 1)];
    [greyLines setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 320, 1)];
    [greyLines setFill];
    [rectangle4Path fill];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(20, 124, 300, 1)];
    [greyLines setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(20, 167, 300, 1)];
    [greyLines setFill];
    [rectangle5Path fill];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 210, 320, 1)];
    [greyLines setFill];
    [rectangle6Path fill];
}


@end
