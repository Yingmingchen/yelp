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
#import "Utils.h"
#import "SVProgressHUD.h"
#import <MapKit/MapKit.h>
#import "BusinessAnnotation.h"
#import "UIImageView+AFNetworking.h"

NSString * const kYelpConsumerKey = @"oiUpkB3MS2bufrS_c8__Hw";
NSString * const kYelpConsumerSecret = @"tHS2EKnurGCy939lZUfX8fuYNqs";
NSString * const kYelpToken = @"g3TcGKOZKSmEDWmzRvhJX4WGxeqYij4w";
NSString * const kYelpTokenSecret = @"-O0BBLNTCMKehCgYbn6rpAnBskE";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControlerDelegate, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) FiltersViewController *fvc;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *infiniteLoadingView;
@property (nonatomic, strong) UIImageView *myCustomImageView;


@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) NSMutableDictionary *searchFilters;
@property (nonatomic, strong) NSString *queryTerm;

@property (nonatomic, assign) BOOL isPullDownRefreshing;
@property (nonatomic, assign) BOOL isInfiniteLoading;
@property (nonatomic, assign) BOOL enableInfiniteLoading;
@property (nonatomic, assign) BOOL isDataFetchingTriggered;
@property (nonatomic, assign) BOOL isMapView;
@property (nonatomic, assign) NSInteger fetchingCount;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
- (void)setPreLoadingState;
- (void)setPostLoadingState;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        // Create the filter view controller we will use later
        self.fvc = [[FiltersViewController alloc] init];
        self.fvc.delegate = self;

        // Init local state variables
        self.queryTerm = @"Restaurants";
        self.searchFilters = [NSMutableDictionary dictionary];
        self.businesses = [NSMutableArray array];
        self.isDataFetchingTriggered = NO;
        self.isPullDownRefreshing = NO;
        self.isInfiniteLoading = NO;
        self.fetchingCount = 0;
        self.enableInfiniteLoading = NO;
        self.tableRefreshControl = nil;
        self.infiniteLoadingView = nil;
        self.isMapView = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Table view setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    // Button to filter page
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings3-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    // Button to map view
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"geo_fence_filled-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
    // Setup search bar
    self.navigationItem.titleView = self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor lightGrayColor];
    self.searchBar.text = self.queryTerm;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    self.myCustomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor  colorWithRed:184.0f/255.0f green:11.0f/255.0f blue:4.0f/255.0f alpha:1.0f]];

    // Start loading data
    [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Map methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"location change");
    // TODO: update the search if location is outside of current region
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"BusinessAnnotation";
    if ([annotation isKindOfClass:[BusinessAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        }
        
        annotationView.image = [UIImage imageNamed:@"location-24"];
        annotationView.canShowCallout = YES;
        //annotationView.animatesDrop = YES;
        annotationView.annotation = annotation;
        return annotationView;
    } else {
        return nil;
    }
    // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//    annotationView.rightCalloutAccessoryView = rightButton;
//    
//    // Add a custom image to the left side of the callout.
//    UIImageView *myCustomImageView = [[UIImageView alloc] init];
//    BusinessAnnotation *businessAnnotation = annotation;
//    NSLog(@"image url %@", businessAnnotation.business.imageUrl);
//    [myCustomImageView setImageWithURL:[NSURL URLWithString:businessAnnotation.business.imageUrl]];
//    annotationView.leftCalloutAccessoryView = myCustomImageView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Add a custom image to the left side of the callout.
    BusinessAnnotation *businessAnnotation = view.annotation;
    NSLog(@"image url %@", businessAnnotation.business.imageUrl);
    [self.myCustomImageView setImageWithURL:[NSURL URLWithString:businessAnnotation.business.imageUrl]];
    view.leftCalloutAccessoryView = self.myCustomImageView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(calloutTapped:)];
    [view addGestureRecognizer:tapGesture];
}

-(void)calloutTapped:(UITapGestureRecognizer *) sender
{
    NSLog(@"Callout was tapped");
    
    MKAnnotationView *view = (MKAnnotationView*)sender.view;
    BusinessAnnotation *businessAnnotation = view.annotation;
    NSLog(@"business id %@", businessAnnotation.business.businessId);
    [self fetchBusiness:businessAnnotation.business.businessId];
//    id <MKAnnotation> annotation = [view annotation];
//    if ([annotation isKindOfClass:[MKPointAnnotation class]])
//    {
//        [self performSegueWithIdentifier:@"annotationDetailSegue" sender:annotation];
//    }
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    Business *business = self.businesses[indexPath.row];
    business.index = indexPath.row + 1;
    cell.business = self.businesses[indexPath.row];
    
    // Disable selection highlighting color
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Trigger infinite loading if needed when reach the last row
    if ((indexPath.row == self.businesses.count - 1) && self.enableInfiniteLoading && !self.isDataFetchingTriggered) {
        // Create filters to include "offset" setting
        NSMutableDictionary *filters = [self.searchFilters mutableCopy];
        [filters setObject:@(self.businesses.count) forKey:@"offset"];
        [self.infiniteLoadingView startAnimating];
        self.isInfiniteLoading = YES;
        [self fetchBusinessesWithQuery:self.queryTerm params:filters];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Filter view delegate methods

- (void)filtersViewController:(FiltersViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    // Save the filters to local property
    self.searchFilters = [filters mutableCopy];
    NSLog(@"%@", self.searchFilters);
    [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
}

#pragma mark - search bar control

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search with %@", searchBar.text);
    // Get the queryTerm from search bar text
    self.queryTerm = searchBar.text;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
}

// Reset search bar state after cancel button clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    searchBar.text = self.queryTerm;
    [searchBar sizeToFit];
}

#pragma mark - private methods

- (void)onFilterButton {
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onMapButton {
    NSLog (@"map");
    [UIView transitionWithView:self.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromBottom//UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.tableView.hidden = !self.isMapView;
                        self.mapView.hidden = self.isMapView;
                    } completion:nil
     ];
    if (self.isMapView) {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"geo_fence_filled-25"]];
    } else {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"align_justify-25"]];
    }
    
    self.isMapView = !self.isMapView;
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    //[self setNeedsStatusBarAppearanceUpdate];
}

