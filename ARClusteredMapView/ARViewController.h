//
//  ARViewController.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARClusteredMapView.h"

@interface ARViewController : UIViewController <MKMapViewDelegate>

@property(nonatomic,retain)	IBOutlet ARClusteredMapView *mapView;

@end
