//
//  HBCraigsMapAppDelegate.m
//  HBCraigsMap
//
//  Created by Heath Borders on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HBCraigsMapAppDelegate.h"

@interface HBCraigsMapAppDelegate()

@end


@implementation HBCraigsMapAppDelegate

@synthesize window = _window;
@synthesize mapViewController = _mapViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[self.window addSubview:self.mapViewController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)dealloc {
	[_mapViewController release];
    [_window release];
    [super dealloc];
}


@end
