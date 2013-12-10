//
//  ARClusteredMapView.m
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import "ARClusteredMapView.h"

static MKZoomScale kARClusteredMapViewMaximumZoom = 20.0;

@interface ARClusteredMapView ()

@property(nonatomic,retain)	MKMapView *invisibleMapView;
@property(nonatomic,assign)	MKZoomScale previousZoomScale;

- (void)clusteredMapViewCommonInit;
- (MKAnnotationView *)annotationInGrid:(MKMapRect)grid usingAnnotations:(NSSet *)annotations;

- (BOOL)didZoomIn;
- (BOOL)didZoomOut;
- (MKZoomScale)currentZoomScale;
- (MKZoomScale)zoomLevelForMapRect:(MKMapRect)rect;

@end

@implementation ARClusteredMapView

@synthesize
	clustering = _clustering,
	invisibleMapView = _invisibleMapView,
	previousZoomScale = _previousZoomScale;

#pragma mark -
#pragma mark ARClusteredMapView construction & destruction

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self clusteredMapViewCommonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self clusteredMapViewCommonInit];
	}
	return self;
}

- (void)dealloc {
	self.invisibleMapView = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark ARClusteredMapView private methods

- (void)clusteredMapViewCommonInit {
	self.clustering = YES;
	self.invisibleMapView = [[[MKMapView alloc] initWithFrame:CGRectZero] autorelease];
	self.previousZoomScale = 0.0;
}

- (id<MKAnnotation>)annotationInGrid:(MKMapRect)grid usingAnnotations:(NSSet *)annotations {
	// First, see if one of the annotations we were already showing is in this mapRect
	NSSet *visibleAnnotationsInBucket = [self annotationsInMapRect:grid];
	NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		BOOL returnValue = ([visibleAnnotationsInBucket containsObject:obj]);
		if (returnValue) {
			*stop = YES;
		}
		return returnValue;
	}];
	
	if (0 < [annotationsForGridSet count]) {
		id<MKAnnotation> annotation = [annotationsForGridSet anyObject];
		NSAssert([self.annotations containsObject:annotation], @"Annotation needs to be added to the MKMapView instance.");
		return annotation;
	}
	
	// Otherwise, find a pin that already serves as a cluster (ideally, the biggest one)
	ARClusteredAnnotation *biggestCluster = nil;
	for (ARClusteredAnnotation *annotation in annotations) {
		if (0 < [annotation.containedAnnotations count]) {
			if (nil == biggestCluster) {
				biggestCluster = annotation;
				continue;
			}
			if ([annotation.containedAnnotations count] > [biggestCluster.containedAnnotations count]) {
				biggestCluster = annotation;
			}
		}
	}
	if (biggestCluster) {
		return biggestCluster;
	}
	
	// Otherwise, sort the annotations based on their distance from the center of the grid square,
	// then choose the one closest to the center to show
	MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(grid),
											   MKMapRectGetMidY(grid));
	NSArray *sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
		MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
		
		CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint);
		CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint);
		
		if (distance1 < distance2) {
			return NSOrderedAscending;
		} else if (distance1 > distance2) {
			return NSOrderedDescending;
		}
		
		return NSOrderedSame;
	}];
	
	id<MKAnnotation> result = nil;
	@try {
		result = [sortedAnnotations objectAtIndex:0];
	}
	@catch (NSException *exception) {
		// ignore
	}
	
	return result;
}

- (void)updateClustering {
	id updateClusteringBlock = ^() {
		[self actuallyUpdateClustering];
	};
	dispatch_async(dispatch_get_main_queue(), updateClusteringBlock);
}

