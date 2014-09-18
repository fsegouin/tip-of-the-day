//
//  BCFractionHelper.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/22/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCFractionHelper : NSObject

+ (NSString *)getSimplifiedFractionWithNumerator:(int)numerator andDenomonator:(int)denominator;

@end
