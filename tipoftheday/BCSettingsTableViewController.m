//
//  BCSettingsTableViewController.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/21/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCSettingsTableViewController.h"

#import "HexColor.h"

@interface BCSettingsTableViewController ()

@property (nonatomic, strong) NSIndexPath* checkedIndexPath;
@property BOOL isFractionOddsEnabled;
@property BOOL isPushNotificationsEnabled;

@end

@implementation BCSettingsTableViewController

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
    
    [self.navigationItem setTitle:@"Settings"];
    _isFractionOddsEnabled = [[self readFromUserDefaultsforKey:@"fractionOdds"] boolValue];
//    _isPushNotificationsEnabled = [[self readFromUserDefaultsforKey:@"pushNotifications"] boolValue];
    
    // GA Screen Tracking
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Settings Screen"];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)readFromUserDefaultsforKey:(NSString *)key {
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Data read");
    return [defaults valueForKey:key];
}

- (void)saveToUserDefaultsWithValue:(id)value forKey:(NSString *)key {
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
    NSLog(@"Data saved");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
//    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if (section == 0)
        return 2;
//    else
//        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
//    [cell.textLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
//    [cell.textLabel setTextColor:[UIColor colorWithHexString:@"444444"]];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Decimal (EU)";
            if (!_isFractionOddsEnabled) {
                self.checkedIndexPath = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.textLabel.text = @"Fractional (UK)";
            if (_isFractionOddsEnabled) {
                self.checkedIndexPath = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
//    else {
//        cell.textLabel.text = @"Notifications";
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
//        [switchView setOn:_isPushNotificationsEnabled animated:NO];
//        [switchView addTarget:self action:@selector(pushNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
//        cell.accessoryView = switchView;
//    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"ODDS FORMAT";
            break;
//        case 1:
//            sectionName = @"ALERTS";
//            break;
        default:
            sectionName = nil;
            break;
    }
    return sectionName;
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    
//    NSString *footerName;
//    
//    switch (section) {
//        case 1:
//            footerName = @"Enable push notifications to get our hot tip of the day every morning. NOT YET IMPLEMENTED.";
//            break;
//        default:
//            footerName = nil;
//            break;
//    }
//    
//    return footerName;
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section)
    {
        case 0:
        {
            if(self.checkedIndexPath) {
                UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
                uncheckCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            if (indexPath.row == 0) {
                [self saveToUserDefaultsWithValue:[NSNumber numberWithBool:NO] forKey:@"fractionOdds"];
                _isFractionOddsEnabled = NO;
            }
            else {
               [self saveToUserDefaultsWithValue:[NSNumber numberWithBool:YES] forKey:@"fractionOdds"];
                _isFractionOddsEnabled = YES;
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Internal action"     // Event category (required)
                                                                      action:@"Switch"  // Event action (required)
                                                                       label:@"Fraction Odds enabled"    // Event label
                                                                       value:nil] build]];
            }
            
        }
            break;
            
//        case 2:
//        {
//            switch (indexPath.row) {
//                case 0:
//                    [self showIntroScreens];
//                    break;
//                case 1:
//                    [self rateUs];
//                    break;
//                case 2:
//                    //                    [self aboutUs];
//                    [SupportKit showInViewController:self withZendeskURL:@"https://bettingexpert.zendesk.com"];
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)pushNotificationsSwitch:(id)sender
{
    UISwitch* switchControl = sender;
//    _pushNotificationsSwitch = sender;
    _isPushNotificationsEnabled = switchControl.on;
    NSLog(@"Push notifications are now %@", switchControl.on ? @"ON" : @"OFF");
    
//    if(switchControl.on && [BCPropertyList getValueFromPlist:@"settings" withKey:@"pushNotificationsEnabled"] == nil) {
//        [BCPushNotifications registerForPushNotifications];
//        [BCPushNotifications updateAlias:[[BCLoginApi sharedInstance] userLogin]];
//    }
//    else
//        [BCPushNotifications updatePushNotificationsState:switchControl.on];
    //        switchControl.on ? [BCPushNotifications registerForPushNotifications:YES] : [BCPushNotifications registerForPushNotifications:NO];
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
