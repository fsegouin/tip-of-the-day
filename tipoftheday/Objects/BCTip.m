//
//  BCTip.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCTip.h"
#import "BCFractionOdds.h"

#import "HCObjectSwitch.h"
#import "NSString+FontAwesome.h"
#import "NSString+HTML.h"
#import "UIColor+Hex.h"

@implementation BCTip

- (NSDate *)getKickOffTime
{
    return [NSDate dateWithTimeIntervalSince1970:[self.matchTime doubleValue]];
}

- (void)setResultStatus:(NSNumber *)resultStatus {
    _resultStatus = resultStatus;
    _resultSymbol = [NSString string];
    _symbolHexColor = [NSString string];
    switch ([resultStatus intValue]) {
        case 0:
            _resultSymbol = [NSString fontAwesomeIconStringForEnum:FAQuestionCircle];
            _symbolHexColor = @"3498db";
            break;
        case 1:
            _resultSymbol = [NSString fontAwesomeIconStringForEnum:FACheckCircle];
            _symbolHexColor = @"1ABC9C";
            break;
        case 2:
            _resultSymbol = [NSString fontAwesomeIconStringForEnum:FATimesCircle];
            _symbolHexColor = @"E74C3C";
            break;
        case 3:
            _resultSymbol = [NSString fontAwesomeIconStringForEnum:FAMinusCircle];
            _symbolHexColor = @"F5A623";
            break;
        default:
            _resultSymbol = [NSString fontAwesomeIconStringForEnum:FAQuestionCircle];
            _symbolHexColor = @"3498db";
            break;
    }
}

- (void)setOdds:(NSNumber *)odds
{
    _odds = odds;
    _fractionOdds = [[BCFractionOdds fractionOddsWithDecimalValue:odds] stringValue];
}

- (void)setFullAnalysis:(NSString *)fullAnalysis
{
    _fullAnalysis = [fullAnalysis stringByConvertingHTMLToPlainText];
}

- (NSString *)getSelectionString
{
    NSString *selectionString;
    
    switch ([self.selectionType intValue]) {
        case 1:
            selectionString = @"Home";
            break;
        case 2:
            selectionString = @"Draw";
            break;
        case 3:
            selectionString = @"Away";
            break;
        case 4:
            selectionString = @"Under";
            break;
        case 5:
            selectionString = @"Over";
            break;
        case 10:
            selectionString = @"Yes";
            break;
        case 11:
            selectionString = @"No";
            break;
        default:
            break;
    }
    
    __block NSString *outSelectionString;
    
    Switch (self.betType)
    {
        Case (@"ah")
        {
            outSelectionString = [selectionString stringByAppendingString:[NSString stringWithFormat:@" %@", [self.handicap stringValue]]];
        },
        
        Case (@"ou")
        {
            outSelectionString = [selectionString stringByAppendingString:[NSString stringWithFormat:@" %@", [self.goals stringValue]]];
        },
        Case (@"bts")
        {
//            [selectionString stringByAppendingString:[NSString stringWithFormat:@"BTS: %@", [self.goals stringValue]]];
//            selectionString = [NSString stringWithFormat:@"BTS: %@", selectionString];
            outSelectionString = [@"BTS:" stringByAppendingString:selectionString];
        },
        Case (@"dnb")
        {
            //            [selectionString stringByAppendingString:[NSString stringWithFormat:@"BTS: %@", [self.goals stringValue]]];
            //            selectionString = [NSString stringWithFormat:@"BTS: %@", selectionString];
            outSelectionString = [NSString stringWithFormat:@"%@ DNB", selectionString];
        },
        Default
        {
            outSelectionString = selectionString;
            // The _object_ object is the object that was used in the switch statement.
            // This is available automatically.
//            NSLog(@"Segue '%@' triggered by: %@", _object_, sender);
        },
    };
        
    return outSelectionString;
}

@end
