//
//  BCBet365Market.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/25/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BCBet365Participant.h"

@interface BCBet365Market : NSObject

//<Market Name="Full Time Result" ID="40" PlaceCount="1" PlaceOdds="1/1">

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSArray *participants;

@end
