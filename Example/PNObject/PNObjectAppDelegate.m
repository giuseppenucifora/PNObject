//
//  PNObjectAppDelegate.m
//  PNObject
//
//  Created by Giuseppe Nucifora on 12/28/2015.
//  Copyright (c) 2015 Giuseppe Nucifora. All rights reserved.
//

#import "PNObjectAppDelegate.h"
#import "PNObject.h"
#import "PNUser.h"
#import "PNAddress.h"

@implementation PNObjectAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [PNObjectConfig initSharedInstanceForEnvironments:@{   EnvironmentDevelopment : @"https://development.it/api/v1",
                                                           EnvironmentStage : @"https://stage.it/api/v1",
                                                           EnvironmentProduction : @"http://pnobjectdemo.giuseppenucifora.com/"
                                                           }];
    
    [[PNObjectConfig sharedInstance] setEnvironment:Production];
    [[[PNObjectConfig sharedInstance] manager] setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate]];
    [[PNObjectConfig sharedInstance] manager].securityPolicy.allowInvalidCertificates = YES;
    
    //[PNObject get];*/
    
    PNUser *user = [PNUser currentUser];
    
    
    NSLog(@"asd");
    /*[user setFirstName:@"Giuseppe"];
     [user setLastName:@"Nucifora"];
     [user setHasAcceptedNewsletter:YES];
     [user setHasAcceptedPrivacy:YES];
     [user setUsername:@"giuseppe.nucifora"];
     [user setPassword:@"giuseppe.nucifora.password"];
     [user setPhone:@"+393485904995"];
     [user saveLocally];
     */
    //NSLog(@"%@",[user getObject]);
    
    /*
     
     
     PNAddress *address1 = [[PNAddress alloc] init];
     [address1 setZip:@"95014"];
     [address1 setCountry:@"Italy"];
     [address1 setCity:@"Giarre"];
     [address1 setProvince:@"Catania"];
     
     NSLog(@"%@",[address1 saveLocally]);
     
     
     PNAddress *address2 = [[PNAddress alloc] init];
     [address2 setZip:@"95014"];
     [address2 setCountry:@"Italy"];
     [address2 setCity:@"Giarre"];
     [address2 setProvince:@"Catania"];
     
     NSLog(@"%@",[address2 saveLocally]);*/
    
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
