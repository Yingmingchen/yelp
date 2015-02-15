//
//  Business.m
//  yelp
//
//  Created by Yingming Chen on 2/10/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        NSString *street = @"N/A";
        NSArray *addresses = [dictionary valueForKeyPath:@"location.address"];
        if (addresses && addresses.count > 0) {
            street = addresses[0];
        }
        NSString *neighborhood = @"N/A";
        NSArray *neighborhoods = [dictionary valueForKeyPath:@"location.neighborhoods"];
        if (neighborhoods && neighborhoods.count) {
            neighborhood = neighborhoods[0];
        }
        NSArray *displayAddresses = [dictionary valueForKeyPath:@"location.display_address"];
        
        self.displayAddress = @"";
        if (displayAddresses.count > 0) {
            self.displayAddress = [displayAddresses componentsJoinedByString:@", "];
        }
        self.businessId = dictionary[@"id"];
        self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
        self.latitude = [[dictionary valueForKeyPath:@"location.coordinate.latitude"]  floatValue];
        self.longitude = [[dictionary valueForKeyPath:@"location.coordinate.longitude"]  floatValue];
        self.phoneNumber = dictionary[@"phone"];
        [self updateReviewData:dictionary];
    }
    
    return self;
}

- (void)updateReviewData:(NSDictionary *)dictionary {
    NSArray *reviews = dictionary[@"reviews"];
    if (reviews && reviews.count > 0) {
        self.reviewData = reviews[0];
    } else {
        self.reviewData = nil;
    }
}

// Factory method
+ (NSMutableArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
