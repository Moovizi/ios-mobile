//
//  AppDelegate.m
//  Moovizi
//
//  Created by Tchikovani on 20/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    [GMSServices provideAPIKey:kGOOGLE_MAP_API_KEY];

    HomeViewController *mainVC = [[HomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    nav.navigationBar.tintColor = [ColorFactory yellowColor];
    UIView *navLineBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nav.navigationBar.bottom - 4.0f, self.window.frame.size.width, 4.0f)];
    [navLineBorder setBackgroundColor:[ColorFactory yellowColor]];
    [nav.navigationBar addSubview:navLineBorder];
    nav.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                          NSForegroundColorAttributeName: [ColorFactory yellowColor],
                                                          NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:21]
                                                          }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                            NSForegroundColorAttributeName: [ColorFactory yellowColor],
                                                            NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:21]
                                                           }
                                                forState:UIControlStateNormal];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
