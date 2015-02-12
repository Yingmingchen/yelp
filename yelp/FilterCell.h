//
//  FilterCell.h
//  yelp
//
//  Created by Yingming Chen on 2/11/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterCell;

@protocol FilterCellDelegate <NSObject>

- (void)filterCell:(FilterCell *)filterCell didUpdateValue:(BOOL)value;

@end

@interface FilterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<FilterCellDelegate> delegate;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
