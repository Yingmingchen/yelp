//
//  Business.h
//  yelp
//
//  Created by Yingming Chen on 2/10/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Business : NSObject

@property (nonatomic, strong) NSString *businessId;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *displayAddress;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSDictionary *reviewData;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateReviewData:(NSDictionary *)dictionary;

+ (NSMutableArray *)businessesWithDictionaries:(NSArray *)dictionaries;

@end
