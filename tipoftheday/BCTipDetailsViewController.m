//
//  BCTipDetailsViewController.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/14/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCTipDetailsViewController.h"
#import "BCEvent.h"
#import "BCTip.h"
#import "BCLineup.h"
#import "BCInjury.h"
#import "BCHotTipDetailsView.h"
#import "BCHotTipAnalysisViewTableViewCell.h"
#import "BCLineupTableViewController.h"
#import "BCHelpButton.h"
#import "BCBet365Event.h"
#import "BCBet365Market.h"
#import "BCBet365Participant.h"
#import "BCBet365EventGroup.h"

#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+FontAwesome.h"
#import "RKXMLReaderSerialization.h"
#import "MZTimerLabel.h"
#import "HexColor.h"
#import "DDHTimerControl.h"
#import "AMPopTip.h"
#import "NSDate+Utilities.h"
#import "HCObjectSwitch.h"
#import "MONActivityIndicatorView.h"

#import "GAIDictionaryBuilder.h"

@interface BCTipDetailsViewController ()

@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) BCEvent *event;
@property (nonatomic, strong) NSMutableDictionary *offscreenCells;
@property (nonatomic, strong) DDHTimerControl *timerControl;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) RKObjectManager *objectManagerForBet365;
@property (nonatomic, strong) AMPopTip *popTip;
@property (nonatomic, strong) NSArray *bet365EventGroups;
@property (nonatomic, strong) MONActivityIndicatorView *indicatorView;
@property BOOL isEnetpulseAvailable;
@property BOOL isHotTipReleased;
@property BOOL isOddsFormatFraction;

@end

@implementation BCTipDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.offscreenCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.navigationItem setTitle:@"Analysis"];
    [self.navigationItem setTitle:@"Football Tip of The Day"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Lato-Bold" size:17], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontAwesomeFamilyName size:21], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitle:[NSString fontAwesomeIconStringForEnum:FACog]];
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake(5, 0) forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontAwesomeFamilyName size:21], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitle:[NSString fontAwesomeIconStringForEnum:FAlineChart]];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-5, 0) forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.tableView setContentInset:UIEdgeInsetsMake(-65, 0, 0, 0)]; // Hide 65 of the top view (need to pull to reveal the timer)
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
    [self.tableView registerClass:[BCHotTipAnalysisViewTableViewCell class] forCellReuseIdentifier:@"AnalysisCell"];
    
    [[AMPopTip appearance] setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
    _popTip = [AMPopTip popTip];
    
    _indicatorView = [[MONActivityIndicatorView alloc] init];
    _indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-40);
    [self.view addSubview:_indicatorView];
    
//    DEBUG
//    _isEnetpulseAvailable = NO; // Prevent enetpulse data from being downloaded
//    _isEnetpulseAvailable = ([[_hotTipOfTheDay enetpulseEventId] intValue] != 0) ? YES : NO;
    
    NSDate *now = [NSDate date];
    if ([now hour] < 13) {
        self.isHotTipReleased = NO;
        NSLog(@"New hot tip of the day is not yet released.");
        UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
        yourLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,130);
        [yourLabel setTextColor:[UIColor colorWithHexString:@"7F8C8D"]];
        [yourLabel setBackgroundColor:[UIColor clearColor]];
        [yourLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
        [yourLabel setNumberOfLines:4];
        [yourLabel setTextAlignment:NSTextAlignmentCenter];
        [yourLabel setText:@"We carefully handpick our best tip\nfor you everyday. Come back\n in a few hours for another great tip!"];
        [self.view addSubview:yourLabel];
        MZTimerLabel *kickoffTimer = [[MZTimerLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [kickoffTimer setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, 190)];
        [kickoffTimer setTimerType:MZTimerLabelTypeTimer];
        kickoffTimer.timeLabel.font = [UIFont fontWithName:@"Lato-Bold" size:23];
        kickoffTimer.timeLabel.textColor = [UIColor colorWithHexString:@"7F8C8D"];
        [kickoffTimer setCountDownToDate:[now dateByAddingHours:13-[now hour]]];
        [self.view addSubview:kickoffTimer];
        [kickoffTimer start];

    }
    else {
        self.isHotTipReleased = YES;
        [_indicatorView startAnimating];
        [self configureRestKitForBettingexpert];
        [self loadHotTipOfTheDay];
    }

    
    // GA Screen Tracking
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Single Tip Screen"];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.hotTipOfTheDay != nil) {
        BOOL currentOddsFormatFraction = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fractionOdds"] boolValue];
        if (currentOddsFormatFraction != self.isOddsFormatFraction) {
            [self.tableView reloadData];

        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.isOddsFormatFraction = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fractionOdds"] boolValue];
}

#pragma mark - Timer Methods

- (void)valueChanged:(DDHTimerControl*)sender {
//    NSLog(@"value: %d", sender.minutesOrSeconds);
    if (sender.minutesOrSeconds == 0) {
        [self loadEnetpulseData];
    }
}

- (void)changeTimer:(NSTimer*)timer {
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceNow];
//    NSLog(@"timeInterval: %f, minutes: %f", timeInterval, timeInterval/60.0f);
    _timerControl.minutesOrSeconds = ((NSInteger)timeInterval)%60;
}

