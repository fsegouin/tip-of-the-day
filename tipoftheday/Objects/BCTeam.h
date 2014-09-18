//
//  BCTeam.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCParticipant.h"

@interface BCTeam : NSObject

//@property (nonatomic, strong) BCParticipant *team;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *countryFK;
@property (nonatomic, strong) NSString *logoUrl;
//@property (nonatomic, strong) NSString *formation;
@property (nonatomic, strong) NSArray *properties;
@property (nonatomic, strong) NSArray *liveScores;
@property (nonatomic, strong) NSArray *lineups;
@property (nonatomic, strong) NSMutableArray *substitutes;
@property (nonatomic, strong) NSArray *injuries;
@property (nonatomic, strong) NSArray *suspensions;

- (NSString *)getTeamFormationString;

@end
