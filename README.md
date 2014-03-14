ARClusteredMapView
==================

Purpose
-------

Originally developed for [Foodish](http://www.foodishapp.com/), `ARClusteredMapView` serves as a drop-in replacement for `MKMapView`, providing animated clustering of `MKAnnotationViews`.

I have decided to share this class here since it provides decent functionality in Foodish and was a fitting ingredient in my [talk on MapKit at AltTechTalks Berlin](http://cloud.alexrepty.com/3R330m053t1J) on December 11th, 2013.

Since I'm giving a talk on MapKit at [NSConference 2014](http://www.nsconference.com/), I have decided to add more functionality to `ARClusteredMapView` and share it with the world.

Bug reports and/or pull requests welcome.

Usage
-----

* Start using the `ARClusteredMapView` class as a replacement for the `MKMapView` instance you would like to have clustering support for.
* Make sure that any annotations you add to the view inherit from the `ARClusteredAnnotation` class, which provides support for managing annotation ownership.
* Whenever appropriate (i.e. in `-mapView:regionDidChangeAnimated:`), call `ARClusteredMapView`'s `-updateClustering` method.
* In your `MKMapViewDelegate` implementation, make sure you call `-animateAnnotationViews:` (supplied with an `NSArray` of annotation views) to make sure that newly inserted `MKAnnotationView` instances animate correctly.
* If you use custom `MKAnnotationView` subclasses, make sure to set `ARClusteredMapView`'s `annotationViewSize` and `annotationViewAnchorPoint` properties to appropriate values. This will make sure that annotation views don't obscure one another and will be properly clustered at all times.

Todo
----

While `ARClusteredMapView` has recently been upgraded to use ARC, I'm sure it still has some other bugs which don't manifest in Foodish and/or the examples in my talks and I hope to eliminate these with some help from the community. When those conditions have been met, I will create a podspec and submit the app to [CocoaPods](http://www.cocoapods.org/).

Scope
-----

I have recently upgraded the project and set its restrictions to a deployment target of >= iOS 7.0, which I've only tested using Xcode 5 so far. It has originally been developed to work with iOS versions as low as 4.2, so it should work with older versions with just minimal amounts of retrofitting.

