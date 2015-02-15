//
//  MapCell.h
//  yelp
//
//  Created by Yingming Chen on 2/15/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface MapCell : UITableViewCell

- (void) setLocation:(Business *)business;

@end
