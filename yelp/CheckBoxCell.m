//
//  CheckBoxCell.m
//  yelp
//
//  Created by Yingming Chen on 2/12/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "CheckBoxCell.h"

@interface CheckBoxCell ()

- (IBAction)onTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *downIconView;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (nonatomic, assign) BOOL arrowState;

@end

// unchecked icon color: B0B0B0
// checked icon color: 45C7FF
@implementation CheckBoxCell

- (void)awakeFromNib {
    // Initialization code
    self.checked = NO;
    self.downIconView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTouch:(id)sender {
    [self setChecked:!self.checked];
    // Trigger the event to delegate
    [self.delegate checkBoxCell:self didUpdateValue:self.checked];
}

- (void)setChecked:(BOOL)checked {
    self.checkButton.hidden = NO;
    self.downIconView.hidden = YES;
    _checked = checked;
    if (self.checked) {
        [self.checkButton.imageView setImage:[UIImage imageNamed:@"checkbox-dot-32"]];
    } else {
        [self.checkButton.imageView setImage:[UIImage imageNamed:@"unchecked-32"]];
    }
}

- (void)setArrowDown {
    self.checkButton.hidden = YES;
    self.downIconView.hidden = NO;
}

@end
