//
//  BCFractionOdds.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/22/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCFractionOdds : NSObject

@property (nonatomic, retain) NSNumber *decimalValue;

- (NSString *)stringValue;

- (id)initWithDecimalValue:(NSNumber *)value;
+ (NSNumber *)fractionOddsWithDecimalValue:(NSNumber *)value;

@end
