//
//  ARClusteredMapView.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "ARClusteredAnnotation.h"

extern NSString *const ARClusteredMapViewDidUpdateClusteringNotification;

@interface ARClusteredMapView : MKMapView

@property(nonatomic,assign,getter = isClustering)	BOOL clustering;

/*!
 @property calloutView
 @abstract If a callout view is currently shown, a reference to it can be stored here for improved hit-testing.
 */
@property(weak, nonatomic) UIView *calloutView;

/*!
 @property annotationViewSize
 @abstract The size of the standard annotation view for this map view, so we can figure out if our annotation views will end up blocking other annotation views.
 */
@property(assign, nonatomic) CGSize annotationViewSize;

/*!
 @property annotationViewAnchorPoint
 @abstract The anchor point for this map view’s standard annotation view.
 */
@property(assign, nonatomic) CGPoint annotationViewAnchorPoint;

// call this when the map view changes
- (void)updateClustering;

// call this from mapView:didAddAnnotationViews: to animate pins into place
- (void)animateAnnotationViews:(NSArray *)views;

- (void)removeAllAnnotations;

@end