- (void)setupTimer
{
    //  Timer on top of TableView
    
    if ([[_hotTipOfTheDay getKickOffTime] isToday]) {
        _timerControl = [DDHTimerControl timerControlWithType:DDHTimerTypeSolid];
        _timerControl.translatesAutoresizingMaskIntoConstraints = NO;
        _timerControl.color = [UIColor colorWithHexString:@"444444" alpha:0.2];
        _timerControl.ringWidth = 3;
        _timerControl.minutesOrSeconds = 60;
        _timerControl.userInteractionEnabled = NO;
        UIView *topView = (UIView *)[self.tableView viewWithTag:10];
        _timerControl.frame = CGRectMake(0, 0, 66, 66);
        _timerControl.center = CGPointMake(topView.frame.size.width/2, (topView.frame.size.height-20)/2);
        [_timerControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [topView addSubview:_timerControl];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        _endDate = [NSDate dateWithTimeIntervalSinceNow:12.0f*60.0f];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RestKit Methods

- (void)configureRestKitForBettingexpert
{
    // initialize AFNetworking HTTPClient
    //    RKLogConfigureByName("RestKit", RKLogLevelWarning);
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    //    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    NSURL *baseURL = [NSURL URLWithString:kAPIEndpointHost];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    self.objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
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
                                 self.hotTipOfTheDay = [mappingResult firstObject];
//                                 if (![_indicatorView isHidden])
//                                     [_indicatorView stopAnimating];
//                                 [refreshControl endRefreshing];
                                 if ([[self.hotTipOfTheDay getKickOffTime] isToday]) {
                                     [self configureRestKitForEnetpulse];
                                     [self loadEnetpulseData];
                                     
                                     [self configureRestKitForBet365];
                                     [self loadBet365Data];
                                     
                                     [self setupTimer];
                                 }
                                 
                                 if (![_indicatorView isHidden])
                                     [_indicatorView stopAnimating];
                                 [self.tableView reloadData];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
                                 //                                ERROR : CHECK FOR "NO TIP FOUND" VALUE
//                                 if (![_indicatorView isHidden])
//                                     [_indicatorView stopAnimating];
//                                 [refreshControl endRefreshing];
//                                 CWStatusBarNotification *notification = [CWStatusBarNotification new];
//                                 notification.notificationLabelBackgroundColor = [UIColor colorWithHexString:@"#c0392b"];
//                                 notification.notificationLabelTextColor = [UIColor whiteColor];
//                                 [notification displayNotificationWithMessage:@"Please check your network connection and try again."
//                                                                  forDuration:3.0f];
                             }];
}

- (void)configureRestKitForEnetpulse
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"http://spocosyodds.enetpulse.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    
    // setup object mappings
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[BCEvent class]];
    [eventMapping addAttributeMappingsFromDictionary:@{
                                                      @"status_type" : @"statusType",
                                                      @"name" : @"name",
                                                      @"properties.LineupConfirmed": @"lineupConfirmed"
                                                      }];
    
    RKObjectMapping *teamMapping = [RKObjectMapping mappingForClass:[BCTeam class]];
    [teamMapping addAttributeMappingsFromDictionary:@{
                                                      @"number" : @"number",
                                                      @"results.result": @"liveScores",
                                                      @"properties.property" : @"properties",
                                                      @"participant.name" : @"name",
                                                      @"participant.countryFK" : @"countryFK"
                                                      }];
    
    RKObjectMapping *lineupMapping = [RKObjectMapping mappingForClass:[BCLineup class]];
    [lineupMapping addAttributeMappingsFromDictionary:@{
                                                        @"pos": @"position",
                                                        @"shirt_number": @"shirtNumber",
                                                        @"participant.name": @"name",
                                                        @"participant.countryFK": @"countryFK",
                                                        @"participant.type": @"type"
                                                        }];

    
    [teamMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"lineups.lineup"
                                                                                           toKeyPath:@"lineups"
                                                                                          withMapping:lineupMapping]]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:teamMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"spocosy.query-response.event.event_participant"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManager addResponseDescriptor:responseDescriptor];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *eventResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:eventMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"spocosy.query-response.event"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManager addResponseDescriptor:eventResponseDescriptor];
    
}
- (void)loadEnetpulseData
{
    [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"/xmlservice/xmlservice.php?service=livestats&usr=chrisper&pwd=PieQTRlRyP&includeProperties=1&includeDebug=0&datecmd=none&defaultLang=&languageids=3&eventids=%d&stageids=&resolveParticipants=1&includeAllEventData=1&includeAllLivestatsData=1", [[_hotTipOfTheDay enetpulseEventId] intValue]]
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 NSDictionary *results = [mappingResult dictionary];
//                                 NSLog(@"Results: %@", results);
                                 self.event = [results objectForKey:@"spocosy.query-response.event"];
                                 NSLog(@"Event Status: %@", [self.event statusType]);
                                 self.teams = [results objectForKey:@"spocosy.query-response.event.event_participant"];
//                                 _teams = mappingResult.array;
                                 // We need to make sure the first team in our array is the team playing at home (will be easier to deal with teams later)
                                 NSSortDescriptor *sortDescriptor;
                                 sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
                                 NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                                 self.teams = [self.teams sortedArrayUsingDescriptors:sortDescriptors];
                                 [self.tableView reloadData];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
                             }];
}

