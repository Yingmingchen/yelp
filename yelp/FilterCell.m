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
    //self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
//    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
//    self.backLayerView.layer.cornerRadius = 3;
//    self.backLayerView.clipsToBounds = YES;
//    self.backLayerView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
//    self.backLayerView.layer.borderWidth = 1.0f;
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
