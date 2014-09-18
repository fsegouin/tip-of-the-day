//
//  BCSoccerFieldView.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/18/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCSoccerFieldView.h"
#import "BCLineup.h"

@implementation BCSoccerFieldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    //
    //    How the data is mapped by Enetpulse
    //    ===================================
    //
    //                          Right	Right	Right Center	Center	Center	Center	Left Center	Left	Left
    //                             x1       x2      x3            x4      x5      x6      x7         x8      x9
    //    Goalkeeper            1x	11
    //    Defender - defensive	2x	21	22	23	24	25	26	27	28	29
    //    Defender              3x	31	32	33	34	35	36	37	38	39
    //    Defender              4x	41	42	43	44	45	46	47	48	49
    //    Defender - offensive	5x	51	52	53	54	55	56	57	58	59
    //    Midfield - defensive	6x	61	62	63	64	65	66	67	68	69
    //    Midfield              7x	71	72	73	74	75	76	77	78	79
    //    Midfield              8x	81	82	83	84	85	86	87	88	89
    //    Midfield - offensive	9x	91	92	93	94	95	96	97	98	99
    //    Offense               10x	101	102	103	104	105	106	107	108	109
    //    Offense               11x	111	112	113	114	115	116	117	118	119
    //
    
    //// Color Declarations
    UIColor* bEBlue = [UIColor colorWithRed: 0.157 green: 0.647 blue: 1 alpha: 1];
    UIColor* tableViewBackgroundColor = [UIColor colorWithRed: 0.965 green: 0.969 blue: 0.969 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.2];
    UIColor* shirtNumber = [UIColor colorWithRed: 0.267 green: 0.267 blue: 0.267 alpha: 1];
    
    //// Pitch
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(30, 171)];
        [bezierPath addLineToPoint: CGPointMake(83, 31)];
        [bezierPath addLineToPoint: CGPointMake(238, 31)];
        [bezierPath addLineToPoint: CGPointMake(290, 171)];
        [bezierPath addLineToPoint: CGPointMake(30, 171)];
        [bezierPath closePath];
        [color2 setFill];
        [bezierPath fill];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(39, 168)];
        [bezier2Path addLineToPoint: CGPointMake(88.33, 34)];
        [bezier2Path addLineToPoint: CGPointMake(232.6, 34)];
        [bezier2Path addLineToPoint: CGPointMake(281, 168)];
        [bezier2Path addLineToPoint: CGPointMake(39, 168)];
        [bezier2Path closePath];
        bezier2Path.lineJoinStyle = kCGLineJoinRound;
        
        [tableViewBackgroundColor setStroke];
        bezier2Path.lineWidth = 2;
        [bezier2Path stroke];
        
        
        //// Bezier 3 Drawing
        UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
        [bezier3Path moveToPoint: CGPointMake(70, 84)];
        [bezier3Path addLineToPoint: CGPointMake(250, 84)];
        [tableViewBackgroundColor setStroke];
        bezier3Path.lineWidth = 1;
        [bezier3Path stroke];
        
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(134, 73, 51, 26)];
        [tableViewBackgroundColor setStroke];
        ovalPath.lineWidth = 2;
        [ovalPath stroke];
        
        
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
        [bezier4Path moveToPoint: CGPointMake(115, 168)];
        [bezier4Path addLineToPoint: CGPointMake(120, 142)];
        [bezier4Path addLineToPoint: CGPointMake(199, 142)];
        [bezier4Path addLineToPoint: CGPointMake(204, 168)];
        [bezier4Path addLineToPoint: CGPointMake(115, 168)];
        [bezier4Path closePath];
        [tableViewBackgroundColor setStroke];
        bezier4Path.lineWidth = 2;
        [bezier4Path stroke];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = UIBezierPath.bezierPath;
        [bezier5Path moveToPoint: CGPointMake(135.82, 34)];
        [bezier5Path addLineToPoint: CGPointMake(134, 42)];
        [bezier5Path addLineToPoint: CGPointMake(189, 42)];
        [bezier5Path addLineToPoint: CGPointMake(187.69, 34)];
        [bezier5Path addLineToPoint: CGPointMake(135.82, 34)];
        [bezier5Path closePath];
        [tableViewBackgroundColor setStroke];
        bezier5Path.lineWidth = 2;
        [bezier5Path stroke];
    }
    
    
    //// Formation
    {
        NSDictionary *yPosition = @{@"1": @154, // Gk
                                    @"2": @130, // Def
                                    @"3": @122, // Def
                                    @"4": @115, // Def
                                    @"5": @110, // Def
                                    @"6": @95,  // Mid
                                    @"7": @90,  // Mid
                                    @"8": @60,  // Mid
                                    @"9": @55,  // Mid
                                    @"10": @40, // Atk
                                    @"11": @30  // Atk
                                    };
        
        NSDictionary *xPosition = @{@"1": @43,
                                    @"2": @69,
                                    @"3": @95,
                                    @"4": @121,
                                    @"5": @147,
                                    @"6": @173,
                                    @"7": @199,
                                    @"8": @225,
                                    @"9": @251
                                    };
    
        for (BCLineup *player in self.players) {
            if ([player.position intValue] != 0) {
                NSNumber *linePosition = [NSNumber numberWithInt:([player.position intValue]/10)];
                CGFloat yPositionPlayer = [[yPosition valueForKey:[linePosition stringValue]] doubleValue];
                CGFloat xPositionPlayer = [[xPosition valueForKey:[player.position substringFromIndex:[player.position length]-1]] doubleValue];

                if ([player.position isEqualToString:@"11"]) // Exception for goalkeeper
                    xPositionPlayer = 147;
                
                //// Oval Drawing
                UIBezierPath* ovalPath2 = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(xPositionPlayer, yPositionPlayer, 26, 26)];
                [tableViewBackgroundColor setFill];
                [ovalPath2 fill];
                [bEBlue setStroke];
                ovalPath2.lineWidth = 1.5;
                [ovalPath2 stroke];
                
                //// Text Drawing
                CGRect textRect = CGRectMake(xPositionPlayer, yPositionPlayer, 26, 26);
                {
                    NSString* textContent = player.shirtNumber;
                    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
                    textStyle.alignment = NSTextAlignmentCenter;
                
                    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Lato-Bold" size: 13], NSForegroundColorAttributeName: shirtNumber, NSParagraphStyleAttributeName: textStyle};
                
                    [textContent drawInRect: CGRectOffset(textRect, 0, (CGRectGetHeight(textRect) - [textContent boundingRectWithSize: textRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height) / 2) withAttributes: textFontAttributes];
                }
            }
        }
    }
    
}

@end
