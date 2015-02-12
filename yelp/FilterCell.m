//
//  FilterCell.m
//  yelp
//
//  Created by Yingming Chen on 2/11/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "FilterCell.h"

@interface FilterCell ()

@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
- (IBAction)switchValueChanged:(id)sender;

@end

@implementation FilterCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self.filterSwitch setOn:on animated:animated];
}


- (IBAction)switchValueChanged:(id)sender {
    // Trigger the event to delegate
    [self.delegate filterCell:self didUpdateValue:self.filterSwitch.on];
}
@end
