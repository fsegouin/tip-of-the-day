//
//  BCHelpButton.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/22/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCHelpButton.h"
#import "UIColor+Hex.h"

@implementation BCHelpButton

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
    //// Color Declarations
    UIColor* bEBlue = [UIColor colorWithHex:0x006bb3];
    
    // Drawing code
    CGRect ovalRect = CGRectMake(0, 0, 22, 22);
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
    [bEBlue setFill];
    [ovalPath fill];
    {
        NSString* textContent = @"?";
        NSMutableParagraphStyle* ovalStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        ovalStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary* ovalFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Montserrat-Regular" size: 16], NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: ovalStyle};
        
        [textContent drawInRect: CGRectOffset(ovalRect, 0, (CGRectGetHeight(ovalRect) - [textContent boundingRectWithSize: ovalRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: ovalFontAttributes context: nil].size.height) / 2) withAttributes: ovalFontAttributes];
    }
}

@end
