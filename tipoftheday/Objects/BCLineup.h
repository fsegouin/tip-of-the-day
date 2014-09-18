//
//  BCLineup.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCParticipant.h"

@interface BCLineup : NSObject

@property (nonatomic, strong) NSNumber *countryFK;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shirtNumber;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *type;
//@property (nonatomic, strong) BCInjury *injury;

- (NSString *)getStringPositionFromPositionNumber;

@end
