//
//  BCBet365Participant.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/25/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCBet365Participant : NSObject

//<Participant Name="Draw" Odds="12/5" OddsDecimal="3.40" Handicap="" ID="594633191" LastUpdated="24/08/14 14:31:48"/>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *fractionOdds;
@property (nonatomic, strong) NSNumber *decimalOdds;
@property (nonatomic, strong) NSNumber *handicap;

@end
