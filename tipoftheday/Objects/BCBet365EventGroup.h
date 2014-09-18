//
//  BCBet365EventGroup.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/25/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BCBet365Event.h"

@interface BCBet365EventGroup : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSArray *events;

@end
