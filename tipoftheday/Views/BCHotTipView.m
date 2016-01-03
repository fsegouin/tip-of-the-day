//
//  BCHotTipView.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/14/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCHotTipView.h"
#import "NSString+FontAwesome.h"
#import "UIColor+Hex.h"

@implementation BCHotTipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [self setBackgroundColor:[UIColor colorWithHexString:@"#F6F7F7"]];
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
    UIColor* strokeColor = [UIColor colorWithRed: 0.875 green: 0.875 blue: 0.875 alpha: 1];
    UIColor* orange = [UIColor colorWithRed: 1 green: 0.51 blue: 0.157 alpha: 1];
    UIColor* pureWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 0.98 green: 0.98 blue: 1 alpha: 0.5];
    UIColor* blackShadow10PC = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.106];
    
    //// Upper Rectangle Drawing
    UIBezierPath* upperRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(13, 20, 296, 185.5)];
    [bEBlue setFill];
    [upperRectanglePath fill];
    [strokeColor setStroke];
    upperRectanglePath.lineWidth = 1;
    [upperRectanglePath stroke];
    
    
    //// Lower Rectangle - Stroke Rect Drawing
    UIBezierPath* lowerRectangleStrokeRectPath = [UIBezierPath bezierPathWithRect: CGRectMake(13, 206, 296, 98)];
    [strokeColor setStroke];
    lowerRectangleStrokeRectPath.lineWidth = 1;
    [lowerRectangleStrokeRectPath stroke];
    
    
    //// Lower Rectangle Drawing
    UIBezierPath* lowerRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(13.5, 204.5, 295, 98)];
    [pureWhite setFill];
    [lowerRectanglePath fill];
    
    
    //// Oval - AwayTeam Drawing
    UIBezierPath* ovalAwayTeamPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(208, 80, 66, 66)];
    [color setFill];
    [ovalAwayTeamPath fill];
    
    
    //// Oval - HomeTeam Drawing
    UIBezierPath* ovalHomeTeamPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(47, 80, 66, 66)];
    [color setFill];
    [ovalHomeTeamPath fill];
    
    //// Trophy Logo
    {
        
        //// Oval - TrophyLogo Shadow Drawing
        UIBezierPath* ovalTrophyLogoShadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(142, 2, 38, 38)];
        [blackShadow10PC setFill];
        [ovalTrophyLogoShadowPath fill];
        
        //// Oval - TrophyLogo Drawing
        UIBezierPath* ovalTrophyLogoPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(142, 0, 38, 38)];
        [orange setFill];
        [ovalTrophyLogoPath fill];
        
        //// Text Drawing
        CGRect textRect = CGRectMake(142, 0, 38, 38);
        {
            NSString* textContent = [NSString fontAwesomeIconStringForEnum:FATrophy];
            NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
            textStyle.alignment = NSTextAlignmentCenter;
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:22], NSForegroundColorAttributeName: pureWhite, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: CGRectOffset(textRect, 0, (CGRectGetHeight(textRect) - [textContent boundingRectWithSize: textRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height) / 2) withAttributes: textFontAttributes];
        }
    }
}


@end
