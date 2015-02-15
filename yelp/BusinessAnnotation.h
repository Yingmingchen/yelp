//
//  businessAnnotation.h
//  yelp
//
//  Created by Yingming Chen on 2/14/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Business.h"

@interface BusinessAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

// Other methods and properties.
@property (nonatomic, strong) Business * business;

- (void)setTitle:(NSString *)titleString;
- (void)setSubtitle:(NSString *)subtitleString;

@end

