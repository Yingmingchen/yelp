//
//  MapCell.m
//  yelp
//
//  Created by Yingming Chen on 2/15/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "MapCell.h"
#import <MapKit/MapKit.h>

@interface MapCell () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *AddressLabel;

@end

@implementation MapCell

- (void)awakeFromNib {
    // Initialization code
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    // Disable selection highlighting color
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Map methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"location cell change");
    self.mapView.showsUserLocation = YES;
    // TODO: update the search if location is outside of current region
}


- (void) setLocation:(Business *)business {
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(business.latitude, business.longitude);
    CLLocationDistance centerToBorderMeters = 500;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoord,
                                                                   centerToBorderMeters * 2,   //vertical span
                                                                   centerToBorderMeters * 2);  //horizontal span
    
    [self.mapView setRegion:region animated:YES];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:centerCoord];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:annotation];
    self.AddressLabel.text = business.displayAddress;
}

@end
