//
//  HBMapViewController.m
//  HBCraigsMap
//
//  Created by Heath Borders on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HBMapViewController.h"
#import "JSON.h"
#import "HBPadMapperAnnotation.h"
#import "HBWebViewController.h"

@interface HBMapViewController()

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) NSMutableData *mutableData;

@property (nonatomic, retain) NSURLConnection *tinyGeocoderUrlConnection;

@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic, retain) NSURLConnection *padMapperPinsUrlConnection;

- (void) reverseGeocodeLocation: (CLLocation *) location;
- (void) alertError: (NSError *) error;
- (void) alertMessage: (NSString *) message;
- (void) cancel;

@end


@implementation HBMapViewController

@synthesize searchBar = _searchBar;
@synthesize mapView = _mapView;
@synthesize webView = _webView;

@synthesize locationManager = _locationManager;

@synthesize mutableData = _mutableData;

@synthesize tinyGeocoderUrlConnection = _tinyGeocoderUrlConnection;

@synthesize reverseGeocoder = _reverseGeocoder;

@synthesize padMapperPinsUrlConnection = _padMapperPinsUrlConnection;

- (void)dealloc {
	[_searchBar release];
	[_mapView release];
	[_webView release];

	[_locationManager release];
	
	[_mutableData release];
	
	[_tinyGeocoderUrlConnection release];
	
	[_reverseGeocoder release];
	
	[_padMapperPinsUrlConnection release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self;
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self.searchBar resignFirstResponder];
	NSString *locationQuery = self.searchBar.text;
	if ([locationQuery length]) {
		[self cancel];
		NSLog(@"searching for location: %@", locationQuery);
		NSURL *tinyGeocoderUrl = 
			[NSURL URLWithString:[NSString stringWithFormat:
								  @"http://tinygeocoder.com/create-api.php?q=%@",
								  [locationQuery stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
		self.tinyGeocoderUrlConnection = [[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:tinyGeocoderUrl]
																		  delegate:self] autorelease];
		[self.tinyGeocoderUrlConnection start];
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
	didReceiveData:(NSData *)data {
	[self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *urlDataString = 
		[[[NSString alloc] initWithData:self.mutableData
							   encoding:NSUTF8StringEncoding] autorelease];
	if (connection == self.tinyGeocoderUrlConnection) {
		self.tinyGeocoderUrlConnection = nil;
		NSString *possibleTinyGeocoderRawCoordinate = urlDataString;
		NSArray *possibleRawLatitudeAndRawLongitude = [possibleTinyGeocoderRawCoordinate componentsSeparatedByString:@","];
		if ([possibleRawLatitudeAndRawLongitude count] == 2) {
			NSString *rawLatitude = [possibleRawLatitudeAndRawLongitude objectAtIndex:0];
			NSString *rawLongitude = [possibleRawLatitudeAndRawLongitude objectAtIndex:1];
			
			double latitude = [rawLatitude doubleValue];
			double longitude = [rawLongitude doubleValue];
			
			CLLocation *location = [[[CLLocation alloc] initWithLatitude:latitude
															   longitude:longitude] autorelease];
			NSLog(@"found location for query %@", location);
			[self reverseGeocodeLocation:location];
		} else {
			[self alertMessage:[NSString stringWithFormat:
								@"Could not find location for %@",
								self.searchBar.text]];
		}
	} else if (connection == self.padMapperPinsUrlConnection) {
		NSString *padMapperAnnotationsJson = urlDataString;
		NSError *error = nil;
		NSArray *padMapperAnnotationDictionaries =
			[[[[SBJsonParser alloc] init] autorelease] objectWithString:padMapperAnnotationsJson
																  error:&error];
		if (padMapperAnnotationsJson) {			
			NSLog(@"Found %@ padmapper pins", 
				  [NSNumber numberWithUnsignedInteger:[padMapperAnnotationDictionaries count]]);
			NSMutableArray *padMapperAnnotations = [NSMutableArray arrayWithCapacity:[padMapperAnnotationDictionaries count]];
			for (NSDictionary *padMapperAnnotationDictionary in padMapperAnnotationDictionaries) {
				NSString *padMapperId = [padMapperAnnotationDictionary objectForKey:@"id"];
				NSNumber *latitude = [padMapperAnnotationDictionary objectForKey:@"lat"];
				NSNumber *longitude = [padMapperAnnotationDictionary objectForKey:@"lng"];
				
				CLLocationCoordinate2D locationCoordinate2D = {[latitude doubleValue], [longitude doubleValue]};
				
				HBPadMapperAnnotation *padMapperAnnotation = 
				[[[HBPadMapperAnnotation alloc] initWithLocationCoordinate2D:locationCoordinate2D
															  andPadMapperId:padMapperId] autorelease];
				
				[padMapperAnnotations addObject:padMapperAnnotation];
			}
			
			if ([padMapperAnnotations count]) {
				[self.mapView removeAnnotations:self.mapView.annotations];
				[self.mapView addAnnotations:padMapperAnnotations];
			}
		} else if (error) {
			[self alertError:error];
		}
	}
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error {
	self.tinyGeocoderUrlConnection = nil;
	[self alertError:error];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	NSLog(@"Found current location %@", newLocation);
	[self reverseGeocodeLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	
	if ((error.code != kCLErrorDenied) && (error.code != kCLErrorLocationUnknown)) {
		[self.locationManager stopUpdatingLocation];
		[self alertError:error];	
	}
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder 
	   didFindPlacemark:(MKPlacemark *)placemark {
	NSLog(@"found placemark, setting map region");
	self.searchBar.text = [NSString stringWithFormat:
						   @"%@, %@ %@",
						   placemark.locality,
						   placemark.administrativeArea,
						   placemark.postalCode];
	
	MKCoordinateRegion coordinateRegion = 
		MKCoordinateRegionMakeWithDistance(placemark.coordinate,
										   10 * 1000,
										   10 * 1000);
	[self.mapView setRegion:coordinateRegion
				   animated:YES];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder
	   didFailWithError:(NSError *)error {
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
	[self alertError:error];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[self cancel];
	NSLog(@"Region changed, Loading padmapper pins");
	
	MKCoordinateRegion coordinateRegion = mapView.region;
	CLLocationCoordinate2D centerLocationCoordinate2D = coordinateRegion.center;
	MKCoordinateSpan coordinateSpan = coordinateRegion.span;
	
	NSNumber *eastLongitude = [NSNumber numberWithDouble:centerLocationCoordinate2D.longitude + coordinateSpan.longitudeDelta];
	NSNumber *northLatitude = [NSNumber numberWithDouble:centerLocationCoordinate2D.latitude + coordinateSpan.latitudeDelta];
	NSNumber *southLatitude = [NSNumber numberWithDouble:centerLocationCoordinate2D.latitude - coordinateSpan.latitudeDelta];
	NSNumber *westLongitude = [NSNumber numberWithDouble:centerLocationCoordinate2D.longitude - coordinateSpan.longitudeDelta];
	
	NSURL *padMapperUrl = 
		[NSURL URLWithString:[NSString stringWithFormat:
							  @"http://www.padmapper.com/reloadMarkersJSON.php?eastLong=%@&northLat=%@&westLong=%@&southLat=%@&cities=false&showPOI=false&limit=150&minRent=0&maxRent=6000&searchTerms=&maxPricePerBedroom=6000&minBR=0&maxBR=10&minBA=1&maxAge=7&imagesOnly=false&cats=false&dogs=false&noFee=false&showSubs=true&showNonSubs=true&userId=-1&cl=true&apts=true&ood=true&forrent=true&zoom=15&favsOnly=false&workplaceLat=0&workplaceLong=0&maxTime=0",
							  eastLongitude,
							  northLatitude,
							  westLongitude,
							  southLatitude]];
	
	self.padMapperPinsUrlConnection = 
		[[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:padMapperUrl]
										 delegate:self] autorelease];
	[self.padMapperPinsUrlConnection start];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[HBPadMapperAnnotation class]]) {
		[self cancel];
		
		HBPadMapperAnnotation *padMapperAnnotation = (HBPadMapperAnnotation *) view.annotation;
		NSURL *padMapperListingUrl = [NSURL URLWithString:[NSString stringWithFormat:
														   @"http://www.padmapper.com/show.php?id=%@&src=main",
														   padMapperAnnotation.padMapperId]];
		NSLog(@"Pulling padMapper Listing");
		[self.webView loadRequest:[NSURLRequest requestWithURL:padMapperListingUrl]];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isKindOfClass:[HBPadMapperAnnotation class]]) {
		MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"HBPadMapperAnnotation"];
		if (!pinAnnotationView) {
			pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
																 reuseIdentifier:@"HBPadMapperAnnotation"] autorelease];			
		}

		pinAnnotationView.animatesDrop = YES;
		return pinAnnotationView;
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"showing real listing");
	NSString *craigslistRawUrl = 
		[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('frame').src"];
	NSURL *craigslistUrl = [NSURL URLWithString:craigslistRawUrl];
	if (craigslistUrl) {
		[self presentModalViewController:[[[HBWebViewController alloc] initWithUrlRequest:[NSURLRequest requestWithURL:craigslistUrl]] autorelease]
								animated:YES];	
	} else {
		[self alertMessage:@"Could not find listing"];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self alertError:error];
}


#pragma mark -
#pragma mark private API

- (void) reverseGeocodeLocation:(CLLocation *)location {
	NSLog(@"Reverse Geocoding");
	self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate] autorelease];
	self.reverseGeocoder.delegate = self;
	[self.reverseGeocoder start];
}

- (void) alertError: (NSError *) error {
	[self alertMessage:[error localizedDescription]];
}

- (void) alertMessage: (NSString *) message {
	UIAlertView *errorAlertView = [[[UIAlertView alloc] initWithTitle:@"Craig Map"
															  message:message
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil] autorelease];
	[errorAlertView show];
}

- (void) cancel {
	NSLog(@"Cancelling requests");
	[self.locationManager stopUpdatingLocation];
	self.mutableData = [NSMutableData data];
	[self.tinyGeocoderUrlConnection cancel];
	self.tinyGeocoderUrlConnection = nil;
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
	[self.padMapperPinsUrlConnection cancel];
	self.padMapperPinsUrlConnection = nil;
	[self.webView stopLoading];
}

#pragma mark -
#pragma mark IBActions

- (IBAction) currentLocationButtonPressed {
	NSLog(@"Loading current location");
	[self cancel];
	[self.locationManager startUpdatingLocation];
}

@end
