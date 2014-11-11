//
//  BCMasterViewController.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCMasterViewController.h"
#import "BCTipDetailsViewController.h"
#import "BCTip.h"

#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+FontAwesome.h"
#import "HexColor.h"
#import "MONActivityIndicatorView.h"
#import "NSDate+Utilities.h"
#import "CWStatusBarNotification.h"

#ifdef DEBUG
#define kAPIKeypath @"result"
#else
#define kAPIKeypath nil
#endif

@interface BCMasterViewController ()

@property (nonatomic, strong) BCTip *hotTipOfTheDay;
@property (nonatomic, strong) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) RKObjectManager *objectManager;

@end

@implementation BCMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationItem setTitle:@"TIP OF THE DAY"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#F6F7F7"]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Lato-Bold" size:17], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontAwesomeFamilyName size:21], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitle:[NSString fontAwesomeIconStringForEnum:FACog]];
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake(5, 0) forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontAwesomeFamilyName size:21], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitle:[NSString fontAwesomeIconStringForEnum:FAlineChart]];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-5, 0) forBarMetrics:UIBarMetricsDefault];
    
    _indicatorView = [[MONActivityIndicatorView alloc] init];
    _indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-40);
    [self.view addSubview:_indicatorView];
    [_indicatorView startAnimating];
    
//    Debug purposes
//    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
//    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadHotTipOfTheDay) forControlEvents:UIControlEventValueChanged];
    
    [self configureRestKit];
    [self loadHotTipOfTheDay];
    
    // GA Screen Tracking
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Home Screen"];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RestKit Methods

- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
//    RKLogConfigureByName("RestKit", RKLogLevelWarning);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    NSURL *baseURL = [NSURL URLWithString:kAPIEndpointHost];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *tipMapping = [RKObjectMapping mappingForClass:[BCTip class]];
    [tipMapping addAttributeMappingsFromDictionary:@{
                                                     @"strMatchTitle": @"name",
                                                     @"intMatchTime": @"matchTime",
                                                     @"strBetType": @"betType",
                                                     @"intSelectionType": @"selectionType",
                                                     @"fltOdds": @"odds",
                                                     @"fltGoals": @"goals",
                                                     @"fltHandicap": @"handicap",
                                                     @"strCountryName": @"countryName",
                                                     @"strLeagueName": @"leagueName",
                                                     @"strFullAnalysis": @"fullAnalysis",
                                                     @"enetpulseStageId": @"enetpulseStageId",
                                                     @"enetpulseEventId": @"enetpulseEventId"
                                                    }];
    
    
    RKObjectMapping *tipsterMapping = [RKObjectMapping mappingForClass:[BCTipster class]];
    [tipsterMapping addAttributeMappingsFromDictionary:@{ @"strUsername": @"username" }];
    
    RKObjectMapping *bookmakerMapping = [RKObjectMapping mappingForClass:[BCBookmaker class]];
    [bookmakerMapping addAttributeMappingsFromDictionary:@{ @"strName": @"name", @"strLink": @"affiliateLink", @"strLogo": @"logoUrl" }];
    
    RKObjectMapping *teamMapping = [RKObjectMapping mappingForClass:[BCTeam class]];
    [teamMapping addAttributeMappingsFromDictionary:@{ @"teamName": @"name", @"teamLogo": @"logoUrl" }];
    
    
    // Define the relationship mapping
    [tipMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"arrTipAuthor"
                                                                                           toKeyPath:@"tipster"
                                                                                         withMapping:tipsterMapping],
                                               [RKRelationshipMapping relationshipMappingFromKeyPath:@"arrAffiliate"
                                                                                           toKeyPath:@"bookmaker"
                                                                                         withMapping:bookmakerMapping],
                                               [RKRelationshipMapping relationshipMappingFromKeyPath:@"teams"
                                                                                           toKeyPath:@"teams"
                                                                                         withMapping:teamMapping]]];
    
    // register mappings with the provider using a response descriptor
//#warning - Need to change this when the feature-api branch will be pushed live
    NSString *keyPath = @"result.tip"; // Prod
//    #ifdef DEBUG
//    keyPath = @"result.tip"; // Dev
//    #endif
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:tipMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:keyPath
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

