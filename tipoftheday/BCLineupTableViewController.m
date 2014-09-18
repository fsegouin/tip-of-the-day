//
//  BCLineupTableViewController.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/18/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCLineupTableViewController.h"
#import "BCLineup.h"
#import "BCInjury.h"
#import "BCSoccerFieldView.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <RestKit/RestKit.h>
#import "RKXMLReaderSerialization.h"
#import "HexColor.h"
#import "NSString+FontAwesome.h"

@interface BCLineupTableViewController ()

@property (nonatomic, strong) RKObjectManager *objectManager;

@end

@implementation BCLineupTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationItem setTitle:[_selectedTeam name]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)]; // 30px from top
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
    
    [self configureRestKit];
    [self loadDataFromXmlSportsFeed];
    
    // GA Screen Tracking
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Lineup Screen"];
    
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
    NSURL *baseURL = [NSURL URLWithString:@"http://xml-sportsfeeds.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    
    // setup object mappings
    
    RKObjectMapping *injuriesMapping = [RKObjectMapping mappingForClass:[BCInjury class]];
    [injuriesMapping addAttributeMappingsFromDictionary:@{
                                                          @"player_name": @"playerName",
                                                          @"player_country_id": @"playerCountry",
                                                          @"injury": @"status",
                                                          @"expected_return": @"expectedReturn"
                                                          }];
    
    RKObjectMapping *suspensionsMapping = [RKObjectMapping mappingForClass:[BCInjury class]];
    [suspensionsMapping addAttributeMappingsFromDictionary:@{
                                                          @"player_name": @"playerName",
                                                          @"player_country_id": @"playerCountry",
                                                          @"charge": @"status",
                                                          @"expected_return": @"expectedReturn"
                                                          }];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:injuriesMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"xml.Injuries.Injury"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKResponseDescriptor *responseDescriptor2 =
    [RKResponseDescriptor responseDescriptorWithMapping:suspensionsMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"xml.Suspensions.Suspension"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    [_objectManager addResponseDescriptor:responseDescriptor2];
    
}

- (void)loadDataFromXmlSportsFeed
{
    NSString *teamName = [[[_selectedTeam name] uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    //    Debug purposes
    teamName = @"PARIS-SAINT-GERMAIN";
    
    [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"/xml/all/injuries/?key=E46AJP2Z&language=en&timestamp=0&status=live&club=%@", teamName]
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 [_selectedTeam setInjuries:mappingResult.array];
                                 [self.tableView reloadData];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
                             }];
    
    
    [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"/xml/all/suspensions/?key=E46AJP2Z&language=en&timestamp=0&status=live&club=%@", teamName]
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 [_selectedTeam setSuspensions:mappingResult.array];
                                 [self.tableView reloadData];
                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"What do you mean by 'there is an error?': %@", error);
                             }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    int howManySections = 6;