- (void)actuallyUpdateClustering {
	if (![self isClustering]) {
		return;
	}
	
	// This value will control the number of off-screen annotations that are being displayed.
	// A bigger number means more annotations, which reduces the chance of annotations popping in but results in lower performance.
	// A smaller number means less annotations, which increases performance but also the likelihood of annotations popping in.
	static double marginFactor = 3.0;
	
	// Bigger bucket sizes will coalesce more annotation views into one, adjust as needed.
	// Very small numbers can lead to too many annotations on screen.
	static double bucketSize = 80.0;
	
	// Figure out the area in which we should coalesce annotation views
	MKMapRect visibleMapRect = [self visibleMapRect];
	MKMapRect adjustedVisibleMapRect = visibleMapRect;
	CGFloat halfWidth = (adjustedVisibleMapRect.size.width / 2.0);
	CGFloat halfHeight = (adjustedVisibleMapRect.size.height / 2.0);
	adjustedVisibleMapRect.origin.x -= halfWidth * ((int)marginFactor - 1);
	adjustedVisibleMapRect.origin.y -= halfHeight * ((int)marginFactor - 1);
	adjustedVisibleMapRect.size.width *= marginFactor;
	adjustedVisibleMapRect.size.height *= marginFactor;
	
	// Figure out our grid sizes
	CLLocationCoordinate2D leftCoordinate = [self convertPoint:CGPointZero toCoordinateFromView:self];
	CLLocationCoordinate2D rightCoordinate = [self convertPoint:CGPointMake(bucketSize, 0.0) toCoordinateFromView:self];
	double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
	MKMapRect gridMapRect = MKMapRectMake(0.0,
										  0.0,
										  gridSize,
										  gridSize);
	
	double steppingSize = 32.0 * gridSize;
	double startX = floor((MKMapRectGetMinX(adjustedVisibleMapRect) / steppingSize)) * steppingSize;
	double startY = floor((MKMapRectGetMinY(adjustedVisibleMapRect) / steppingSize)) * steppingSize;
	double endX = ceil((MKMapRectGetMaxX(adjustedVisibleMapRect) / steppingSize)) * steppingSize;
	double endY = ceil((MKMapRectGetMaxY(adjustedVisibleMapRect) / steppingSize)) * steppingSize;
	
	// Find one annotation per grid square (if any)
	NSMutableArray *annotationsToAdd = [NSMutableArray array];
	gridMapRect.origin.y = startY;
	while (MKMapRectGetMinY(gridMapRect) <= endY) {
		gridMapRect.origin.x = startX;
		
		while (MKMapRectGetMinX(gridMapRect) <= endX) {
			NSSet *allAnnotationsInBucket = [self.invisibleMapView annotationsInMapRect:gridMapRect];
			NSSet *visibleAnnotationsInBucket = [self annotationsInMapRect:gridMapRect];
			
			BOOL didZoomOut = [self didZoomOut];
			if (didZoomOut) {
				BOOL hasAnnotations = ([allAnnotationsInBucket count] > 0);
				BOOL hasVisibleAnnotations = ([visibleAnnotationsInBucket count] > 0);
				if (hasAnnotations && !hasVisibleAnnotations) {
					gridMapRect.origin.x += gridSize;
					continue;
				}
			}
			
			NSMutableSet *filteredAnnotationsInBucket = [[[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL *stop) {
				BOOL passed = ([obj isKindOfClass:[ARClusteredAnnotation class]]);
				if (passed && didZoomOut) {
					passed = (((ARClusteredAnnotation *)obj).clusterAnnotation == nil);
				}
				if (passed) {
					passed = ([((ARClusteredAnnotation *)obj) canBeClustered]);
				}
				return passed;
			}] mutableCopy] autorelease];
			
			if (0 < [filteredAnnotationsInBucket count]) {
				ARClusteredAnnotation *annotationForGrid = (ARClusteredAnnotation *)[self annotationInGrid:gridMapRect usingAnnotations:filteredAnnotationsInBucket];
				[filteredAnnotationsInBucket removeObject:annotationForGrid];
				
				// Give the annotationForGrid a reference to all the other annotations it will represent
				for (ARClusteredAnnotation *annotation in filteredAnnotationsInBucket) {
					annotation.clusterAnnotation = annotationForGrid;
				}
				[annotationsToAdd addObject:annotationForGrid];
				
				MKAnnotationView *gridAnnotationView = [self viewForAnnotation:annotationForGrid];
				if (gridAnnotationView) {
					UIView *superview = gridAnnotationView.superview;
					[superview bringSubviewToFront:gridAnnotationView];
					gridAnnotationView.layer.zPosition = 2.0;
				}

				for (ARClusteredAnnotation *annotation in filteredAnnotationsInBucket) {
					// Give all the other annotations a reference to the one which is representing them
					annotation.clusterAnnotation = annotationForGrid;
					
					// Remove annotations which we've decided to cluster
					if ([visibleAnnotationsInBucket containsObject:annotation]) {
						CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
						BOOL wasSelected = NO;
						if ([[self selectedAnnotations] containsObject:annotation]) {
							wasSelected = YES;
							[self deselectAnnotation:annotation animated:YES];
						}
						
						MKAnnotationView *annotationView = [self viewForAnnotation:annotation];
						UIView *annotationViewSuperview = annotationView.superview;
						[annotationViewSuperview sendSubviewToBack:annotationView];
						annotationView.layer.zPosition = 1.0;
						
						id animations = ^{
							annotation.coordinate = annotation.clusterAnnotation.coordinate;
							annotationView.transform = gridAnnotationView.transform;
						};
						id completion = ^(BOOL finished) {
							annotation.coordinate = actualCoordinate;
							if (wasSelected) {
								[self selectAnnotation:annotation.clusterAnnotation animated:YES];
								gridAnnotationView.layer.zPosition = 4.0;
							} else {
								gridAnnotationView.layer.zPosition = 0.0;
							}
							[super removeAnnotation:annotation];
						};
						
						[UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState & UIViewAnimationOptionCurveEaseInOut & UIViewAnimationOptionAllowAnimatedContent & UIViewAnimationOptionLayoutSubviews) animations:animations completion:completion];
					}
				}
				
				if ([self.selectedAnnotations containsObject:annotationForGrid] &&
					([self currentZoomScale] != [self previousZoomScale])) {
					[self deselectAnnotation:annotationForGrid animated:NO];
					[self selectAnnotation:annotationForGrid animated:NO];
				}
			}
			
			gridMapRect.origin.x += gridSize;
		}
		
		gridMapRect.origin.y += gridSize;	
	}
	
	[super addAnnotations:annotationsToAdd];
	self.previousZoomScale = [self currentZoomScale];
}

