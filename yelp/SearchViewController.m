//
//  SearchViewController.m
//  yelp
//
//  Created by Yingming Chen on 2/10/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "SearchViewController.h"
#import "FiltersViewController.h"
#import "BusinessViewController.h"
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

// UI components
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) FiltersViewController *fvc;
@property (nonatomic, strong) BusinessViewController *bvc;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *infiniteLoadingView;
@property (nonatomic, strong) UIImageView *myCustomImageView;

// Location service
@property (nonatomic, strong) CLLocationManager *locationManager;

// API client
@property (nonatomic, strong) YelpClient *client;

// Local data variables
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) NSMutableDictionary *searchFilters;
@property (nonatomic, strong) NSString *queryTerm;
@property (nonatomic, assign) CLLocationCoordinate2D userLocationCoordinate2D;

// Local state flags
@property (nonatomic, assign) BOOL isPullDownRefreshing;
@property (nonatomic, assign) BOOL isInfiniteLoading;
@property (nonatomic, assign) BOOL enableInfiniteLoading;
@property (nonatomic, assign) BOOL isDataFetchingTriggered;
@property (nonatomic, assign) BOOL isMapView;
@property (nonatomic, assign) NSInteger fetchingCount;

// Local functions
- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
- (void)setPreLoadingState;
- (void)setPostLoadingState;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create the API client
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        // Init local variables
        self.tableRefreshControl = nil;

        self.queryTerm = @"Restaurants";
        self.searchFilters = [NSMutableDictionary dictionary];
        self.businesses = [NSMutableArray array];
        
        self.isDataFetchingTriggered = NO;
        self.isPullDownRefreshing = NO;
        self.isInfiniteLoading = NO;
        self.fetchingCount = 0;
        self.enableInfiniteLoading = NO;
        self.infiniteLoadingView = nil;
        self.isMapView = NO;

        // Start the location tracking
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the filter view controller we will use later
    self.fvc = [[FiltersViewController alloc] init];
    self.fvc.delegate = self;
    
    // Create business detail view controller
    self.bvc = [[BusinessViewController alloc] init];
    
    // Table view setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    // Add button to filter view
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings3-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    // Add button to map view
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"geo_fence_filled-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
    // Setup search bar
    self.navigationItem.titleView = self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor lightGrayColor];
    self.searchBar.text = self.queryTerm;
    
    // Init the map view
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    // Create the image view which will be used in map callout
    self.myCustomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    // Setup the loading spinner style
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor  colorWithRed:184.0f/255.0f green:11.0f/255.0f blue:4.0f/255.0f alpha:1.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location manager methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

// Get the user location and then start fetching data based on user current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    [manager stopUpdatingLocation];
    self.userLocationCoordinate2D = currentLocation.coordinate;
    NSLog(@"current location %lf %lf", self.userLocationCoordinate2D.latitude, self.userLocationCoordinate2D.longitude);
    // Start loading data
    [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
}

#pragma mark - Map methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // TODO: update the search if location is outside of current region
}

// Customize the annotation view for businesses
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"BusinessAnnotation";
    if ([annotation isKindOfClass:[BusinessAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        }
        
        annotationView.image = [UIImage imageNamed:@"location-24-red"];
        annotationView.canShowCallout = YES;
        annotationView.annotation = annotation;
        return annotationView;
    } else {
        return nil;
    }
}

// Show customized callout for each business annotation
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // If the annotation is the user location, just return nil.
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }

    // Add a custom image to the left side of the callout.
    BusinessAnnotation *businessAnnotation = view.annotation;
    [self.myCustomImageView setImageWithURL:[NSURL URLWithString:businessAnnotation.business.imageUrl]];
    view.leftCalloutAccessoryView = self.myCustomImageView;

    // Setup listener for tapping on callout
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(onAnnotationCalloutTapped:)];
    [view addGestureRecognizer:tapGesture];
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
    
    // Trigger infinite loading if needed when reaching the last row
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