- (void)configureRestKitForBet365
{
//    http://www.valuecalculator.com.gridhosted.co.uk/feed.xml
    
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"http://www.valuecalculator.com.gridhosted.co.uk"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    _objectManagerForBet365 = [[RKObjectManager alloc] initWithHTTPClient:client];
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    
    // setup object mapping
    RKObjectMapping *eventGroupMapping = [RKObjectMapping mappingForClass:[BCBet365EventGroup class]];
    [eventGroupMapping addAttributeMappingsFromDictionary:@{
                                                       @"Name" : @"name",
                                                       @"ID": @"identifier"
                                                       }];
    
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[BCBet365Event class]];
    [eventMapping addAttributeMappingsFromDictionary:@{
                                                      @"Name" : @"name",
                                                      @"ID": @"identifier",
                                                      @"StartTime" : @"startTime"
                                                      }];
    
    RKObjectMapping *marketMapping = [RKObjectMapping mappingForClass:[BCBet365Market class]];
    [marketMapping addAttributeMappingsFromDictionary:@{
                                                        @"Name": @"name",
                                                        @"ID": @"identifier"
                                                        }];
    
    RKObjectMapping *participantMapping = [RKObjectMapping mappingForClass:[BCBet365Participant class]];
    [participantMapping addAttributeMappingsFromDictionary:@{
                                                        @"Name": @"name",
                                                        @"Odds": @"fractionOdds",
                                                        @"OddsDecimal": @"decimalOdds",
                                                        @"Handicap": @"handicap",
                                                        @"ID": @"identifier"
                                                        }];
    
    [eventGroupMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"Event"
                                                                                             toKeyPath:@"events"
                                                                                           withMapping:eventMapping]]];
    
    [eventMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"Market"
                                                                                            toKeyPath:@"markets"
                                                                                          withMapping:marketMapping]]];
    
    [marketMapping addPropertyMappingsFromArray:@[[RKRelationshipMapping relationshipMappingFromKeyPath:@"Participant"
                                                                                             toKeyPath:@"participants"
                                                                                           withMapping:participantMapping]]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:eventGroupMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"Sport.EventGroup"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManagerForBet365 addResponseDescriptor:responseDescriptor];
}

