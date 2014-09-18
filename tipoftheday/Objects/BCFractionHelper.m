//
//  BCFractionHelper.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/22/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCFractionHelper.h"

@implementation BCFractionHelper

+ (NSString *)getSimplifiedFractionWithNumerator:(int)numerator andDenomonator:(int)denominator
{
    int a = numerator;
    int b = denominator;
	int c = 0;
    
	while ( a != 0 )
    {
        c = a;
        a = b%a;
        b = c;
    }
    
	numerator /= c;
	denominator /= c;
    return [NSString stringWithFormat:@"%d/%d", numerator, denominator];
}

@end
