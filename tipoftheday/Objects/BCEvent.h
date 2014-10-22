//
//  BCEvent.h
//  tipoftheday
//
//  Created by Florent Segouin on 22/10/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCEvent : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *lineupConfirmed;
@property (nonatomic, strong) NSString *statusType;

@end
