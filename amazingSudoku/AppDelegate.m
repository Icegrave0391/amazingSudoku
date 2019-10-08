//
//  AppDelegate.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //bar
    UITabBarController * barVC = [[UITabBarController alloc] init];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    HomeViewController * homeVC = [[HomeViewController alloc] init];
    homeVC.tabBarItem.title = @"游戏";
    homeVC.tabBarItem.image = [UIImage imageNamed:@"shipin"];
    [barVC addChildViewController:homeVC];
//    UINavigationController * rootVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UIViewController * vc = [[UIViewController alloc] init];
    vc.tabBarItem.title = @"个人资料";
    vc.tabBarItem.image = [UIImage imageNamed:@"Profile"];
    [barVC addChildViewController:vc];
    [self.window setRootViewController:barVC];
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
