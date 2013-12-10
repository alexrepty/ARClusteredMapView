//
//  ARClusteredAnnotation.m
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ARClusteredAnnotation.h"

NSString *const kARClusteredAnnotationKeyClusterAnnotation	= @"clusterAnnotation";
NSString *const kARClusteredAnnotationKeyTitle				= @"title";
NSString *const kARClusteredAnnotationKeySubtitle			= @"subtitle";
NSString *const kARClusteredAnnotationKeyCoordinate			= @"coordinate";

@implementation ARClusteredAnnotation

@synthesize
	containedAnnotations = _containedAnnotations,
	clusterAnnotation = _clusterAnnotation,
	coordinate = _coordinate,
	title = _title,
	subtitle = _subtitle,
	clusterable = _clusterable;

#pragma mark -
#pragma mark ARClusteredAnnotation construction & destruction

- (id)init {
	self = [super init];
	if (self) {
		self.clusterable = YES;
	}
	return self;
}

- (void)dealloc {
	self.containedAnnotations = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark MKAnnotation methods

- (NSString *)title {
	if (0 < [self.containedAnnotations count]) {
		NSString *clusteredMapViewAnnotationsKey = @"ClusteredMapView_annotations";
		NSString *localizedAnnotations = NSLocalizedString(clusteredMapViewAnnotationsKey, nil);
		if ([localizedAnnotations isEqualToString:clusteredMapViewAnnotationsKey]) {
			localizedAnnotations = @"annotations";
		}
		NSString *title = [NSString stringWithFormat:@"%d %@", [self.containedAnnotations count]+1, localizedAnnotations];
		return title;
	}
	return [[_title retain] autorelease];
}

- (NSString *)subtitle {
	if (0 < [self.containedAnnotations count]) {
		return nil;
	}
	return [[_subtitle retain] autorelease];
}

#pragma mark -
#pragma mark ARClusteredAnnotation accessors

- (void)setClusterAnnotation:(ARClusteredAnnotation *)clusterAnnotation {
	if ([self.containedAnnotations containsObject:clusterAnnotation]) {
		return;
	}
	if (clusterAnnotation == self) {
		return;
	}
	if (clusterAnnotation == _clusterAnnotation) {
		return;
	}
	
	if (clusterAnnotation) {
		for (ARClusteredAnnotation *annotation in [[self.containedAnnotations retain] autorelease]) {
			[annotation setClusterAnnotation:clusterAnnotation];
		}
		
		if (self.containedAnnotations) {
			[self willChangeValueForKey:kARClusteredAnnotationKeyTitle];
			[self willChangeValueForKey:kARClusteredAnnotationKeySubtitle];
			self.containedAnnotations = nil;
			[self didChangeValueForKey:kARClusteredAnnotationKeyTitle];
			[self didChangeValueForKey:kARClusteredAnnotationKeySubtitle];
		}
	}
	
	if (self.clusterAnnotation) {
		NSArray *oldAnnotations = [[self.clusterAnnotation.containedAnnotations retain] autorelease];
		NSMutableArray *adjustedContainedAnnotations = [[oldAnnotations mutableCopy] autorelease];
		[adjustedContainedAnnotations removeObject:self];
		self.clusterAnnotation.containedAnnotations = adjustedContainedAnnotations;
		[self.clusterAnnotation sendKVOUpdate];
	}
	
	[self willChangeValueForKey:kARClusteredAnnotationKeyClusterAnnotation];
	_clusterAnnotation = clusterAnnotation;
	[self didChangeValueForKey:kARClusteredAnnotationKeyClusterAnnotation];

	if (!clusterAnnotation) {
		return;
	}
	
	if (!self.clusterAnnotation.containedAnnotations) {
		self.clusterAnnotation.containedAnnotations = [NSArray arrayWithObject:self];
	} else {
		if (![self.clusterAnnotation.containedAnnotations containsObject:self]) {
			NSArray *oldAnnotations = [[self.clusterAnnotation.containedAnnotations retain] autorelease];
			self.clusterAnnotation.containedAnnotations = [oldAnnotations arrayByAddingObject:self];
		}
	}
	[self.clusterAnnotation sendKVOUpdate];
}

#pragma mark -
#pragma mark ARClusteredAnnotation public methods

- (void)sendKVOUpdate {
	[self willChangeValueForKey:kARClusteredAnnotationKeyTitle];
	[self willChangeValueForKey:kARClusteredAnnotationKeySubtitle];
	[self willChangeValueForKey:kARClusteredAnnotationKeyCoordinate];
	[self didChangeValueForKey:kARClusteredAnnotationKeyTitle];
	[self didChangeValueForKey:kARClusteredAnnotationKeySubtitle];
	[self didChangeValueForKey:kARClusteredAnnotationKeyCoordinate];
}

#pragma mark -
#pragma mark NSObject methods

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p> title = %@; subtitle = %@; cluster = %@; # contained: %d; coordinate: %@",
			NSStringFromClass([self class]),
			self,
			self.title,
			self.subtitle,
			self.clusterAnnotation ? [NSString stringWithFormat:@"\n%@\n", self.clusterAnnotation] : @"NO",
			[self.containedAnnotations count],
			[NSString stringWithFormat:@"{latitude: %.8f; longitude: %.8f}",
			 self.coordinate.latitude,
			 self.coordinate.longitude]];
}

@end
