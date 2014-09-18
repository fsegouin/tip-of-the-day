//
//  BCBet365Event.h
//  tipoftheday
//
//  Created by Florent Segouin on 8/25/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BCBet365Market.h"

@interface BCBet365Event : NSObject

//<Event Name="Bochum v Union Berlin" ID="46747905" StartTime="25/08/14 19:15:00" EventComment="Live In-Play.">

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSArray *markets;

@end