- (void)loadBet365Data
{
    __block NSString *apiEndPoint;
    
    Switch ([_hotTipOfTheDay betType])
    {
        Case (@"ah")
        {
            apiEndPoint = @"/alternative-ah-feed.xml";
        },
        
        Case (@"ou")
        {
            apiEndPoint = @"/goal-line-feed.xml";
        },
        Case (@"bts")
        {
            apiEndPoint = @"/btts-feed.xml";
        },
        Default
        {
            apiEndPoint = @"/feed.xml";
        },
    };
    
//    DEBUG
//    apiEndPoint = @"/feed.xml";
    
    [_objectManagerForBet365 getObjectsAtPath:apiEndPoint
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 _bet365EventGroups = mappingResult.array;
                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
                             }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hotTipOfTheDay != nil && self.isHotTipReleased == YES)
        return 7;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if (_isEnetpulseAvailable) {
        if (section == 4)
            return 2;
        else
            return 1;
//    }
//    else {
//        if (section == 3 || section == 4)
//            return 0;
//        else
//            return 1;
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithHexString:@"#F6F7F7"];
//
//    if (indexPath.section == 0) {
//        BCHelpButton *selectionHelpButton = (BCHelpButton *)[cell viewWithTag:36];
//        selectionHelpButton.frame = [self getFrameForHelpButton:selectionHelpButton fromSurroudingLabelWithText:[_hotTipOfTheDay getSelectionString] withFont:[UIFont fontWithName:@"Lato-Regular" size:16] andOffset:270];
//        
//        BCHelpButton *oddsHelpButton = (BCHelpButton *)[cell viewWithTag:37];
//        oddsHelpButton.frame = [self getFrameForHelpButton:oddsHelpButton fromSurroudingLabelWithText:[[_hotTipOfTheDay odds] stringValue] withFont:[UIFont fontWithName:@"Lato-Regular" size:16] andOffset:270];
//    }
////    cell.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#F6F7F7"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    NSLog(@"indexPath.section being rendered: %ld", (long)indexPath.section);
    
    static NSString *TipCellIdentifier = @"TipCell";
    static NSString *BetNowButtonCellIdentifier = @"BetNowCell";
    static NSString *MoreTipsCellIdentifier = @"MoreTipsCell";
    static NSString *AnalysisCellIdentifier = @"AnalysisCell";
    static NSString *LineupHeaderCellIdentifier = @"LineupHeaderCell";
    static NSString *LineupCellIdentifier = @"LineupCell";
    static NSString *FooterCellIdentifier = @"FooterCell";
    
    id cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:TipCellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        BCHotTipDetailsView* tipBackgroundView = [[BCHotTipDetailsView alloc] init];
        [tipBackgroundView setBackgroundColor:[UIColor clearColor]];
        ([[self.event statusType] isEqualToString:@"inprogress"]) ? [tipBackgroundView setIsLive:YES] : [tipBackgroundView setIsLive:NO];
        [cell setBackgroundView:tipBackgroundView];
        
        UILabel *liveScore = (UILabel *)[cell viewWithTag:24];
        if ([tipBackgroundView isLive])
            [liveScore setText:@"LIVE"];
        else if ([[self.event statusType] isEqualToString:@"finished"])
            [liveScore setText:@"Finished"];
        else if ([[self.event statusType] isEqualToString:@"notstarted"])
            [liveScore setText:@""]; // Do not display the liveScore label
        
        UILabel *leagueName = (UILabel *)[cell viewWithTag:22];
        [leagueName setText:[_hotTipOfTheDay leagueName]];
        [leagueName setFont:[UIFont fontWithName:@"Lato-Bold" size:15]];
        UILabel *tipsterName = (UILabel *)[cell viewWithTag:25];
        [tipsterName setText:[NSString stringWithFormat:@"Written by %@", [[_hotTipOfTheDay tipster] username]]];
        [tipsterName setFont:[UIFont fontWithName:@"Lato-Regular" size:13]];
        
        UILabel *versusLabel = (UILabel *)[cell viewWithTag:23];
        [versusLabel setFont:[UIFont fontWithName:@"Lato-Black" size:18]];
        
        UIImageView *homeTeamLogo = (UIImageView *)[cell viewWithTag:10];
        UIImageView *awayTeamLogo = (UIImageView *)[cell viewWithTag:11];
        [homeTeamLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [awayTeamLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [homeTeamLogo sd_setImageWithURL:[NSURL URLWithString:[[[_hotTipOfTheDay teams] firstObject] logoUrl]]
                        placeholderImage:[UIImage imageNamed:@"teamlogo-placeholder"]];
        [awayTeamLogo sd_setImageWithURL:[NSURL URLWithString:[[[_hotTipOfTheDay teams] lastObject] logoUrl]]
                        placeholderImage:[UIImage imageNamed:@"teamlogo-placeholder"]];
        
        UILabel *homeTeamName = (UILabel *)[cell viewWithTag:20];
        UILabel *awayTeamName = (UILabel *)[cell viewWithTag:21];
        [homeTeamName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [awayTeamName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [homeTeamName setText:[[[_hotTipOfTheDay teams] firstObject] name]];
        [awayTeamName setText:[[[_hotTipOfTheDay teams] lastObject] name]];
        
        UILabel *bookmakerLabel = (UILabel *)[cell viewWithTag:30];
        [bookmakerLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        UILabel *selectionLabel = (UILabel *)[cell viewWithTag:31];
        [selectionLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        UILabel *oddsLabel = (UILabel *)[cell viewWithTag:32];
        [oddsLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        UILabel *selectionValue = (UILabel *)[cell viewWithTag:33];
        [selectionValue setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [selectionValue setText:[_hotTipOfTheDay getSelectionString]];
        UILabel *oddsValue = (UILabel *)[cell viewWithTag:34];
        [oddsValue setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [[[NSUserDefaults standardUserDefaults] valueForKey:@"fractionOdds"] boolValue] ? [oddsValue setText:[_hotTipOfTheDay fractionOdds]] : [oddsValue setText:[[_hotTipOfTheDay odds] stringValue]];
        UIImageView *bookmakerLogo = (UIImageView *)[cell viewWithTag:35];
        [bookmakerLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [bookmakerLogo sd_setImageWithURL:[NSURL URLWithString:[[_hotTipOfTheDay bookmaker] logoUrl]]
                         placeholderImage:nil];
        
//        ((BCHotTipDetailTableViewCell *)cell).oddsHelp = (BCHelpButton *)[cell viewWithTag:36];
//        ((BCHotTipDetailTableViewCell *)cell).selectionHelp = (BCHelpButton *)[cell viewWithTag:37];
        
//        [((BCHotTipDetailTableViewCell *)cell).oddsHelp setFrame:[self getFrameForHelpButton:((BCHotTipDetailTableViewCell *)cell).oddsHelp fromSurroudingLabel:selectionValue withFont:[UIFont fontWithName:@"Lato-Regular" size:16] andOffset:270]];
////        [selectionHelpButton setHidden:NO];
//        selectionHelpButton.frame = [self getFrameForHelpButton:selectionHelpButton fromSurroudingLabel:selectionValue withFont:[UIFont fontWithName:@"Lato-Regular" size:16] andOffset:270];
//        
//        BCHelpButton *oddsHelpButton = (BCHelpButton *)[cell viewWithTag:37];
//
////        [oddsHelpButton setHidden:NO];
//        oddsHelpButton.frame = [self getFrameForHelpButton:oddsHelpButton fromSurroudingLabel:oddsValue withFont:[UIFont fontWithName:@"Lato-Regular" size:16] andOffset:270];
        
        if ([self.hotTipOfTheDay getKickOffTime] != nil && [self.event statusType] != nil) {
//            Debug kickofftime
//            NSLog(@"Kickoff time : %@", [_hotTipOfTheDay getKickOffTime]);
            if ([[self.hotTipOfTheDay getKickOffTime] isInFuture]) {
                MZTimerLabel *kickoffTimer = (MZTimerLabel *)[cell viewWithTag:24];
                [kickoffTimer setTimerType:MZTimerLabelTypeTimer];
                kickoffTimer.timeLabel.font = [UIFont fontWithName:@"Lato-Bold" size:23];
                kickoffTimer.timeLabel.textColor = [UIColor whiteColor];
                [kickoffTimer setCountDownToDate:[_hotTipOfTheDay getKickOffTime]];
                [kickoffTimer start];
            }
            else {
//                UILabel *liveScore = (UILabel *)[cell viewWithTag:24];
                liveScore.font = [UIFont fontWithName:@"Lato-Bold" size:23];
                liveScore.textColor = [UIColor whiteColor];
                if ([[[[_teams firstObject] liveScores] objectAtIndex:1] valueForKey:@"value"] != nil)
                    [liveScore setText:[self getLiveScore]];
//                else
//                    [liveScore setText:@"LIVE"];
            }
        }
    }
    else if (indexPath.section == 1)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:BetNowButtonCellIdentifier forIndexPath:indexPath];
        UIButton *betNowAtBet365 = (UIButton *)[cell viewWithTag:10];
        [betNowAtBet365.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18]];
        [betNowAtBet365 setTitle:@"Bet now at bet365" forState:UIControlStateNormal];
        if ([_bet365EventGroups count] != 0)
            [betNowAtBet365 setEnabled:YES];
        else
            [betNowAtBet365 setEnabled:NO];
    }
    else if (indexPath.section == 2)
    {
        cell = (BCHotTipAnalysisViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AnalysisCellIdentifier forIndexPath:indexPath];
        [cell updateFonts];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        ((BCHotTipAnalysisViewTableViewCell *)cell).titleLabel.text = @"FULL ANALYSIS";
        ((BCHotTipAnalysisViewTableViewCell *)cell).bodyLabel.text = [[[NSAttributedString alloc] initWithData:[[_hotTipOfTheDay fullAnalysis] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil] string];
        UIView *upperBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        upperBorder.backgroundColor = [UIColor colorWithHexString:@"DFDFDF"];
        UIView *lowerBorder = [[UIView alloc] initWithFrame:CGRectMake(0, ((BCHotTipAnalysisViewTableViewCell *) cell).bounds.size.height-1, 320, 1)];
        lowerBorder.backgroundColor = [UIColor colorWithHexString:@"DFDFDF"];
        [((BCHotTipAnalysisViewTableViewCell *)cell).contentView addSubview:upperBorder];
        [((BCHotTipAnalysisViewTableViewCell *)cell).contentView addSubview:lowerBorder];
    }
    else if (indexPath.section == 3)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:LineupHeaderCellIdentifier forIndexPath:indexPath];
        UILabel *headerLabel = (UILabel *)[cell viewWithTag:10];
        [headerLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [headerLabel setText:@"LINEUPS"];
    }
    else if (indexPath.section == 4)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:LineupCellIdentifier forIndexPath:indexPath];
        UILabel *teamLabel = (UILabel *)[cell viewWithTag:10];
        [teamLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        if (indexPath.row == 0)
            [teamLabel setText:[[[_hotTipOfTheDay teams] firstObject] name]];
        else
            [teamLabel setText:[[[_hotTipOfTheDay teams] lastObject] name]];
    }
    else if (indexPath.section == 5)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MoreTipsCellIdentifier forIndexPath:indexPath];
        UIButton *moreTipsButton = (UIButton *)[cell viewWithTag:10];
        [moreTipsButton.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18]];
        [moreTipsButton setTitle:@"More tips in this league" forState:UIControlStateNormal];
    }
    else
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:FooterCellIdentifier forIndexPath:indexPath];
        UILabel *footerLabel = (UILabel *)[cell viewWithTag:10];
        [footerLabel setFont:[UIFont fontWithName:@"Lato-Light" size:17]];
        [footerLabel setNumberOfLines:4];
        [footerLabel setText:@"This tip is provided by bettingexpert. Sign up for free to access more than 75,000 tips\nevery month."];
        UIButton *goToWebsite = (UIButton *)[cell viewWithTag:20];
        [goToWebsite setBackgroundColor:[UIColor colorWithHexString:@"3ABF50"]];
        [goToWebsite setTintColor:[UIColor whiteColor]];
        [goToWebsite.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18]];
        [goToWebsite setTitle:@"Sign up" forState:UIControlStateNormal];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"AnalysisCell";
    switch (indexPath.section)
    {
        case 0:
            return 354;
            break;
            
        case 1:
        case 5:
            return 100;
            break;
            
        case 2:
        {
            BCHotTipAnalysisViewTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
            if (!cell) {
                cell = [[BCHotTipAnalysisViewTableViewCell alloc] init];
                [self.offscreenCells setObject:cell forKey:reuseIdentifier];
            }
            
            [cell.titleLabel setText:@"FULL ANALYSIS"];
            [cell.bodyLabel setText:[_hotTipOfTheDay fullAnalysis]];
            
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            
            cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            height += 1.0f;
            
            return height;

        }
            break;
            
        case 3:
            return 70;
            break;
            
        case 6:
            return 185;
            break;
            
        default:
            return 44;
            break;
    }
}