//    if ([[_selectedTeam substitutes] count] > 0)
//        howManySections++;
    if ([[_selectedTeam injuries] count] > 0)
        howManySections = howManySections+2;
    if ([[_selectedTeam suspensions] count] > 0)
        howManySections = howManySections+2;
    return howManySections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 3)
        return [[_selectedTeam lineups] count];
    if (section == 4 && [[_selectedTeam substitutes] count] == 0)
        return 0;
    else if (section == 5)
        return [[_selectedTeam substitutes] count];
    if (section == 6 && [[_selectedTeam injuries] count] == 0)
        return 0;
    else if (section == 7)
        return [[_selectedTeam injuries] count];
    if (section == 8 && [[_selectedTeam suspensions] count] == 0)
        return 0;
    else if (section == 9)
        return [[_selectedTeam suspensions] count];
    else
        return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 || indexPath.section == 5 || indexPath.section == 7 || indexPath.section == 9) {
        if(indexPath.row % 2 == 0)
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F6F7F7"];
        else
            cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...

    static NSString *TeamNameHeaderCellIdentifier = @"TeamNameHeaderCell";
    static NSString *SoccerFieldCellIdentifier = @"SoccerFieldCell";
    static NSString *HeaderCellIdentifier = @"HeaderCell";
    static NSString *LineupCellIdentifier = @"LineupCell";
    static NSString *InjuryCellIdentifier = @"InjuryCell";
    
    
    NSString *cellIdentifier;
    
    switch (indexPath.section) {
        case 0:
            cellIdentifier = TeamNameHeaderCellIdentifier;
            break;
        case 1:
            cellIdentifier = SoccerFieldCellIdentifier;
            break;
        case 2:
        case 4:
        case 6:
        case 8:
            cellIdentifier = HeaderCellIdentifier;
            break;
        case 3:
        case 5:
            cellIdentifier = LineupCellIdentifier;
            break;
        case 7:
        case 9:
            cellIdentifier = InjuryCellIdentifier;
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamNameHeaderCellIdentifier forIndexPath:indexPath];
        
        UILabel *teamName = (UILabel *)[cell viewWithTag:10];
        [teamName setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
        [teamName setText:[[_selectedTeam name] uppercaseString]];
        
        UIImageView *teamLogo = (UIImageView *)[cell viewWithTag:11];
        [teamLogo.layer setMinificationFilter:kCAFilterTrilinear];
        [teamLogo sd_setImageWithURL:[NSURL URLWithString:[_selectedTeam logoUrl]]
                    placeholderImage:[UIImage imageNamed:@"teamlogo-placeholder"]];
    }
    
    else if (indexPath.section == 1) {
//        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:SoccerFieldCellIdentifier forIndexPath:indexPath];
        BCSoccerFieldView *soccerFieldView = [[BCSoccerFieldView alloc] init];
        [soccerFieldView setPlayers:[_selectedTeam lineups]];
        [soccerFieldView setBackgroundColor:[UIColor colorWithHexString:@"F6F7F7"]];
        [cell setBackgroundView:soccerFieldView];
    }
    
    else if (indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 6 || indexPath.section == 8) {
        UILabel *headerLabel = (UILabel *)[cell viewWithTag:10];
        [headerLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        switch (indexPath.section) {
            case 2:
                if ([[_selectedTeam getTeamFormationString] length] != 0)
                    [headerLabel setText:[NSString stringWithFormat:@"LINEUP (%@)", [_selectedTeam getTeamFormationString]]];
                else
                    [headerLabel setText:@"LINEUP"];
                break;
            case 4:
                [headerLabel setText:@"SUBSTITUTES"];
                break;
            case 6:
                [headerLabel setText:@"INJURIES"];
                break;
            case 8:
                [headerLabel setText:@"SUSPENSIONS"];
                break;
            default:
                break;
        }
    }
    
    else if (indexPath.section == 3 || indexPath.section == 5) {
        BCLineup *player = [[BCLineup alloc] init];
        
        if (indexPath.section == 3)
            player = [[_selectedTeam lineups] objectAtIndex:indexPath.row];
        else
            player = [[_selectedTeam substitutes] objectAtIndex:indexPath.row];
        
        UILabel *shirtNumber = (UILabel *)[cell viewWithTag:10];
        [shirtNumber setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
        [shirtNumber setText:[player shirtNumber]];
        
        if ([[player shirtNumber] intValue] == 0)
            [shirtNumber setHidden:YES];
        else
            [shirtNumber setHidden:NO];
        
        UILabel *playerName = (UILabel *)[cell viewWithTag:11];
        [playerName setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [playerName setText:[player name]];
        
        UILabel *position = (UILabel *)[cell viewWithTag:12];
        [position setFont:[UIFont fontWithName:@"Lato-Light" size:15]];
        [position setText:[player getStringPositionFromPositionNumber]];
    }
    
    else if (indexPath.section == 7 || indexPath.section == 9) {
        BCInjury *player = [[BCInjury alloc] init];

        if (indexPath.section == 7)
            player = [[_selectedTeam injuries] objectAtIndex:indexPath.row];
        else
            player = [[_selectedTeam suspensions] objectAtIndex:indexPath.row];
        
        UILabel *symbol = (UILabel *)[cell viewWithTag:10];
        [symbol setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
        if (indexPath.section == 7)
            [symbol setText:[NSString fontAwesomeIconStringForEnum:FAMedkit]];
        else
            [symbol setText:[NSString fontAwesomeIconStringForEnum:FAExclamationTriangle]];
        
        UILabel *playerName = (UILabel *)[cell viewWithTag:11];
        [playerName setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [playerName setText:[player playerName]];
        
        UILabel *position = (UILabel *)[cell viewWithTag:12];
        [position setFont:[UIFont fontWithName:@"Lato-Light" size:15]];
        [position setText:[player status]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
            return 200;
            break;
        case 3:
        case 5:
        case 7:
        case 9:
            return 50;
            break;
        default:
            return 44;
            break;
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
