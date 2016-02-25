//
//  AppDelegate.m
//  zTV Series
//
//  Created by Avikant Saini on 2/24/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Override point for customization after application launch.
	
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:17.f], NSForegroundColorAttributeName: [UIColor darkTextColor]}];
	
	[[UINavigationBar appearance] setBarTintColor:GLOBAL_BACK_COLOR];
	
	[[UITabBar appearance] setTintColor:[UIColor blackColor]];
	[[UITabBar appearance] setBarTintColor:GLOBAL_BACK_COLOR];
	
	[[UITabBarItem appearance] setTitleTextAttributes: @{ NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:11.0f], NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
	
	[[UITabBarItem appearance] setTitleTextAttributes: @{ NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:11.0f], NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateNormal];
	
	NSString *bundledFilePath = [[NSBundle mainBundle] pathForResource:@"OTVSeries.db" ofType:nil];
	NSString *filePath = [self documentsPathForFileName:@"OTVSeries.db"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self documentsPathForFileName:@"OTVSeries.db"]]) {
		NSLog(@"Copying bundled file to documents.");
		[[NSFileManager defaultManager] copyItemAtPath:bundledFilePath toPath:filePath error:nil];
	}
	
	[[DBManager sharedManager] dbManagerOpenDatabaseWithPath:filePath];
	
	return YES;
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/OTVSeries/", [paths lastObject]] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"OTVSeries/%@", name]];
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
