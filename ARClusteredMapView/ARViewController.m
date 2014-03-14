//
//  ARViewController.m
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import "ARViewController.h"
#import "ARClusteredMapView.h"

@implementation ARViewController

@synthesize
	mapView = _mapView;

#pragma mark -
#pragma mark UIViewController methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 53.093724;
    coordinate.longitude = 8.805225;
	[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 5000, 5000) animated:YES];
    
    NSMutableArray *pins = [NSMutableArray array];
    
    for(int i=0;i<200;i++) {
        CGFloat latDelta = rand()*0.125/RAND_MAX - 0.08;
        CGFloat lonDelta = rand()*0.130/RAND_MAX - 0.08;
        
        CGFloat lat = 53.093724;
        CGFloat lng = 8.805225;
        
        CLLocationCoordinate2D newCoord = {lat+latDelta, lng+lonDelta};
        ARClusteredAnnotation *pin = [[ARClusteredAnnotation alloc] init];
        pin.title = [NSString stringWithFormat:@"Pin %i",i+1];;
        pin.subtitle = [NSString stringWithFormat:@"Pin %i subtitle",i+1];
        pin.coordinate = newCoord;
        [pins addObject:pin];
    }
    
    [self.mapView addAnnotations:pins];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{ 
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	[self.mapView animateAnnotationViews:views];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[self.mapView updateClustering];
}

@end
