//
//  BCTip.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCTipster.h"
#import "BCTeam.h"
#import "BCBookmaker.h"

@interface BCTip : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) BCTipster *tipster;
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) NSString *matchTime;
@property (nonatomic, strong) NSString *betType;
@property (nonatomic, strong) NSNumber *selectionType;
@property (nonatomic, strong) NSNumber *resultStatus;
@property (nonatomic, strong) NSString *resultSymbol;
@property (nonatomic, strong) NSString *symbolHexColor;
@property (nonatomic, strong) NSNumber *handicap;
@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong) NSNumber *odds;
@property (nonatomic, strong) NSString *fractionOdds;
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *leagueName;
@property (nonatomic, strong) NSString *fullAnalysis;
@property (nonatomic, strong) NSString *externalLink;
@property (nonatomic, strong) NSNumber *enetpulseStageId;
@property (nonatomic, strong) NSNumber *enetpulseEventId;
@property (nonatomic, strong) BCBookmaker *bookmaker;

- (NSDate *)getKickOffTime;
- (NSString *)getSelectionString;

@end
