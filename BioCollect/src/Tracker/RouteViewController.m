//
//  RouteViewController.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 13/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RouteViewController.h"
#import "SightingForm.h"
#import "SpeciesAnnotation.h"
#import "SightingViewController.h"

@implementation RouteViewController
- (instancetype) initWithRoute: (NSMutableArray *) route andAnimals:(NSMutableArray *)animals {
    _route = route;
    _animals = animals;
    _annotations = [NSMutableArray new];

    self = [super init];
    return self;
}

- (void) viewDidLoad {
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height )];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeHybrid;
    [self.view addSubview: _mapView];
    [self addAnnotations];
    
    [self updateMap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnnotations) name:@"SPECIES-SIGHTING-SAVED" object:nil];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateMap) userInfo:nil repeats:YES];
}

- (void) updateMap {
    [self drawLine];
}

- (void) drawLine {
    NSInteger count = [_route count];
    // remove polyline if one exists
    [_mapView removeOverlay: _polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[count];
    int i = 0;
    for (CLLocation *point in _route) {
        coordinates[i] = point.coordinate;
        i++;
    }
    
    // create a polyline with all cooridnates
    _polyline = [MKPolyline polylineWithCoordinates:coordinates count: count];
    [_mapView addOverlay: _polyline];
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:[self zoomToAnnotationsBounds]];
    [_mapView setRegion: adjustedRegion animated:YES];
}

# pragma mark - MapView delegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if( [overlay isKindOfClass: [ MKPolyline class]] ){
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:_polyline];
        polylineView.strokeColor = [UIColor blueColor];
        polylineView.lineWidth = 8.0;
        
        return polylineView;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    UIButton *details = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //    [details addTarget:self action:@selector(viewSighting:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = details;
    SpeciesAnnotation *speciesAnnotation = annotation;
    if ( [speciesAnnotation.forms count] > 0 ) {
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[speciesAnnotation.forms[0] getImage]];
        annotationView.leftCalloutAccessoryView.contentMode = UIViewContentModeScaleAspectFit;
        annotationView.leftCalloutAccessoryView.frame = CGRectMake(0, 0, 40, annotationView.frame.size.height);
    }
    
    return annotationView;
}

- (void)mapView: (MKMapView *)mapView annotationView:(nonnull MKAnnotationView *)view calloutAccessoryControlTapped:(nonnull UIControl *)control {
    if( [view.annotation isKindOfClass:[SpeciesAnnotation class]] ) {
        SpeciesAnnotation * annotation = view.annotation;
        if ( [annotation.forms count] > 0 ) {
            SightingForm *form = annotation.forms[0];
            SightingViewController *vc = [[SightingViewController alloc] initWithForm:form];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

# pragma mark - helper function
- (MKCoordinateRegion)zoomToAnnotationsBounds
{
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (CLLocation *location in _route) {
        double annotationLat = location.coordinate.latitude;
        double annotationLong = location.coordinate.longitude;
        if (annotationLat == 0 && annotationLong == 0) continue;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 10.0, 40.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D bottomCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.mapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.longitude - rightCoord.longitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.longitude - leftCoord.longitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    if ((region.span.latitudeDelta < 0.019863) || ([_route count] < 8))
        region.span.latitudeDelta = 0.019863;
    
    if ((region.span.longitudeDelta < 0.019863) || ([_route count] < 8))
        region.span.longitudeDelta = 0.019863;
    
    return region;
}

- (void) addAnnotations {
    if ( [_animals count] > 0 ) {
        for (SightingForm *sighting in _animals) {
            SpeciesAnnotation *annotation = nil;
          
            for (SpeciesAnnotation *existingAnnotation in _annotations) {
                if ( existingAnnotation.forms[0] == sighting ) {
                    annotation = existingAnnotation;
                    break;
                }
            }
            
            if (annotation == nil) {
                annotation = [[SpeciesAnnotation alloc] init];
                if (annotation.forms == nil) {
                    annotation.forms = [NSMutableArray new];
                }
                
                [annotation.forms addObject: sighting];
                [_annotations addObject: annotation];
            }
            
            annotation.coordinate = sighting.location.coordinate;
            annotation.title = sighting.animal.displayName;
            annotation.subtitle = [sighting.animal getSubTitle];
            MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[annotation.forms[0] getImage]];
            imageView.frame = CGRectMake(0, 0, 40, annotationView.frame.size.height);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            annotationView.leftCalloutAccessoryView = imageView;
        }
        
        [self.mapView addAnnotations: _annotations];
    }
}

- (void) removeAnnotation: (SightingForm *) sighting {
    for ( SpeciesAnnotation *annotation in _annotations ) {
        if ( annotation.forms[0] == sighting ) {
            [ _mapView removeAnnotation: annotation ];
            break;
        }
    }
}

- (void) stopTimerNotification {
    [_timer invalidate];
}
@end
