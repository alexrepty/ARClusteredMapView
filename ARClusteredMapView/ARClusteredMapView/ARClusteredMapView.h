//
//  ARClusteredMapView.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import <MapKit/MapKit.h>

@class ARClusteredAnnotation;

/*!
 *  NSNotification sent by ARClusteredMapView after a clustering run has finished.
 */
extern NSString *const ARClusteredMapViewDidUpdateClusteringNotification;

/*!
 *  ARClusteredMapView is a drop-in replacement for MKMapView which provides animated clustering of MKAnnotationViews.
 *
 *  See https://github.com/alexrepty/ARClusteredMapView/blob/master/README.md for more details.
 */
@interface ARClusteredMapView : MKMapView

/*!
 @property clustering
 @abstract If YES, ARClusteredMapView is currently in the process of clustering the MKAnnotationView instances.
 */
@property(assign, nonatomic, getter = isClustering) BOOL clustering;

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

/*!
 *  Explicitly starts a run of the clustering process. ARClusteredMapView does this automatically when annotations are added or removed.
 */
- (void)updateClustering;

/*!
 *  Animates the supplied MKAnnotationView objects into place after they have been added. Should be called from the delegate's implementation of mapView:didAddAnnotationViews:.
 *
 *  @param views An NSArray containing references to MKAnnotationView objects.
 */
- (void)animateAnnotationViews:(NSArray *)views;

/*!
 *  Convenience method to remove all annotations from the map.
 */
- (void)removeAllAnnotations;

@end
