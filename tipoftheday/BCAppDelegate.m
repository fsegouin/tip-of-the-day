//
//  BCAppDelegate.m
//  tipoftheday
//
//  Created by Florent Segouin on 8/13/14.
//  Copyright (c) 2014 Better Collective. All rights reserved.
//

#import "BCAppDelegate.h"
#import "Reachability.h"
#import "CWStatusBarNotification.h"
#import "UIColor+Hex.h"

@implementation BCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    Initialize NSUserDefaults defaults values for this app
    
    // Check the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"fractionOdds"] == nil) {
        [defaults setValue:[NSNumber numberWithBool:NO] forKey:@"fractionOdds"];
        [defaults synchronize];
        NSLog(@"Data initialized!");
    }
    
//    OtherLevels SDK Init
    
//    [OtherLevels startSessionWithLaunchOptions:launchOptions];
//    [OtherLevels debugSessionWithLaunchOptions:launchOptions];
    
    // insert this, in addition to code already in didFinishLaunchingWithOptions
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeAlert |
//      UIRemoteNotificationTypeBadge |
//      UIRemoteNotificationTypeSound )];
    
//    GoogleAnalytics SDK Init
    
//    // Optional: automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    
//    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 20;
//    
//    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
//    
//    // Initialize tracker. Replace with your tracking ID.
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53019916-2"];
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Reachability methods
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UNREACHABLE!");
            CWStatusBarNotification *notification = [CWStatusBarNotification new];
            notification.notificationLabelBackgroundColor = [UIColor colorWithHex:0xc0392b];
            notification.notificationLabelTextColor = [UIColor whiteColor];
            [notification displayNotificationWithMessage:@"Please check your network connection and try again."
                                             forDuration:3.0f];
        });
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
    
    //    Test to list every font available
    
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [OtherLevels didReceiveNotification:application
                           notification:userInfo];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if(types != UIRemoteNotificationTypeNone){
        
        NSLog(@"%@", [deviceToken description]);
        // store the device token here, for later use
        [[NSUserDefaults standardUserDefaults] setObject:[deviceToken description] forKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // OtherLevels Register device cald
        
//        If you are unable to determine a Tracking ID at this point, OtherLevels will generate and store one for you. In this case you will need to do as shown below instead of the above @registerDevice@ call. The OtherLevels generated Tracking ID will then become the App's default Tracking ID until you overwrite it.
        
            // OtherLevels Register device call
            [OtherLevels registerDevice:[deviceToken description]
                         withTrackingId:@""];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
