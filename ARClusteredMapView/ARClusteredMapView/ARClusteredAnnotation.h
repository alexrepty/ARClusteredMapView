//
//  ARClusteredAnnotation.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

/*!
 *  ARClusteredAnnotation is a datatype that implementations should subclass in order to use animated annotation clustering using ARClusteredMapView.
 */
@interface ARClusteredAnnotation : NSObject <MKAnnotation>

/*!
 @property containedAnnotations
 @abstract If this is the main annotation for a cluster, this array contains references to all other ARClusteredAnnotation objects contained in the cluster.
 */
@property(nonatomic, retain) NSArray *containedAnnotations;

/*!
 @property clusterAnnotation
 @abstract If this annotation is part of a cluster, this property contains a reference to the cluster's main annotation.
 */
@property(nonatomic, assign) ARClusteredAnnotation *clusterAnnotation;

/*!
 @property coordinate
 @abstract This annotation's coordinate, as per the MKAnnotation protocol.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/*!
 @property title
 @abstract This annotation's title, as per the MKAnnotation protocol.
 */
@property(nonatomic, copy) NSString *title;

/*!
 @property subtitle
 @abstract This annotation's subtitle, as per the MKAnnotation protocol.
 */
@property(nonatomic, copy) NSString *subtitle;

/*!
 @property clusterable
 @abstract Determines whether this annotation can be clustered. Defaults to YES.
 */
@property(nonatomic, assign, getter = canBeClustered) BOOL clusterable;

/*!
 *  Sends a KVO update for the annotation's title, subtitle and coordinate properties since they are derived dynamically and might change due to the annotation being clustered.
 */
- (void)sendKVOUpdate;

@end
