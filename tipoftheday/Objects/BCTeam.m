//
//  BCTeam.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCTeam.h"
#import "BCLineup.h"

@implementation BCTeam

- (NSString *)getTeamFormationString {
    NSMutableDictionary *formation = [NSMutableDictionary dictionary];
    NSString *formationString = @"";
    for (BCLineup *player in self.lineups) {
        if ([player.position intValue] != 0 && ([player.position intValue]/10) != 1) {
            NSNumber *linePosition = [NSNumber numberWithInt:([player.position intValue]/10)];
            if ([formation valueForKey:[linePosition stringValue]] != nil)
                [formation setObject:[NSNumber numberWithInt:[[formation valueForKey:[linePosition stringValue]] intValue]+1] forKey:[linePosition stringValue]];
            else
                [formation setObject:[NSNumber numberWithInt:1] forKey:[linePosition stringValue]];
        }
    }
    NSArray *sortedKeysFromFormation = [NSArray arrayWithArray:[formation allKeys]];
    sortedKeysFromFormation = [sortedKeysFromFormation sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    for (NSString *keyFromFormation in sortedKeysFromFormation) {
        NSNumber *value = [formation objectForKey:keyFromFormation];
        formationString = [formationString stringByAppendingString:[NSString stringWithFormat:@"%d-", [value intValue]]];
    }
    if ([formationString length] != 0)
        formationString = [formationString substringToIndex:[formationString length]-1];
    return formationString;
}

- (void)setLogoUrl:(NSString *)logoUrl {
    //do something else
    NSArray *parts = [logoUrl componentsSeparatedByString:@"/"];
    NSString *filename = [parts lastObject];
    if ([logoUrl isEqualToString:@""] || [filename isEqualToString:@"be_crest.png"])
        _logoUrl = nil;
    else
        _logoUrl = logoUrl;
}

- (void)setLineups:(NSArray *)lineups {
    _lineups = lineups;
    //do something else
    self.substitutes = [NSMutableArray array];
    [self separateSubstitutes];
}

- (void)separateSubstitutes {
    NSMutableArray *lineupsCopy = [[NSMutableArray alloc] init];
    lineupsCopy = [NSMutableArray arrayWithArray:_lineups];
    for (BCLineup *player in _lineups) {
        if ([player.position intValue] == 0 && [player.shirtNumber intValue] != 0) {
            // This player is a substitute
            [self.substitutes addObject:player];
            [lineupsCopy removeObject:player];
        }
    }
    // Move the coach to the end of the array (better for tableView later)
    if ([lineupsCopy count] != 0) {
        [lineupsCopy insertObject:[lineupsCopy objectAtIndex:0] atIndex:[lineupsCopy count]];
        [lineupsCopy removeObjectAtIndex:0];
    }
    _lineups = [NSArray arrayWithArray:lineupsCopy];
}

@end
