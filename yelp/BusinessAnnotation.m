//
//  BusinessAnnotation.m
//  yelp
//
//  Created by Yingming Chen on 2/14/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "BusinessAnnotation.h"

@implementation BusinessAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (void)setTitle:(NSString *)titleString {
    title = titleString;
}

- (void)setSubtitle:(NSString *)subtitleString {
    subtitle = subtitleString;
}

@end