#pragma mark - Table view delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_popTip isVisible])
        [_popTip hide];
}

#pragma mark - Enetpulse data

- (NSString *)getLiveScore {
    return [NSString stringWithFormat:@"%@ - %@", [[[[_teams firstObject] liveScores] objectAtIndex:1] valueForKey:@"value"], [[[[_teams lastObject] liveScores] objectAtIndex:1] valueForKey:@"value"]];
}

#pragma mark - Controller methods

- (IBAction)goToBookmaker:(id)sender {
    [OtherLevels registerEvent:@"External link"
                         label:[[_hotTipOfTheDay bookmaker] affiliateLink]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"External link"     // Event category (required)
                                                          action:@"Button"  // Event action (required)
                                                           label:[NSString stringWithFormat:@"Affiliate link to: %@", [[_hotTipOfTheDay bookmaker] name]]    // Event label
                                                           value:nil] build]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[_hotTipOfTheDay bookmaker] affiliateLink]]];
}

- (IBAction)goToBet365:(id)sender {
    [OtherLevels registerEvent:@"External link"
                         label:@"Watch live at bet365 (single tip)"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"External link"     // Event category (required)
                                                          action:@"Button"  // Event action (required)
                                                           label:@"Watch live at bet365 (single tip)"    // Event label
                                                           value:nil] build]];
    
    NSString *affiliateLink = @"http://www.bettingexpert.com/goto/bet365";
    NSString *bet365ParticipantId = [self getBet365ParticipantId];
    
    if ([bet365ParticipantId length] != 0) { // If we have a bet365 event for this tip, then, better use it!
        affiliateLink = [NSString stringWithFormat:@"http://www.bet365.com/instantbet/default.asp?participantid=%@&affiliatecode=365_323635&odds=%.3f&Instantbet=1", bet365ParticipantId, [[_hotTipOfTheDay odds] floatValue]];
        NSLog(@"Bet365 link : %@", affiliateLink);
    }
    
    else
        NSLog(@"No Bet365 link found!");
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]];

}

