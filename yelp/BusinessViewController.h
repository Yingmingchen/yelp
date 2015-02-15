//
//  BusinessViewController.h
//  yelp
//
//  Created by Yingming Chen on 2/14/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface BusinessViewController : UIViewController

@property (nonatomic, strong) Business * business;

- (void)updateReviewData:(NSDictionary *)dictionary;

@end
