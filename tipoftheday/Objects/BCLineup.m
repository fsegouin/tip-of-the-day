//
//  BCLineup.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCLineup.h"

@implementation BCLineup

- (NSString *)getStringPositionFromPositionNumber
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
    
    NSString *position = [NSString string];
    
    switch ([self.position intValue]/10) {
        case (0):
            if ([self.type isEqualToString:@"coach"])
                position = @"Coach";
            else
                position = @"Substitute";
            break;
            
        case (1):
            position = @"Goalkeeper";
            break;
            
        case (2):
        case (3):
        case (4):
        case (5):
            position = @"Defender";
            break;
            
        case (6):
        case (7):
        case (8):
        case (9):
            position = @"Midfield";
            break;
            
        case (10):
        case (11):
            position = @"Offense";
            break;
            
        default:
            position = @"Unknown";
            break;
    }
    
    return position;
}

@end