- (IBAction)signupToBettingexpert:(id)sender {
    [OtherLevels registerEvent:@"External link"
                         label:@"Signup page"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"External link"     // Event category (required)
                                                          action:@"Button"  // Event action (required)
                                                           label:@"Signup page"    // Event label
                                                           value:nil] build]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.bettingexpert.com/user/register"]]];
}

- (IBAction)goToBettingexpert:(id)sender {
    [OtherLevels registerEvent:@"External link"
                         label:@"More tips for this league"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"External link"     // Event category (required)
                                                          action:@"Button"  // Event action (required)
                                                           label:@"More tips for this league"    // Event label
                                                           value:nil] build]];
    
    NSString *leagueName = [[[_hotTipOfTheDay leagueName] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *countryName = [[[_hotTipOfTheDay countryName] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
//    Should maybe check for device language and add it to the bettingexpert link in order to have the translated version of the website
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.bettingexpert.com/tips/football/%@/%@", countryName, leagueName]]];
}

- (IBAction)actionButton:(UIButton *)sender
{
    [_popTip hide];
    
    if ([_popTip isVisible]) {
        return;
    }
    
    CGRect buttonFrame = sender.frame;
    buttonFrame.origin.y = buttonFrame.origin.y+95;
    NSString *buttonText = [NSString string];
    
    self.popTip.popoverColor = [UIColor colorWithHexString:@"006bb3"];
    
//    
//    TEMP - SHOULD MAYBE WRITE THIS IN A DATABASE
//
    int direction = 0;
    if (sender.tag == 36) {
        switch ([[_hotTipOfTheDay selectionType] intValue]) {
            case 1:
            {
                if ([[_hotTipOfTheDay betType] isEqualToString:@"1x2"])
                    buttonText = @"The home team has to win.";
                else if ([[_hotTipOfTheDay betType] isEqualToString:@"ah"])
                    buttonText = [NSString stringWithFormat:@"The home team needs to keep an advantage of %d goals to win.", abs([[_hotTipOfTheDay handicap] intValue])+1];
                else if ([[_hotTipOfTheDay betType] isEqualToString:@"dnb"])
                    buttonText = @"The home team has to win. If it's a draw, this bet will be voided.";
            }
                break;
            case 2:
                buttonText = @"You need a draw to win this bet.";
                break;
            case 3:
            {
                if ([[_hotTipOfTheDay betType] isEqualToString:@"1x2"])
                    buttonText = @"The away team has to win.";
                else if ([[_hotTipOfTheDay betType] isEqualToString:@"ah"])
                    buttonText = [NSString stringWithFormat:@"The away team needs to keep an advantage of %d goals to win.", abs([[_hotTipOfTheDay handicap] intValue])+1];
                else if ([[_hotTipOfTheDay betType] isEqualToString:@"dnb"])
                    buttonText = @"The away team has to win. If it's a draw, this bet will be voided.";
            }
                break;
                
            case 4:
            case 5:
            {
                NSString *selectionOU = ([[_hotTipOfTheDay selectionType] intValue] == 4) ? @"less" : @"more";
                int valueOU = ([[_hotTipOfTheDay selectionType] intValue] == 4) ? [[_hotTipOfTheDay goals] intValue] : [[_hotTipOfTheDay goals] intValue]+1;
                int goals = [[_hotTipOfTheDay goals] intValue];
                if ([[_hotTipOfTheDay goals] intValue] == [[_hotTipOfTheDay goals] floatValue])
                    buttonText = [NSString stringWithFormat:@"You need %@ than %d goals to win this bet. If there is exactly %d goals, this bet will be voided.", selectionOU, goals, goals];
                else
                    buttonText = [NSString stringWithFormat:@"You need %@ than %.1f goals to win this bet (i.e., in this case you need %d goals).", selectionOU, [[_hotTipOfTheDay goals] floatValue], valueOU];
            }
                break;
                
            case 10:
                buttonText = @"Both team have to score.";
                break;
            case 11:
                buttonText = @"One of the team should not score.";
                break;
                
            default:
                break;
        }
    }
    else if (sender.tag == 37) {
        buttonText = [NSString stringWithFormat:@"Implied probability: %.1f%%", (100/[[_hotTipOfTheDay odds] floatValue])];
        direction = 3;
    }
    
    [self.popTip showText:buttonText direction:direction maxWidth:200 inView:self.view fromFrame:buttonFrame];

}

//- (CGRect)getFrameForHelpButton:(UIButton *)button fromSurroudingLabelWithText:(NSString *)labelText withFont:(UIFont *)font andOffset:(float)offset
//{
//    CGSize constraint = CGSizeMake(300,300);
//    
//    NSDictionary *attributes = @{NSFontAttributeName: font};
//    
//    CGRect rect = [labelText boundingRectWithSize:constraint
//                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                                 attributes:attributes
//                                                    context:nil];
//    
//    return CGRectMake(offset-rect.size.width, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
//}

- (NSString *)getBet365ParticipantId
{
    NSString *returnValue;
    NSString *bet365EventName = [NSString stringWithFormat:@"%@ v %@", [[[_hotTipOfTheDay teams] firstObject] name], [[[_hotTipOfTheDay teams] lastObject] name]];
    for (BCBet365EventGroup *eventGroup in _bet365EventGroups) {
        for (BCBet365Event *event in [eventGroup events]) {
            if ([[event name] isEqualToString:bet365EventName]) {
                // Found it! We need to extract the identifier corresponding to the selection of the tip and we're good to go :)
                NSLog(@"FOUND IT!");
                switch ([[_hotTipOfTheDay selectionType] intValue]) {
                    case 1:
                    case 2:
                    case 3:
                    {
                        if ([[_hotTipOfTheDay betType] isEqualToString:@"1x2"])
                            // 1x2 market
                            returnValue = [[[[[event markets] firstObject] participants] objectAtIndex:[[_hotTipOfTheDay selectionType] intValue]-1] identifier];
                        else if ([[_hotTipOfTheDay betType] isEqualToString:@"ah"]) {
                            // Asian handicap market
                            int index = 0;
                            BOOL shouldNotBeOdd = FALSE;
                            if ([[_hotTipOfTheDay selectionType] intValue] == 3)
                                shouldNotBeOdd = TRUE;
                            for (BCBet365Participant *participant in [[[event markets] firstObject] participants]) {
                                if ((index % 2 == shouldNotBeOdd) && ([[participant handicap] floatValue] == [[_hotTipOfTheDay handicap] floatValue])) {
                                    returnValue = [[participant identifier] stringValue];
                                }
                                index++;
                            }
                        }
                    }
                        break;
                    case 4:
                    case 5:
                    {
                        // over/under market
                        returnValue = [[[[[event markets] firstObject] participants] objectAtIndex:abs([[_hotTipOfTheDay selectionType] intValue]-5)] identifier];
                    }
                    case 10:
                    case 11:
                    {
                        // BTTS market
                        returnValue = [[[[[event markets] firstObject] participants] objectAtIndex:[[_hotTipOfTheDay selectionType] intValue]-10] identifier];
                    }
                    default:
                        break;
                }
                NSLog(@"ID for this selection: %@", returnValue);
            }
        }
    }
    return returnValue;
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


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showLineup"] && [_teams count] > 0)
        return YES;
    else if ([identifier isEqualToString:@"showSettings"] || [identifier isEqualToString:@"showTipsHistory"])
        return YES;
    else
        return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showLineup"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        [[_teams objectAtIndex:selectedRowIndex.row] setLogoUrl:[[[_hotTipOfTheDay teams] objectAtIndex:selectedRowIndex.row] logoUrl]];
        [[segue destinationViewController] setSelectedTeam:[_teams objectAtIndex:selectedRowIndex.row]];
        [[segue destinationViewController] setEvent:self.event];
    }
}

#pragma mark - Touches Events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_popTip hide];
}


@end