- (BOOL)didZoomIn {
	return ([self currentZoomScale] > [self previousZoomScale]);
}

- (BOOL)didZoomOut {
	return ([self currentZoomScale] < [self previousZoomScale]);
}

- (MKZoomScale)currentZoomScale {
	return [self zoomLevelForMapRect:self.visibleMapRect];
}

- (MKZoomScale)zoomLevelForMapRect:(MKMapRect)rect {
    MKZoomScale zoomScale = rect.size.width / self.bounds.size.width; //MKZoomScale is just a CGFloat typedef
    MKZoomScale zoomExponent = log2(zoomScale);
    MKZoomScale zoomLevel = (kARClusteredMapViewMaximumZoom - zoomExponent);
    return zoomLevel;
}

#pragma mark -
#pragma mark ARClusteredMapView public methods

- (void)animateAnnotationViews:(NSArray *)views {
	for (MKAnnotationView *annotationView in views) {
		if (![annotationView.annotation isKindOfClass:[ARClusteredAnnotation class]]) {
			continue;
		}
		
		ARClusteredAnnotation *annotation = (ARClusteredAnnotation *)annotationView.annotation;
		
		if (annotation.clusterAnnotation != nil) {
			// Animate the annotation from its old container's coordinate to its actual coordinate
			CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
			CLLocationCoordinate2D containerCoordinate = annotation.clusterAnnotation.coordinate;
			
			annotationView.layer.zPosition = 1.0;
			MKAnnotationView *clusterAnnotationView = [self viewForAnnotation:annotation.clusterAnnotation];
			clusterAnnotationView.layer.zPosition = 1.5;
			
			annotation.clusterAnnotation = nil;
			annotation.coordinate = containerCoordinate;
			
			[UIView animateWithDuration:0.3
							 animations:^() {
								 annotation.coordinate = actualCoordinate;
							 }
							 completion:^(BOOL finished) {
								 [annotationView setNeedsLayout];
								 annotationView.layer.zPosition = 0.0;
								 clusterAnnotationView.layer.zPosition = 0.0;
							 }];
			
			if ([[self selectedAnnotations] containsObject:annotation]) {
				[self deselectAnnotation:annotation animated:YES];
			}
		} else {
			[annotationView.superview sendSubviewToBack:annotationView];
		}
	}
}

- (void)removeAllAnnotations {
	NSArray *allAnnotations = [self.invisibleMapView annotations];
	NSArray *visibleAnnotations = [super annotations];
	
	[self.invisibleMapView removeAnnotations:allAnnotations];
	[self.invisibleMapView removeAnnotations:visibleAnnotations];
	
	[self removeAnnotations:allAnnotations];
	[self removeAnnotations:visibleAnnotations];
	
	[super removeAnnotations:allAnnotations];
	[super removeAnnotations:visibleAnnotations];
	
	[self updateClustering];
}

#pragma mark -
#pragma mark MKMapView methods

- (NSArray *)annotations {
	return [self.invisibleMapView annotations];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation {
	[self.invisibleMapView addAnnotation:annotation];
	if (![((ARClusteredAnnotation *)annotation) canBeClustered]) {
		[super addAnnotation:annotation];
	}
	[self updateClustering];
}

- (void)addAnnotations:(NSArray *)annotations {
	[self.invisibleMapView addAnnotations:annotations];
	NSSet *nonClusterableAnnotations = [[NSSet setWithArray:annotations] objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return ![((ARClusteredAnnotation *)obj) canBeClustered];
	}];
	for (ARClusteredAnnotation *annotation in nonClusterableAnnotations) {
		[super addAnnotation:annotation];
	}
	[self updateClustering];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation {
	[self.invisibleMapView removeAnnotation:annotation];
	if (![((ARClusteredAnnotation *)annotation) canBeClustered]) {
		[super removeAnnotation:annotation];
	}
	[self updateClustering];
}

- (void)removeAnnotations:(NSArray *)annotations {
	[self.invisibleMapView removeAnnotations:annotations];
	NSSet *nonClusterableAnnotations = [[NSSet setWithArray:annotations] objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		if ([((id<MKAnnotation>)obj) isKindOfClass:[MKUserLocation class]]) {
			return NO;
		}
		return [((ARClusteredAnnotation *)obj) canBeClustered];
	}];
	for (ARClusteredAnnotation *annotation in nonClusterableAnnotations) {
		[super removeAnnotation:annotation];
	}
	[self updateClustering];
}

@end