// Switch to business detail view when row selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Business *business = self.businesses[indexPath.row];
    self.bvc.business = business;
    
    // fetch individual business data to get review info
    [self fetchBusiness:business.businessId];
    
    // Switch to detail view
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.bvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Filter view delegate methods

- (void)filtersViewController:(FiltersViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    // Save the filters to local property
    self.searchFilters = [filters mutableCopy];
    [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
}

#pragma mark - search bar control

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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

// Switch to filter view
- (void)onFilterButton {
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

// Switch between map view and list view
- (void)onMapButton {
    [UIView transitionWithView:self.view
                      duration:1.0
                       options:self.isMapView ? UIViewAnimationOptionTransitionFlipFromTop :UIViewAnimationOptionTransitionFlipFromBottom
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
}

// Pull down support
- (void)onPullDownRefresh {
    if (!self.isDataFetchingTriggered) {
        self.isPullDownRefreshing = YES;
        [self fetchBusinessesWithQuery:self.queryTerm params:self.searchFilters];
    }
}

// Switch to business detail view when callout is tapped
-(void)onAnnotationCalloutTapped:(UITapGestureRecognizer *) sender
{
    MKAnnotationView *view = (MKAnnotationView*)sender.view;
    BusinessAnnotation *businessAnnotation = view.annotation;

    // Dismiss callout
    [self.mapView deselectAnnotation:businessAnnotation animated:NO];
    
    // Make API call to get business detail
    [self fetchBusiness:businessAnnotation.business.businessId];
    
    // Switch to business detail view with the data we have
    self.bvc.business = businessAnnotation.business;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.bvc];
    [self presentViewController:nvc animated:YES completion:nil];
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

// Set the UI loading indicator state if needed before making searching API calls
- (void)setPreLoadingState {
    // No need to show loading spinner for pull down refresh and infinite loading
    // since they have their own loading indicators
    if (!self.isPullDownRefreshing && !self.isInfiniteLoading) {
        // Delay showing the loading spinner otherwise it will move down a little bit
        // after keyboard resigns. See https://github.com/TransitApp/SVProgressHUD/issues/125
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isDataFetchingTriggered) {
                [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
            }
        });
    }
}

// Clear the UI loading indicator state if needed after API call returns
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
    
    // Setup pulldown refresh and infinite loading UI if we haven't done so
    if (self.fetchingCount == 1) {
        self.mapView.hidden = YES;
        [self initAutoLoadingUISupport];
    }
}

// Helper function to fetch business data via yelp API
- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    // Don't trigger multiple API calls at the same time
    if (self.isDataFetchingTriggered) {
        return;
    }
    
    [self setPreLoadingState];
    
    // Set the flag to indicate an API call is on the fly
    self.isDataFetchingTriggered = YES;

    self.fetchingCount ++;
    
    // Make the API call
    NSLog(@"searching with location %lf and params %@", self.userLocationCoordinate2D.latitude,  params);
    [self.client searchWithTerm:query userLocation:self.userLocationCoordinate2D params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        NSLog(@"respones %ld", businessDictionaries.count);
        NSDictionary *regionData = response[@"region"];
        // Setup the map region based on the result
        [self setMapViewRegion:regionData];
        
        NSMutableArray *newBusiness = [Business businessesWithDictionaries:businessDictionaries];
        // If # of the new businesses returned is less than the default limit 20, it means there is no more data
        // to retrieve for this search. Will disable infinite loading in that case.
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

// Helper function to fetch individual business data via yelp API
- (void)fetchBusiness:(NSString *)businessId {
    NSString *encodedId = [businessId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self.client searchBusiness:encodedId success:^(AFHTTPRequestOperation *operation, id response) {
        NSDictionary *businessDictionary = response;
        if ([businessDictionary[@"id"] isEqualToString:self.bvc.business.businessId]) {
            [self.bvc updateReviewData:businessDictionary];
        }
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
        point.subtitle = [NSString stringWithFormat:@"%@ - %@", business.categories, business.address];
        
        [self.mapView addAnnotation:point];
    }
}

@end
