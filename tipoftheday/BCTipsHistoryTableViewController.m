//
//  BCTipsHistoryTableViewController.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/19/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCTipsHistoryTableViewController.h"
#import "BCTip.h"
#import "BCHotTipsHistory.h"

#import <RestKit/RestKit.h>
#import "HexColor.h"
#import "NSString+FontAwesome.h"
#import "MONActivityIndicatorView.h"
#import "CWStatusBarNotification.h"

@interface BCTipsHistoryTableViewController ()

@property (nonatomic, retain) BCHotTipsHistory *hotTipsHistoryStats;
@property (nonatomic, retain) NSArray *hotTipsHistoryArray;
@property (nonatomic, strong) MONActivityIndicatorView *indicatorView;
@property (nonatomic, strong) RKObjectManager *objectManager;

@end

@implementation BCTipsHistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Hot tips history"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)]; // 30px from top
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
    _indicatorView = [[MONActivityIndicatorView alloc] init];
    _indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-40);
    [self.view addSubview:_indicatorView];
    [self configureRestKit];
    [self loadHotTipsHistory];
    [_indicatorView startAnimating];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadHotTipsHistory) forControlEvents:UIControlEventValueChanged];
    
    // GA Screen Tracking
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Tips History Screen"];
    
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
                                                     @"intResultStatus": @"resultStatus",
                                                     @"strCountryName": @"countryName",
                                                     @"strLeagueName": @"leagueName",
                                                     @"strLink": @"externalLink"
                                                     }];
    
    RKObjectMapping *teamMapping = [RKObjectMapping mappingForClass:[BCTeam class]];
    [teamMapping addAttributeMappingsFromDictionary:@{
                                                      @"teamName": @"name",
                                                      @"teamLogo": @"logoUrl"
                                                      }];
    
    RKObjectMapping *tipsHistory = [RKObjectMapping mappingForClass:[BCHotTipsHistory class]];
    [tipsHistory addAttributeMappingsFromDictionary:@{
                                                      @"intTotalHotTips": @"totalTips",
                                                      @"fltTotalYield": @"totalYield",
                                                      @"fltTotalResult": @"totalResult",
                                                      @"intWinningPercentage": @"winningPercentage"
                                                      }];
    
    
    // Define the relationship mapping
    [tipMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"teams"
                                                                                           toKeyPath:@"teams"
                                                                                         withMapping:teamMapping]]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:tipMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"result.tips"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor2 =
    [RKResponseDescriptor responseDescriptorWithMapping:tipsHistory
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"result.stats"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    [_objectManager addResponseDescriptor:responseDescriptor2];
    
//    [_objectManager getObjectsAtPath:@"/api/tips/hot/list/history/1/EN/0/10/"
//                                           parameters:nil
//                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//                                                  NSDictionary *results = [mappingResult dictionary];
//                                                  _hotTipsHistoryStats = [results objectForKey:@"result.stats"];
//                                                  _hotTipsHistoryArray = [results objectForKey:@"result.tips"];
//                                                  if (![_indicatorView isHidden])
//                                                      [_indicatorView stopAnimating];
//                                                  [self.tableView reloadData];
//                                              }
//                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                                                  NSLog(@"What do you mean by 'there is an error?': %@", error);
//                                              }];
}

