//
//  ARAppDelegate.h
//  ARClusteredMapView
//
//  Created by Alexander Repty on 18.10.11.
//  Copyright (c) 2011 Alexander Repty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARViewController;

@interface ARAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong,nonatomic) UIWindow			*window;
@property (strong,nonatomic) ARViewController	*viewController;

@end
