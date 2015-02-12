//
//  SearchViewController.m
//  yelp
//
//  Created by Yingming Chen on 2/10/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "SearchViewController.h"
#import "FiltersViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"

NSString * const kYelpConsumerKey = @"oiUpkB3MS2bufrS_c8__Hw";
NSString * const kYelpConsumerSecret = @"tHS2EKnurGCy939lZUfX8fuYNqs";
NSString * const kYelpToken = @"g3TcGKOZKSmEDWmzRvhJX4WGxeqYij4w";
NSString * const kYelpTokenSecret = @"-O0BBLNTCMKehCgYbn6rpAnBskE";


@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControlerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) FiltersViewController *fvc;
@property (nonatomic, strong) NSArray *businesses;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        self.fvc = [[FiltersViewController alloc] init];
        // Set myself as the receiver of the filter change event
        self.fvc.delegate = self;
        
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Yelp";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    
    cell.business = self.businesses[indexPath.row];
    // Disable selection highlighting color
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Filter delegate methods

- (void)filtersViewController:(FiltersViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    NSLog(@"filter change %@", filters);
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
}

#pragma mark - private methods

- (void)onFilterButton {
//    FiltersViewController *fvc = [[FiltersViewController alloc] init];
//    // Set myself as the receiver of the filter change event
//    fvc.delegate = self;
    
    // Consider remembering this fvc so that we can reuse it so that the filter
    // state will stay.
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.fvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessDictionaries];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
