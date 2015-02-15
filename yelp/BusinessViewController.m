//
//  BusinessViewController.m
//  yelp
//
//  Created by Yingming Chen on 2/14/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "BusinessViewController.h"
#import "UIImageView+AFNetworking.h"
#import "BusinessCell.h"
#import "MapCell.h"
#import "ContactInfoCell.h"
#import "ReviewCell.h"
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, BusinessViewSectionIndex) {
    BusinessViewSectionIndexIntro       = 0,
    BusinessViewSectionIndexContact     = 1,
    BusinessViewSectionIndexLocation    = 2,
    BusinessViewSectionIndexReview      = 3
};

@interface BusinessViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Setup navigation items
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButton)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MapCell" bundle:nil] forCellReuseIdentifier:@"MapCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactInfoCell" bundle:nil] forCellReuseIdentifier:@"ContactInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReviewCell" bundle:nil] forCellReuseIdentifier:@"ReviewCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    [self setNavigationBarStyle];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setNavigationBarStyle {
    //UIColor *myColor = UIColorFromRGB(0X45C7FF);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor  colorWithRed:184.0f/255.0f green:11.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)onSearchButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// custom setter
- (void)setBusiness:(Business *)business {
    _business = business;
    self.title = business.name;
    [self.tableView reloadData];
}

- (void)updateReviewData:(NSDictionary *)dictionary {
    [self.business updateReviewData:dictionary];
    [self.tableView reloadData];
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [self.sectionTitles objectAtIndex:section];
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case BusinessViewSectionIndexIntro:
            return 1;
        case BusinessViewSectionIndexContact:
            return 1;
        case BusinessViewSectionIndexLocation:
            return 1;
        case BusinessViewSectionIndexReview:
            if (self.business.reviewData) {
                return 1;
            }
            return 0;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == BusinessViewSectionIndexContact) {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:self.business.phoneNumber];
        NSLog(@"call %@", phoneNumber);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == BusinessViewSectionIndexIntro) {
        BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
        cell.business = self.business;
        // Disable selection highlighting color
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == BusinessViewSectionIndexLocation) {
        MapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapCell"];
        [cell setLocation:self.business];
        // Disable selection highlighting color
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == BusinessViewSectionIndexContact) {
        ContactInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactInfoCell"];
        cell.contentLabel.text = self.business.phoneNumber;
        // Disable selection highlighting color
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == BusinessViewSectionIndexReview) {
        ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
        [cell setReviewWithDictionary:self.business.reviewData];
        // Disable selection highlighting color
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

@end