- (void)loadHotTipOfTheDay
{
    [_objectManager getObjectsAtPath:@"/api/tips/hot/single/1/EN"
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                      _hotTipOfTheDay = [mappingResult firstObject];
                                  if (![_indicatorView isHidden])
                                      [_indicatorView stopAnimating];
                                 [refreshControl endRefreshing];
                                 [self.tableView reloadData];
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"What do you mean by 'there is an error?': %@", error);
//                                ERROR : CHECK FOR "NO TIP FOUND" VALUE
                                if (![_indicatorView isHidden])
                                    [_indicatorView stopAnimating];
                                [refreshControl endRefreshing];
                                CWStatusBarNotification *notification = [CWStatusBarNotification new];
                                notification.notificationLabelBackgroundColor = [UIColor colorWithHexString:@"#c0392b"];
                                notification.notificationLabelTextColor = [UIColor whiteColor];
                                [notification displayNotificationWithMessage:@"Please check your network connection and try again."
                                                                 forDuration:3.0f];
                            }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_hotTipOfTheDay != nil)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = [UIColor colorWithHexString:@"#F6F7F7"];
    cell.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#F6F7F7"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"";
    if (indexPath.section == 0)
        cellIdentifier = @"HeaderCell";
    else
        cellIdentifier = @"TipCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        UILabel *headerLabel = (UILabel *)[cell viewWithTag:10];
        [headerLabel setFont:[UIFont fontWithName:@"Lato-Light" size:17]];
    }
    else {
        
        UILabel *leagueName = (UILabel *)[cell viewWithTag:22];
        [leagueName setText:[_hotTipOfTheDay leagueName]];
        [leagueName setFont:[UIFont fontWithName:@"Lato-Bold" size:15]];
        
        UILabel *versusLabel = (UILabel *)[cell viewWithTag:23];
        [versusLabel setFont:[UIFont fontWithName:@"Lato-Black" size:18]];
        
        UIImageView *homeTeamLogo = (UIImageView *)[cell viewWithTag:10];
        UIImageView *awayTeamLogo = (UIImageView *)[cell viewWithTag:11];
        [homeTeamLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [awayTeamLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [homeTeamLogo sd_setImageWithURL:[NSURL URLWithString:[[[_hotTipOfTheDay teams] firstObject] logoUrl]]
                          placeholderImage:[UIImage imageNamed:@"teamlogo-placeholder"]];
        [awayTeamLogo sd_setImageWithURL:[NSURL URLWithString:[[[_hotTipOfTheDay teams] lastObject] logoUrl]]
//                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                        placeholderImage:[UIImage imageNamed:@"teamlogo-placeholder"]];
        
        UILabel *homeTeamName = (UILabel *)[cell viewWithTag:20];
        UILabel *awayTeamName = (UILabel *)[cell viewWithTag:21];
        [homeTeamName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [awayTeamName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [homeTeamName setText:[[[_hotTipOfTheDay teams] firstObject] name]];
        [awayTeamName setText:[[[_hotTipOfTheDay teams] lastObject] name]];
        
        
        UILabel *clockSymbol = (UILabel *)[cell viewWithTag:30];
        [clockSymbol setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:17]];
        [clockSymbol setText:[NSString fontAwesomeIconStringForEnum:FAClockO]];
        UILabel *kickOffTime = (UILabel *)[cell viewWithTag:31];
        [kickOffTime setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        UILabel *alternateKickOffLabel = (UILabel *)[cell viewWithTag:32];
        [alternateKickOffLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        NSString *timeStamp = [dateFormatter stringFromDate:[_hotTipOfTheDay getKickOffTime]];
//        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//        [dateFormatter setTimeZone:gmt];
        
        if ([[_hotTipOfTheDay getKickOffTime] isInPast]) {
            [clockSymbol setHidden:YES];
            [kickOffTime setHidden:YES];
            [alternateKickOffLabel setHidden:NO];
            if ([[_hotTipOfTheDay getKickOffTime] isToday])
                [alternateKickOffLabel setText:@"LIVE"];
            else
                [alternateKickOffLabel setText:@"Finished"];
        }
        else
            [kickOffTime setText:timeStamp];
        
        // Setup the string
        NSMutableAttributedString *buttonText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   Watch live at bet365", [NSString fontAwesomeIconStringForEnum:FADesktop]]];
        
        // Set the font to bold from the beginning of the string to the ","
        [buttonText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:kFontAwesomeFamilyName size:14] forKey:NSFontAttributeName] range:NSMakeRange(0, 2)];
        
        // Normal font for the rest of the text
        [buttonText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Montserrat-Regular" size:16] forKey:NSFontAttributeName] range:NSMakeRange(2, [buttonText length]-2)];
        
        UIButton *goToWatchLiveGamesAtBet365 = (UIButton *)[cell viewWithTag:40];
        [goToWatchLiveGamesAtBet365 setBackgroundColor:[UIColor colorWithHexString:@"3ABF50"]];
        [goToWatchLiveGamesAtBet365 setTintColor:[UIColor whiteColor]];
//        [goToWatchLiveGamesAtBet365.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]];
        [goToWatchLiveGamesAtBet365 setAttributedTitle:buttonText forState:UIControlStateNormal];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section== 0) {
        return 116;
    }
    else
        return 305;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
////    return YES;
//    return NO;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showDetail"] && _hotTipOfTheDay == nil)
        return NO;
    else
        return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        [OtherLevels registerEvent:@"Read the tip of the day"
                             label:@"Tip of the day was opened"];
        [[segue destinationViewController] setHotTipOfTheDay:_hotTipOfTheDay];
    }
}

#pragma mark - Controller methods

- (IBAction)goToBookmaker:(id)sender {
    [OtherLevels registerEvent:@"External link"
                         label:@"Watch live at bet365 (home view)"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"External link"     // Event category (required)
                                                          action:@"Button"  // Event action (required)
                                                           label:@"Watch live at bet365 (home view)"    // Event label
                                                           value:nil] build]];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bettingexpert.com/goto/bet365"]];
}

@end
