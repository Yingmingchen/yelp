//
//  FiltersViewController.h
//  yelp
//
//  Created by Yingming Chen on 2/11/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaration so that delete protocol can refer to it
@class FiltersViewController;

@protocol FiltersViewControlerDelegate <NSObject>

- (void)filtersViewController:(FiltersViewController *)filterViewController didChangeFilters:(NSDictionary *)filters;

@end

@interface FiltersViewController : UIViewController

@property (nonatomic, weak) id<FiltersViewControlerDelegate> delegate;

@end
