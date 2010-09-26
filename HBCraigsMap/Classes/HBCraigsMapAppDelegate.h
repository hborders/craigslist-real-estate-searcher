//
//  HBCraigsMapAppDelegate.h
//  HBCraigsMap
//
//  Created by Heath Borders on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBMapViewController.h"

@interface HBCraigsMapAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HBMapViewController *mapViewController;

@end

