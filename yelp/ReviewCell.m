//
//  ReviewCell.m
//  yelp
//
//  Created by Yingming Chen on 2/15/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "ReviewCell.h"
#import "UIImageView+AFNetworking.h"

@interface ReviewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UILabel *timeCreated;
@property (weak, nonatomic) IBOutlet UILabel *reviewTextLabel;

@end

@implementation ReviewCell

- (void)awakeFromNib {
    // Round the image corner
    self.userImage.layer.cornerRadius = 25;
    self.userImage.clipsToBounds = YES;
    
    // Disable selection highlighting color
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setReviewWithDictionary:(NSDictionary *)dictionary {
    NSString *userImageUrl = [dictionary valueForKeyPath:@"user.image_url"];
    [self.userImage setImageWithURL:[NSURL URLWithString:userImageUrl]];
    self.userName.text = [dictionary valueForKeyPath:@"user.name"];
    NSString *ratingImageUrl = dictionary[@"rating_image_url"];
    [self.ratingImage setImageWithURL:[NSURL URLWithString:ratingImageUrl]];
    self.reviewTextLabel.text = dictionary[@"excerpt"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"time_created"] integerValue]];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    self.timeCreated.text = formattedDateString;
}

@end
