//
//  ARClusteredAnnotation.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ARClusteredAnnotation : NSObject <MKAnnotation>

@property(nonatomic,retain)	NSArray *containedAnnotations;
@property(nonatomic,assign)	ARClusteredAnnotation *clusterAnnotation;

@property(nonatomic,assign)	CLLocationCoordinate2D coordinate;

@property(nonatomic,copy)	NSString *title;
@property(nonatomic,copy)	NSString *subtitle;

@property(nonatomic,assign,getter = canBeClustered)	BOOL	clusterable;

- (void)sendKVOUpdate;

@end
