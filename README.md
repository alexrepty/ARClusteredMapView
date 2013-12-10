ARClusteredMapView
==================

Purpose
-------

Originally developed for [Foodish](http://www.foodishapp.com/), `ARClusteredMapView` serves as a drop-in replacement for `MKMapView`, providing animated clustering of `MKAnnotationViews`.

I have decided to share this class here since it provides decent functionality in Foodish and was a fitting ingredient in my talk on MapKit at AltTechTalks Berlin on December 11th, 2013.

Bug reports and/or pull requests welcome.

Usage
-----

* Start using the `ARClusteredMapView` class as a replacement for the `MKMapView` instance you would like to have clustering support for.
* Make sure that any annotations you add to the view inherit from the `ARClusteredAnnotation` class, which provides support for managing annotation ownership.
* Whenever appropriate (i.e. in `-mapView:regionDidChangeAnimated:`), call `ARClusteredMapView`'s `-updateClustering` method.
* In your `MKMapViewDelegate` implementation, make sure you call `-animateAnnotationViews:` (supplied with an `NSArray` of annotation views) to make sure that newly inserted `MKAnnotationView` instances animate correctly.

Todo
----

`ARClusteredMapView` has yet to be upgraded to use ARC. I'm sure it has some other bugs which don't manifest in Foodish and I hope to eliminate these shortly. When those conditions have been met, I will create a podspec and submit the app to [CocoaPods](http://www.cocoapods.org/).

Scope
-----

The included Xcode project is ready to build in Xcode 4/5 and iOS 5 through 7. As mentioned above, the project does not support ARC yet.

