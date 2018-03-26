//
//  PNObjAppDelegate.m
//  PNObject
//
//  Created by Giuseppe Nucifora on 12/28/2016.
//  Copyright (c) 2016 Giuseppe Nucifora. All rights reserved.
//

#import "PNObjAppDelegate.h"

#import <PNObject/PNUser.h>
#import <PNObject/PNAddress.h>
#import <PNObject/PNObject+PNObjectConnection.h>
#import "PNObjViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "UIDevice-Hardware.h"

#import <PNObject/PNInstallation.h>
#import <NSDate_Utils/NSDate+NSDate_Util.h>

@implementation PNObjAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [FBSDKSettings setAppID:@"213761522305123"];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @{BaseUrl:@"http://pnobject.local/",EndpointPath:@"api/v1/"},
                                                        EnvironmentStage : @{BaseUrl:@"https://idd.ppreview.it/",EndpointPath:@"wp-json/v1/"},
                                                        EnvironmentProduction : @{BaseUrl:@"http://pnobject.prod.it/",EndpointPath:@"api/v1/"},
                                                        } userSubclass:[PNUser class] withOauthMode:OAuthModeClientCredential];
    
    [[PNObjectConfig sharedInstance] setClientID:@"xVdEbNLLierj9CJoLNo5lsbg7VFs8UikqADbcwKA" clientSecret:@"2WWSJrDNbZhbUUCXIOTBiYIJv9muiRGK68f2B2Eb" oAuthEndpointAction:@"oauth/token" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setOauthClientID:@"tXYhKtcvfYdCM4tNor6WfbclEWYkoGWqBimUBzqZ" oauthClientSecret:@"3UMEQthBHp1oEo0pjFmgkifhig689ZL5L9DsSETd" oAuthEndpointAction:@"oauth/token" forEnv:EnvironmentStage];
    
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
    //[[PNObjectConfig sharedInstance] setHTTPHeaderValue:@"XMLHttpRequest" forKey:@"X-Request-With"];
    
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] baseUrl]);
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] endPointPath]);
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] endPointUrl]);
    
    
    
    PNObjViewController *viewController = [[PNObjViewController alloc] init];
    
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
    
    /*[PNUser loginCurrentUserWithEmail:@"socials2@giuseppenucifora.com" password:@"asdasdasd" withBlockSuccess:^(PNUser * _Nullable responseObject) {
     
     } failure:^(NSError * _Nonnull error) {
     
     }];*/
    
    if ([PNUser currentUser] && [[PNUser currentUser] isAuthenticated]) {
        NSLogDebug(@"Login in corso...");
        [[PNUser currentUser] reloadFormServerWithBlockSuccess:^(PNUser * _Nullable currentUser) {
            NSLogDebug(@"Login Success...");
            
        } failure:^(NSError * _Nonnull error) {
            NSLogDebug(@"Login in error...");
        }];
    }

    
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
    
    NSLogDebug(@"%@",installation);
    
    NSLogDebug(@"%@",[installation JSONFormObject]);
    
    //[installation setUser:nil];
    
    [self updateDeviceUser];
    
}

- (void) updateDeviceUser {
    
    if ([PNUser currentUser] && [[PNUser currentUser] isAuthenticated]) {
        [[PNInstallation currentInstallation] setUser:[PNUser currentUser]];
    }
    else {
        [[PNInstallation currentInstallation] setUser:nil];
    }
    
    if (![[PNInstallation currentInstallation] registeredAt] || [[NSDate date] isLaterThanDate:[[[PNInstallation currentInstallation] lastTokenUpdate] dateByAddingDays:1]]) {
        [self registerRemoteDevice];
    }
    else if ([[PNInstallation currentInstallation] updatedAt] || [[NSDate date] isLaterThanDate:[[[PNInstallation currentInstallation] updatedAt] dateByAddingMinutes:30]]) {
        [self updateRemoteDevice];
    }
}

- (void) registerRemoteDevice {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PNInstallation currentInstallation] registerDeviceWithBlockProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } Success:^(BOOL response) {
            NSLogDebug(@"device registrato");
        } failure:^(NSError * _Nonnull error) {
            NSLogDebug(@"device non registrato");
        }];
    });
}

- (void) updateRemoteDevice {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PNInstallation currentInstallation] updateDeviceWithBlockProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } Success:^(BOOL response) {
            NSLogDebug(@"device aggiornato");
        } failure:^(NSError * _Nonnull error) {
            NSLogDebug(@"device non aggiornato");
        }];
    });
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    NSLogDebug(@"%@",notificationSettings);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLogDebug(@"%@",userInfo);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLogDebug(@"%@",userInfo);
}

#pragma mark -

@end
