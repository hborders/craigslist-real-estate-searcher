//
//  HBPadMapperPin.m
//  HBCraigsMap
//
//  Created by Heath Borders on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HBPadMapperAnnotation.h"

@interface HBPadMapperAnnotation()

@property (nonatomic) CLLocationCoordinate2D locationCoordinate2D;
@property (nonatomic, retain, readwrite) NSString *padMapperId;

@end


@implementation HBPadMapperAnnotation

@synthesize locationCoordinate2D = _locationCoordinate2D;
@synthesize padMapperId = _padMapperId;

- (id) initWithLocationCoordinate2D: (CLLocationCoordinate2D) locationCoordinate2D
					 andPadMapperId: (NSString *) padMapperId {
	if (self = [super init]) {
		_locationCoordinate2D = locationCoordinate2D;
		_padMapperId = [padMapperId retain];
	}
	
	return self;
}

- (void) dealloc {
	[_padMapperId release];
	
	[super dealloc];
}

- (CLLocationCoordinate2D) coordinate {
	return self.locationCoordinate2D;
}

@end
