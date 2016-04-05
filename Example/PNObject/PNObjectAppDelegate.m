//
//  PNObjectAppDelegate.m
//  PNObject
//
//  Created by Giuseppe Nucifora on 12/28/2015.
//  Copyright (c) 2015 Giuseppe Nucifora. All rights reserved.
//

#import "PNObjectAppDelegate.h"
#import "PNObjectViewController.h"

#import "PNObject.h"
#import "PNUser.h"
#import "PNAddress.h"
#import "PNObject+PNObjectConnection.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "UIDevice-Hardware.h"

#import "PNInstallation.h"


@implementation PNObjectAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [FBSDKSettings setAppID:@"213761522305123"];

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @"http://packman.local/app_dev.php/api/v1/",
                                                        EnvironmentStage : @"https://packman.ppreview.it/app_stage.php/api/v1/",
                                                        EnvironmentProduction : @"http://packman.ppreview.it/app_stage.php/api/v1/"
                                                        } userSubclass:[PNUser class] withOauth:YES];
    [[PNObjectConfig sharedInstance] setHTTPHeaderValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [[PNObjectConfig sharedInstance] setClientID:@"1_pqjo2w5k7j4g8skco408oc048w8so0ws840gcg8k8gwsgk0g4" clientSecret:@"10w0vg2v6eggooc4wks4w4s0wkwok0wkck0w888so0o80g88w8" forEnv:EnvironmentProduction];
#ifdef DEBUG
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
#endif
    
    
    PNObjectViewController *viewController = [[PNObjectViewController alloc] init];
    
    switch ([[UIDevice currentDevice] deviceFamily]) {
        case UIDeviceFamilyiPhone:
        case UIDeviceFamilyiPod:
        case UIDeviceFamilyiPad: {
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
            break;
        }
        case UIDeviceFamilyAppleTV:
        case UIDeviceFamilyUnknown:
        default: {
            break;
        }
    }

    _window.rootViewController = viewController;

    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];

    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


#pragma mark - Remote Notification

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PNInstallation *installation = [PNInstallation currentInstallation];
    
    [installation setDeviceTokenFromData:deviceToken];
    
    [installation saveLocally];
    
    NSLog(@"%@",installation);
    
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    NSLog(@"%@",notificationSettings);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"%@",userInfo);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"%@",userInfo);
}

#pragma mark -

@end
