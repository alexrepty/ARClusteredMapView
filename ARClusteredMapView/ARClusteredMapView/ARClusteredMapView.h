//
//  ARClusteredMapView.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "ARClusteredAnnotation.h"

@interface ARClusteredMapView : MKMapView

@property(nonatomic,assign,getter = isClustering)	BOOL clustering;

// call this when the map view changes
- (void)updateClustering;

// call this from mapView:didAddAnnotationViews: to animate pins into place
- (void)animateAnnotationViews:(NSArray *)views;

- (void)removeAllAnnotations;

@end
