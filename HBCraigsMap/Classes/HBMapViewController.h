//
//  HBMapViewController.h
//  HBCraigsMap
//
//  Created by Heath Borders on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HBMapViewController : UIViewController<MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIWebViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction) currentLocationButtonPressed;

@end