- (void)loadHotTipsHistory
{
    [_objectManager getObjectsAtPath:@"/api/tips/hot/list/history/1/EN/0/10/"
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 NSDictionary *results = [mappingResult dictionary];
                                 _hotTipsHistoryStats = [results objectForKey:@"result.stats"];
                                 _hotTipsHistoryArray = [results objectForKey:@"result.tips"];
                                 if (![_indicatorView isHidden])
                                     [_indicatorView stopAnimating];
                                 [self.tableView reloadData];
                                 [refreshControl endRefreshing];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([_hotTipsHistoryArray count] == 0)
        return 0;
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 2)
        return [_hotTipsHistoryArray count];
    else
        return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if(indexPath.row % 2 == 0)
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F6F7F7"];
        else
            cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    static NSString *StatsCellIdentifier = @"StatsCell";
    static NSString *TipsHeaderCellIdentifier = @"TipsHeaderCell";
    static NSString *TipsCellIdentifier = @"TipsCell";
    
    
    NSString *cellIdentifier;
    
    switch (indexPath.section) {
        case 0:
            cellIdentifier = StatsCellIdentifier;
            break;
        case 1:
            cellIdentifier = TipsHeaderCellIdentifier;
            break;
        case 2:
            cellIdentifier = TipsCellIdentifier;
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        UILabel *statsHeaderLabel = (UILabel *)[cell viewWithTag:10];
        [statsHeaderLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [statsHeaderLabel setText:@"STATS"];
        UILabel *totalHotTipsLabel = (UILabel *)[cell viewWithTag:20];
        [totalHotTipsLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        UILabel *totalYieldLabel = (UILabel *)[cell viewWithTag:30];
        [totalYieldLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        UILabel *totalResultLabel = (UILabel *)[cell viewWithTag:40];
        [totalResultLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        UILabel *winningRatioLabel = (UILabel *)[cell viewWithTag:50];
        [winningRatioLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        UILabel *totalHotTipsValue = (UILabel *)[cell viewWithTag:21];
        [totalHotTipsValue setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        [totalHotTipsValue setText:[_hotTipsHistoryStats totalTips]];
        UILabel *totalYieldValue = (UILabel *)[cell viewWithTag:31];
        [totalYieldValue setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        [totalYieldValue setText:[NSString stringWithFormat:@"%@%%",[_hotTipsHistoryStats totalYield]]];
        UILabel *totalResultValue = (UILabel *)[cell viewWithTag:41];
        [totalResultValue setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        if ([_hotTipsHistoryStats totalResult] > 0)
            [totalResultValue setText:[NSString stringWithFormat:@"+%@", [_hotTipsHistoryStats totalResult]]];
        else
            [totalResultValue setText:[_hotTipsHistoryStats totalResult]];
        UILabel *winningRatioValue = (UILabel *)[cell viewWithTag:51];
        [winningRatioValue setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        [winningRatioValue setText:[NSString stringWithFormat:@"%@%%",[_hotTipsHistoryStats winningPercentage]]];
    }
    
    if (indexPath.section == 1) {
        UILabel *tipsHeaderLabel = (UILabel *)[cell viewWithTag:10];
        [tipsHeaderLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [tipsHeaderLabel setText:@"TIPS"];
    }
    
    if (indexPath.section == 2) {
        UILabel *resultSymbol = (UILabel *)[cell viewWithTag:10];
//        resultSymbol = [[_hotTipsHistoryArray objectAtIndex:indexPath.row] resultSymbol];
        [resultSymbol setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
        [resultSymbol setText:[[_hotTipsHistoryArray objectAtIndex:indexPath.row] resultSymbol]];
        [resultSymbol setTextColor:[UIColor colorWithHexString:[[_hotTipsHistoryArray objectAtIndex:indexPath.row] symbolHexColor]]];
        
//        if(indexPath.row % 2 == 0) {
//            [resultSymbol setTextColor:[UIColor colorWithHexString:@"1ABC9C"]];
//        }
//        else {
//            [resultSymbol setText:[NSString fontAwesomeIconStringForEnum:FATimesCircle]];
//            [resultSymbol setTextColor:[UIColor colorWithHexString:@"E74C3C"]];
//        }
        UILabel *tipTitle = (UILabel *)[cell viewWithTag:11];
        [tipTitle setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [tipTitle setText:[[_hotTipsHistoryArray objectAtIndex:indexPath.row] name]];
        UILabel *selection = (UILabel *)[cell viewWithTag:12];
        [selection setFont:[UIFont fontWithName:@"Lato-Light" size:15]];
        [selection setText:[NSString stringWithFormat:@"%@ @ %@",[[_hotTipsHistoryArray objectAtIndex:indexPath.row] getSelectionString], [[_hotTipsHistoryArray objectAtIndex:indexPath.row] odds]]];
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return 211;
            break;
        case 1:
            return 62;
            break;
        default:
            return 50;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        BCTip *selectedTip = [_hotTipsHistoryArray objectAtIndex:indexPath.row];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[selectedTip externalLink]]];

    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
