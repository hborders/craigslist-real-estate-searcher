//
//  HBPadMapperPin.h
//  HBCraigsMap
//
//  Created by Heath Borders on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HBPadMapperAnnotation : NSObject<MKAnnotation> {

}

- (id) initWithLocationCoordinate2D: (CLLocationCoordinate2D) locationCoordinate2D
					 andPadMapperId: (NSString *) padMapperId;

@property (nonatomic, retain, readonly) NSString *padMapperId;

@end
