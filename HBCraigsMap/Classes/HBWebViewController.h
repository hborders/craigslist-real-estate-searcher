//
//  HBWebViewController.h
//  HBCraigsMap
//
//  Created by Heath Borders on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HBWebViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id) initWithUrlRequest: (NSURLRequest *) urlRequest;

- (IBAction) donePressed;

@end
