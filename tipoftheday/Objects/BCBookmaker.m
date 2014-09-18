//
//  BCBookmaker.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCBookmaker.h"

@implementation BCBookmaker

@synthesize logoUrl = _logoUrl;

- (void)setLogoUrl:(NSString *)url {
    _logoUrl = [NSString stringWithFormat:@"http://www.bettingexpert.com%@", url];
}

@end