- (void)onPullDownRefresh {
    if (!self.isDataFetchingTriggered) {
        self.isPullDownRefreshing = YES;
        [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
    }
}

// Helper function to setup the UI for pull to refresh and infinite loading
- (void)initAutoLoadingUISupport {
    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onPullDownRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    // For infinite loading
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    self.infiniteLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.infiniteLoadingView.center = tableFooterView.center;
    [tableFooterView addSubview:self.infiniteLoadingView];
    self.tableView.tableFooterView = tableFooterView;
    self.enableInfiniteLoading = YES;
}

// Set the UI loading indicator state if needed before triggering loading
- (void)setPreLoadingState {
    // No need to show loading spinner for pull down refresh and infinite loading since they have their own
    // loading indicators
    if (!self.isPullDownRefreshing && !self.isInfiniteLoading) {
        // Delay showing the loading spinner otherwise it will jump
        // after keyboard resigns. See https://github.com/TransitApp/SVProgressHUD/issues/125
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
        });
//        [SVProgressHUD show];
    }
}

// Set the UI loading indicator state if needed after data returned from API call
- (void)setPostLoadingState {
    // Hide loading spinner
    if (!self.isPullDownRefreshing && !self.isInfiniteLoading) {
        [SVProgressHUD dismiss];
    }
    // Stop pull down refresh related loading indicator
    if (self.isPullDownRefreshing) {
        [self.tableRefreshControl endRefreshing];
        self.isPullDownRefreshing = NO;
    }
    
    // Stop infinite loading indicator
    if (self.isInfiniteLoading) {
        [self.infiniteLoadingView stopAnimating];
        self.isInfiniteLoading = NO;
    }
    
    // Setup pulldown refresh and infinite loading UI
    if (self.fetchingCount == 1) {
        self.mapView.hidden = YES;
        [self initAutoLoadingUISupport];
    }
}

// Helper function to fetch business data via yelp API
- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    if (self.isDataFetchingTriggered) {
        return;
    }
    
    [self setPreLoadingState];
    
    // Set the flag to indicate an API call is trigger
    self.isDataFetchingTriggered = YES;

    self.fetchingCount ++;
    
    // Make the API call
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];

        NSDictionary *regionData = response[@"region"];
        [self setMapViewRegion:regionData];
        
        NSLog(@"response %@", response);
        NSMutableArray *newBusiness = [Business businessesWithDictionaries:businessDictionaries];
        NSLog(@"new business %ld", newBusiness.count);
        // If # of the new businesses returned is less than the default limit 20, it means there is no more data
        // to retrieve for this search. We should disable infinite loading.
        if (newBusiness.count < 20) {
            self.enableInfiniteLoading = NO;
        } else {
            self.enableInfiniteLoading = YES;
        }
        
        // For fetching triggered by infinite loading we want to append new businesses on top of existing businesses
        if (self.isInfiniteLoading) {
            [self.businesses addObjectsFromArray:newBusiness];
            [self addAnnotations:newBusiness append:YES];
        } else {
            self.businesses = newBusiness;
            [self addAnnotations:newBusiness append:NO];
        }
        // Reload the table UI with new data
        [self.tableView reloadData];
        
        [self setPostLoadingState];
        // Reset the flag to allow future data fetching
        self.isDataFetchingTriggered = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setPostLoadingState];
        // @TODO: better error handling
        NSLog(@"error: %@", [error description]);
        self.isDataFetchingTriggered = NO;
    }];
    
}

// Helper function to fetch business data via yelp API
- (void)fetchBusiness:(NSString *)businessId {
    // Make the API call
    [self.client searchBusiness:businessId success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"business %@", response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
    
}

- (void)setMapViewRegion:(NSDictionary *)regionData {
    MKCoordinateRegion region;
    region.center.latitude = [[regionData valueForKeyPath:@"center.latitude"] floatValue];
    region.center.longitude = [[regionData valueForKeyPath:@"center.longitude"] floatValue];
    region.span.latitudeDelta = [[regionData valueForKeyPath:@"span.latitude_delta"] floatValue];
    region.span.longitudeDelta = [[regionData valueForKeyPath:@"span.longitude_delta"] floatValue];
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)addAnnotations:(NSArray *)businesses append:(BOOL)append {
    if (!append) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    for (Business *business in self.businesses) {
        CLLocationCoordinate2D  businessLocation;
        businessLocation.latitude = business.latitude;
        businessLocation.longitude = business.longitude;
        BusinessAnnotation *point = [[BusinessAnnotation alloc] initWithLocation:businessLocation];
        point.business = business;
        point.title = business.name;
        point.subtitle = business.categories;
        
        [self.mapView addAnnotation:point];
        //[self.mapView setCenterCoordinate:mycenter];
    }
}

@end
