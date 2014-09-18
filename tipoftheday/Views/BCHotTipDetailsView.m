//
//  BCHotTipDetailsView.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/14/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCHotTipDetailsView.h"

@implementation BCHotTipDetailsView

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
    UIColor* bEBlue = [UIColor colorWithRed: 0.157 green: 0.647 blue: 1 alpha: 1];
    UIColor* orange = [UIColor colorWithRed: 1 green: 0.51 blue: 0.157 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 0.98 green: 0.98 blue: 1 alpha: 0.5];
    UIColor* blackShadow10PC = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.106];
    UIColor* green = [UIColor colorWithRed: 0.227 green: 0.749 blue: 0.314 alpha: 1];
    UIColor* greyLines = [UIColor colorWithRed: 0.875 green: 0.875 blue: 0.875 alpha: 1];
    UIColor* pureWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Variable Declarations
    UIColor* tresholdColor = _isLive ? green : orange;
    
    //// Upper Rectangle Drawing
    UIBezierPath* upperRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 20, 320, 196)];
    [bEBlue setFill];
    [upperRectanglePath fill];
    
    //// Lower Rectangle Drawing
    UIBezierPath* lowerRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 216, 320, 136)];
    [pureWhite setFill];
    [lowerRectanglePath fill];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(20, 262.5, 300, 1)];
    [greyLines setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(20, 307, 300, 1)];
    [greyLines setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 352, 320, 1)];
    [greyLines setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 19, 320, 1)];
    [greyLines setFill];
    [rectangle4Path fill];
    
    
    //// Oval - AwayTeam Drawing
    UIBezierPath* ovalAwayTeamPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(208, 91, 66, 66)];
    [color setFill];
    [ovalAwayTeamPath fill];
    
    
    //// Oval - HomeTeam Drawing
    UIBezierPath* ovalHomeTeamPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(47, 91, 66, 66)];
    [color setFill];
    [ovalHomeTeamPath fill];
    
    
    //// Livescore
    {
        //// Rectangle - Shadow Drawing
        UIBezierPath* rectangleShadowPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(90, 2, 143, 38) cornerRadius: 19];
        [blackShadow10PC setFill];
        [rectangleShadowPath fill];
        
        
        //// Rectangle 1 Drawing
        UIBezierPath* rectangle1Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(90, 0, 143, 38) cornerRadius: 19];
        [tresholdColor setFill];
        [rectangle1Path fill];
    }

}


@end
