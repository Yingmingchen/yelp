//
//  FiltersViewController.m
//  yelp
//
//  Created by Yingming Chen on 2/11/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "FiltersViewController.h"
#import "FilterCell.h"
#import "CheckBoxCell.h"
#import "PlaceHolderCell.h"
#import "Utils.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, FilterCellDelegate, CheckBoxCellDelegate>

@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *sortModes;
@property (nonatomic, strong) NSArray *distanceChoices;
@property (nonatomic, strong) NSArray *mostPopularChoices;

@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) NSInteger sortFilterIndex;
@property (nonatomic, assign) NSInteger radiusFilterIndex;
@property (nonatomic, assign) BOOL dealsFilter;

@property (nonatomic, assign) BOOL showFullCategories;
@property (nonatomic, assign) BOOL showFullSortModes;
@property (nonatomic, assign) BOOL showFullDistanceChoices;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void) initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        [self initCategories];
        self.selectedCategories = [NSMutableSet set];
        self.sectionTitles = [NSArray arrayWithObjects:@"Most Popular", @"Distance", @"Sort by", @"Category", nil];
        self.sortFilterIndex = 0;
        self.radiusFilterIndex = 0;
        self.dealsFilter = NO;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil] forCellReuseIdentifier:@"FilterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckBoxCell" bundle:nil] forCellReuseIdentifier:@"CheckBoxCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlaceHolderCell" bundle:nil] forCellReuseIdentifier:@"PlaceHolderCell"];
    
    self.showFullCategories = NO;
    self.showFullDistanceChoices = NO;
    self.showFullSortModes = NO;
    
    self.tableView.rowHeight = 40;
    
    self.title = @"Filters";
    [self setNavigationBarStyle];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void) setNavigationBarStyle {
    UIColor *myColor = UIColorFromRGB(0X45C7FF);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.backgroundColor = myColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.showFullCategories = NO;
    self.showFullDistanceChoices = NO;
    self.showFullSortModes = NO;
    [self setNavigationBarStyle];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.showFullCategories = NO;
    self.showFullDistanceChoices = NO;
    self.showFullSortModes = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell delegate methods

- (void)filterCell:(FilterCell *)filterCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:filterCell];
    
    switch (indexPath.section) {
        case 0:
            self.dealsFilter = !self.dealsFilter;
            break;
        case 3:
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        default:
            break;
    }
}

