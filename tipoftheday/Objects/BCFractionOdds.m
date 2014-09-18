//
//  BCFractionOdds.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/22/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCFractionOdds.h"
#import "BCFractionHelper.h"

@implementation BCFractionOdds

//To convert decimal odds to fraction odds, we need to form a fraction using: (odds-1)/1. This will come out ugly in most cases, so we need to do some multiplication and simplifying. For example, odds 1.45 are (1.45-1)/1 which is 0.45/1. Considering that we can't leave this as a fraction with a decimal, multiply both sides by 100 to get 45/100; from here, we simply the fraction to 9/20.

- (id)initWithDecimalValue:(NSNumber *)value
{
    self = [super init];
    if(self)
    {
        self.decimalValue = value;
    }
    return self;
}

+ (NSNumber *)fractionOddsWithDecimalValue:(NSNumber *)value
{
    return [[self alloc] initWithDecimalValue:value];
}

- (NSString *)stringValue
{
    float numerator = ([_decimalValue floatValue]-1)*100;
    float denominator = 100;
    return [BCFractionHelper getSimplifiedFractionWithNumerator:numerator andDenomonator:denominator];
}

@end
