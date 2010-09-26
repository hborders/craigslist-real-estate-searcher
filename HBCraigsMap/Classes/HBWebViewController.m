//
//  HBWebViewController.m
//  HBCraigsMap
//
//  Created by Heath Borders on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HBWebViewController.h"

@interface HBWebViewController()

@property (nonatomic, retain) NSURLRequest *urlRequest;

@end


@implementation HBWebViewController

@synthesize webView = _webView;

@synthesize urlRequest = _urlRequest;

- (id) initWithUrlRequest: (NSURLRequest *) urlRequest {
	if (self = [super init]) {
		_urlRequest = [urlRequest retain];
	}
	
	return self;
}

- (void)dealloc {
	[_webView release];
	
	[_urlRequest release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[self.webView loadRequest:self.urlRequest];
}

- (void)viewDidUnload {
	self.webView = nil;
	
    [super viewDidUnload];
}

#pragma mark -
#pragma mark IBActions

- (IBAction) donePressed {
	[self dismissModalViewControllerAnimated:YES];
}

@end