- (void)checkBoxCell:(CheckBoxCell *)checkBoxCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:checkBoxCell];
    
    switch (indexPath.section) {
        case 1:
            if (value) {
                self.radiusFilterIndex = indexPath.row;
            } else {
                self.radiusFilterIndex = 0;
            }
            self.showFullDistanceChoices = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 2:
            if (value) {
                self.sortFilterIndex = indexPath.row;
            } else {
                self.sortFilterIndex = 0;
            }
            self.showFullSortModes = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 10;
//    } else {
//        return 10;
//    }
//}

//// Custom the header @TODO create a separate view for it
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
//    /* Create custom view to display section header... */
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
//    [label setFont:[UIFont boldSystemFontOfSize:12]];
//    NSString *string = [self.sectionTitles objectAtIndex:section];
//    /* Section header is in 0th index... */
//    [label setText:string];
//    [view addSubview:label];
//    //[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // Most Popular
            return self.mostPopularChoices.count;
        case 1:
            if (self.showFullDistanceChoices) {
                return self.distanceChoices.count;
            } else {
                return 1;
            }
        case 2:
            if (self.showFullSortModes) {
                return self.sortModes.count;
            } else {
                return 1;
            }
        case 3:
            if (!self.showFullCategories) {
                if (self.categories.count > 5)
                    return 6;
            }
            
            return self.categories.count + 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    FilterCell *filterCell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
    CheckBoxCell *checkBoxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
    checkBoxCell.delegate = self;
    filterCell.delegate = self;

    switch (indexPath.section) {
        case 0: // Most Popular
            filterCell.titleLabel.text = self.mostPopularChoices[indexPath.row][@"name"];
            filterCell.on = NO;
            return filterCell;
        case 1:
            if (self.showFullDistanceChoices) {
                checkBoxCell.titleLabel.text = self.distanceChoices[indexPath.row][@"name"];
                if (self.radiusFilterIndex == indexPath.row) {
                    checkBoxCell.checked = YES;
                } else {
                    checkBoxCell.checked = NO;
                }
            } else {
                checkBoxCell.titleLabel.text = self.distanceChoices[self.radiusFilterIndex][@"name"];
                checkBoxCell.checked = YES;
                [checkBoxCell setArrowDown];
            }
            return checkBoxCell;
        case 2:
            if (self.showFullSortModes) {
                checkBoxCell.titleLabel.text = self.sortModes[indexPath.row][@"name"];
                if (self.sortFilterIndex == indexPath.row) {
                    checkBoxCell.checked = YES;
                } else {
                    checkBoxCell.checked = NO;
                }
            } else {
                checkBoxCell.titleLabel.text = self.sortModes[self.sortFilterIndex][@"name"];
                checkBoxCell.checked = YES;
                [checkBoxCell setArrowDown];
            }
            return checkBoxCell;
        case 3:
            if (self.showFullCategories) {
                if (indexPath.row == self.categories.count) {
                    PlaceHolderCell *placeHolderCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    placeHolderCell.titleLabel.text = @"See Less";
                    return placeHolderCell;
                }
            } else {
                if (self.categories.count == indexPath.row || indexPath.row == 5) {
                    PlaceHolderCell *placeHolderCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    placeHolderCell.titleLabel.text = @"See All";
                    return placeHolderCell;
                }
            }
            
            filterCell.titleLabel.text = self.categories[indexPath.row][@"name"];
            // use the saved data to update the switch UI
            filterCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            return filterCell;
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BOOL reloadNeeded = NO;
    switch (indexPath.section) {
        case 1:
            if (!self.showFullDistanceChoices) {
                self.showFullDistanceChoices = YES;
                reloadNeeded = YES;
            }
            break;
        case 2:
            if (!self.showFullSortModes) {
                self.showFullSortModes = YES;
                reloadNeeded = YES;
            }
            break;
        case 3:
            if (indexPath.row + 1 == [tableView numberOfRowsInSection:3]) {
                self.showFullCategories = !self.showFullCategories;
                reloadNeeded = YES;
            }
            break;
        default:
            break;
    }
    
    if (reloadNeeded) {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//// for section border?
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//        CGFloat cornerRadius = 5.f;
//        cell.backgroundColor = UIColor.clearColor;
//        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//        CGMutablePathRef pathRef = CGPathCreateMutable();
//        CGRect bounds = CGRectInset(cell.bounds, 10, 0);
//        BOOL addLine = NO;
//        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//        } else if (indexPath.row == 0) {
//            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//            addLine = YES;
//        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//        } else {
//            CGPathAddRect(pathRef, nil, bounds);
//            addLine = YES;
//        }
//        layer.path = pathRef;
//        CFRelease(pathRef);
//        //set the border color
//        layer.strokeColor = [UIColor lightGrayColor].CGColor;
//        //set the border width
//        layer.lineWidth = 1;
//        layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.0f].CGColor;
//        
//        
//        if (addLine == YES) {
//            CALayer *lineLayer = [[CALayer alloc] init];
//            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
//            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
//            [layer addSublayer:lineLayer];
//        }
//        
//        UIView *testView = [[UIView alloc] initWithFrame:bounds];
//        [testView.layer insertSublayer:layer atIndex:0];
//        testView.backgroundColor = UIColor.clearColor;
//        cell.backgroundView = testView;
//    }
//}

#pragma mark - private methods

- (NSInteger)getFilterSectionIndex:(NSString *)sectionTitle {
    NSInteger index = [self.sectionTitles indexOfObject:sectionTitle];
    // could be NSNotFound
    return index;
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    [filters setObject:@(self.sortFilterIndex) forKey:@"sort"];
    NSInteger radiusInMeter = [self.distanceChoices[self.radiusFilterIndex][@"code"] integerValue];
    NSLog(@"radiusMeter %ld", radiusInMeter);
    [filters setObject:@(radiusInMeter) forKey:@"radius_filter"];
    if (self.dealsFilter) {
        [filters setObject:@"true" forKey:@"deals_filter"];
    }
    
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    // trigger the event
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.mostPopularChoices = @[@{@"name" : @"Offering a Deal", @"code": @"deals_filter"}];
    self.sortModes = @[@{@"name" : @"Best matched", @"code": @(0)},
                       @{@"name" : @"Distance", @"code": @(1)},
                       @{@"name" : @"Highest Rated", @"code": @(2)}];
    self.distanceChoices = @[@{@"name" : @"Auto", @"code": @(40000)},
                       @{@"name" : @"0.3 miles", @"code": @(483)},
                       @{@"name" : @"1 mile", @"code": @(1609)},
                       @{@"name" : @"5 miles", @"code": @(8047)},
                       @{@"name" : @"20 miles", @"code": @(32187)}];
    self.categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                            @{@"name" : @"African", @"code": @"african" },
                            @{@"name" : @"American, New", @"code": @"newamerican" },
                            @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                            @{@"name" : @"Arabian", @"code": @"arabian" },
                            @{@"name" : @"Argentine", @"code": @"argentine" },
                            @{@"name" : @"Armenian", @"code": @"armenian" },
                            @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                            @{@"name" : @"Asturian", @"code": @"asturian" },
                            @{@"name" : @"Australian", @"code": @"australian" },
                            @{@"name" : @"Austrian", @"code": @"austrian" },
                            @{@"name" : @"Baguettes", @"code": @"baguettes" },
                            @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                            @{@"name" : @"Barbeque", @"code": @"bbq" },
                            @{@"name" : @"Basque", @"code": @"basque" },
                            @{@"name" : @"Bavarian", @"code": @"bavarian" },
                            @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                            @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                            @{@"name" : @"Beisl", @"code": @"beisl" },
                            @{@"name" : @"Belgian", @"code": @"belgian" },
                            @{@"name" : @"Bistros", @"code": @"bistros" },
                            @{@"name" : @"Black Sea", @"code": @"blacksea" },
                            @{@"name" : @"Brasseries", @"code": @"brasseries" },
                            @{@"name" : @"Brazilian", @"code": @"brazilian" },
                            @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                            @{@"name" : @"British", @"code": @"british" },
                            @{@"name" : @"Buffets", @"code": @"buffets" },
                            @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                            @{@"name" : @"Burgers", @"code": @"burgers" },
                            @{@"name" : @"Burmese", @"code": @"burmese" },
                            @{@"name" : @"Cafes", @"code": @"cafes" },
                            @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                            @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                            @{@"name" : @"Cambodian", @"code": @"cambodian" },
                            @{@"name" : @"Canadian", @"code": @"New)" },
                            @{@"name" : @"Canteen", @"code": @"canteen" },
                            @{@"name" : @"Caribbean", @"code": @"caribbean" },
                            @{@"name" : @"Catalan", @"code": @"catalan" },
                            @{@"name" : @"Chech", @"code": @"chech" },
                            @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                            @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                            @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                            @{@"name" : @"Chilean", @"code": @"chilean" },
                            @{@"name" : @"Chinese", @"code": @"chinese" },
                            @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                            @{@"name" : @"Corsican", @"code": @"corsican" },
                            @{@"name" : @"Creperies", @"code": @"creperies" },
                            @{@"name" : @"Cuban", @"code": @"cuban" },
                            @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                            @{@"name" : @"Cypriot", @"code": @"cypriot" },
                            @{@"name" : @"Czech", @"code": @"czech" },
                            @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                            @{@"name" : @"Danish", @"code": @"danish" },
                            @{@"name" : @"Delis", @"code": @"delis" },
                            @{@"name" : @"Diners", @"code": @"diners" },
                            @{@"name" : @"Dumplings", @"code": @"dumplings" },
                            @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                            @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                            @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                            @{@"name" : @"Filipino", @"code": @"filipino" },
                            @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                            @{@"name" : @"Fondue", @"code": @"fondue" },
                            @{@"name" : @"Food Court", @"code": @"food_court" },
                            @{@"name" : @"Food Stands", @"code": @"foodstands" },
                            @{@"name" : @"French", @"code": @"french" },
                            @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                            @{@"name" : @"Galician", @"code": @"galician" },
                            @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                            @{@"name" : @"Georgian", @"code": @"georgian" },
                            @{@"name" : @"German", @"code": @"german" },
                            @{@"name" : @"Giblets", @"code": @"giblets" },
                            @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                            @{@"name" : @"Greek", @"code": @"greek" },
                            @{@"name" : @"Halal", @"code": @"halal" },
                            @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                            @{@"name" : @"Heuriger", @"code": @"heuriger" },
                            @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                            @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                            @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                            @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                            @{@"name" : @"Hungarian", @"code": @"hungarian" },
                            @{@"name" : @"Iberian", @"code": @"iberian" },
                            @{@"name" : @"Indian", @"code": @"indpak" },
                            @{@"name" : @"Indonesian", @"code": @"indonesian" },
                            @{@"name" : @"International", @"code": @"international" },
                            @{@"name" : @"Irish", @"code": @"irish" },
                            @{@"name" : @"Island Pub", @"code": @"island_pub" },
                            @{@"name" : @"Israeli", @"code": @"israeli" },
                            @{@"name" : @"Italian", @"code": @"italian" },
                            @{@"name" : @"Japanese", @"code": @"japanese" },
                            @{@"name" : @"Jewish", @"code": @"jewish" },
                            @{@"name" : @"Kebab", @"code": @"kebab" },
                            @{@"name" : @"Korean", @"code": @"korean" },
                            @{@"name" : @"Kosher", @"code": @"kosher" },
                            @{@"name" : @"Kurdish", @"code": @"kurdish" },
                            @{@"name" : @"Laos", @"code": @"laos" },
                            @{@"name" : @"Laotian", @"code": @"laotian" },
                            @{@"name" : @"Latin American", @"code": @"latin" },
                            @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                            @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                            @{@"name" : @"Malaysian", @"code": @"malaysian" },
                            @{@"name" : @"Meatballs", @"code": @"meatballs" },
                            @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                            @{@"name" : @"Mexican", @"code": @"mexican" },
                            @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                            @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                            @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                            @{@"name" : @"Modern European", @"code": @"modern_european" },
                            @{@"name" : @"Mongolian", @"code": @"mongolian" },
                            @{@"name" : @"Moroccan", @"code": @"moroccan" },
                            @{@"name" : @"New Zealand", @"code": @"newzealand" },
                            @{@"name" : @"Night Food", @"code": @"nightfood" },
                            @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                            @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                            @{@"name" : @"Oriental", @"code": @"oriental" },
                            @{@"name" : @"Pakistani", @"code": @"pakistani" },
                            @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                            @{@"name" : @"Parma", @"code": @"parma" },
                            @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                            @{@"name" : @"Peruvian", @"code": @"peruvian" },
                            @{@"name" : @"Pita", @"code": @"pita" },
                            @{@"name" : @"Pizza", @"code": @"pizza" },
                            @{@"name" : @"Polish", @"code": @"polish" },
                            @{@"name" : @"Portuguese", @"code": @"portuguese" },
                            @{@"name" : @"Potatoes", @"code": @"potatoes" },
                            @{@"name" : @"Poutineries", @"code": @"poutineries" },
                            @{@"name" : @"Pub Food", @"code": @"pubfood" },
                            @{@"name" : @"Rice", @"code": @"riceshop" },
                            @{@"name" : @"Romanian", @"code": @"romanian" },
                            @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                            @{@"name" : @"Rumanian", @"code": @"rumanian" },
                            @{@"name" : @"Russian", @"code": @"russian" },
                            @{@"name" : @"Salad", @"code": @"salad" },
                            @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                            @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                            @{@"name" : @"Scottish", @"code": @"scottish" },
                            @{@"name" : @"Seafood", @"code": @"seafood" },
                            @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                            @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                            @{@"name" : @"Singaporean", @"code": @"singaporean" },
                            @{@"name" : @"Slovakian", @"code": @"slovakian" },
                            @{@"name" : @"Soul Food", @"code": @"soulfood" },
                            @{@"name" : @"Soup", @"code": @"soup" },
                            @{@"name" : @"Southern", @"code": @"southern" },
                            @{@"name" : @"Spanish", @"code": @"spanish" },
                            @{@"name" : @"Steakhouses", @"code": @"steak" },
                            @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                            @{@"name" : @"Swabian", @"code": @"swabian" },
                            @{@"name" : @"Swedish", @"code": @"swedish" },
                            @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                            @{@"name" : @"Tabernas", @"code": @"tabernas" },
                            @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                            @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                            @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                            @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                            @{@"name" : @"Thai", @"code": @"thai" },
                            @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                            @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                            @{@"name" : @"Trattorie", @"code": @"trattorie" },
                            @{@"name" : @"Turkish", @"code": @"turkish" },
                            @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                            @{@"name" : @"Uzbek", @"code": @"uzbek" },
                            @{@"name" : @"Vegan", @"code": @"vegan" },
                            @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                            @{@"name" : @"Venison", @"code": @"venison" },
                            @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                            @{@"name" : @"Wok", @"code": @"wok" },
                            @{@"name" : @"Wraps", @"code": @"wraps" },
                            @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
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
