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

typedef NS_ENUM(NSInteger, FilterSectionIndex) {
    FilterSectionIndexMostPopular = 0,
    FilterSectionIndexDistance    = 1,
    FilterSectionIndexSortBy      = 2,
    FilterSectionIndexCategory    = 3
};

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, FilterCellDelegate, CheckBoxCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, readonly) NSDictionary *filters;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) BOOL showFullCategories;

@property (nonatomic, strong) NSArray *sortModes;
@property (nonatomic, assign) NSInteger sortFilterIndex;
@property (nonatomic, assign) BOOL showFullSortModes;

@property (nonatomic, strong) NSArray *distanceChoices;
@property (nonatomic, assign) NSInteger radiusFilterIndex;
@property (nonatomic, assign) BOOL showFullDistanceChoices;

@property (nonatomic, strong) NSArray *mostPopularChoices;
@property (nonatomic, assign) BOOL dealsFilter;

- (void) initFilteringData;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        [self initFilteringData];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup navigation items
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    // Setup table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil] forCellReuseIdentifier:@"FilterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckBoxCell" bundle:nil] forCellReuseIdentifier:@"CheckBoxCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlaceHolderCell" bundle:nil] forCellReuseIdentifier:@"PlaceHolderCell"];
    self.tableView.rowHeight = 40;
    
    self.title = @"Filters";
    [self setNavigationBarStyle];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell delegate methods

- (void)filterCell:(FilterCell *)filterCell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:filterCell];

    switch (indexPath.section) {
        case FilterSectionIndexMostPopular:
            self.dealsFilter = !self.dealsFilter;
            break;
        case FilterSectionIndexCategory:
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
        case FilterSectionIndexDistance:
            if (value) {
                // Remember the selected distance filter
                self.radiusFilterIndex = indexPath.row;
            } else {
                // Otherwise, reset to default
                self.radiusFilterIndex = 0;
            }
            self.showFullDistanceChoices = NO;
            break;
        case FilterSectionIndexSortBy:
            if (value) {
                self.sortFilterIndex = indexPath.row;
            } else {
                self.sortFilterIndex = 0;
            }
            self.showFullSortModes = NO;
            break;
        default:
            break;
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case FilterSectionIndexMostPopular: // Most Popular
            return self.mostPopularChoices.count;
        case FilterSectionIndexDistance:
            if (self.showFullDistanceChoices) {
                return self.distanceChoices.count;
            } else {
                return 1;
            }
        case FilterSectionIndexSortBy:
            if (self.showFullSortModes) {
                return self.sortModes.count;
            } else {
                return 1;
            }
        case FilterSectionIndexCategory:
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
    FilterCell *filterCell;
    CheckBoxCell *checkBoxCell;
    PlaceHolderCell *placeHolderCell;

    switch (indexPath.section) {
        case FilterSectionIndexMostPopular: // Most Popular
            filterCell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
            filterCell.delegate = self;
            filterCell.titleLabel.text = self.mostPopularChoices[indexPath.row][@"name"];
            filterCell.on = NO;
            return filterCell;
        case FilterSectionIndexDistance:
            checkBoxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
            checkBoxCell.delegate = self;
            if (self.showFullDistanceChoices) {
                checkBoxCell.titleLabel.text = self.distanceChoices[indexPath.row][@"name"];
                if (self.radiusFilterIndex == indexPath.row) {
                    checkBoxCell.checked = YES;
                } else {
                    checkBoxCell.checked = NO;
                }
            } else {
                checkBoxCell.titleLabel.text = self.distanceChoices[self.radiusFilterIndex][@"name"];
                [checkBoxCell setArrowDown];
            }
            return checkBoxCell;
        case FilterSectionIndexSortBy:
            checkBoxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
            checkBoxCell.delegate = self;
            if (self.showFullSortModes) {
                checkBoxCell.titleLabel.text = self.sortModes[indexPath.row][@"name"];
                if (self.sortFilterIndex == indexPath.row) {
                    checkBoxCell.checked = YES;
                } else {
                    checkBoxCell.checked = NO;
                }
            } else {
                checkBoxCell.titleLabel.text = self.sortModes[self.sortFilterIndex][@"name"];
                [checkBoxCell setArrowDown];
            }
            return checkBoxCell;
        case FilterSectionIndexCategory:
            if (self.showFullCategories) {
                if (indexPath.row == self.categories.count) {
                    placeHolderCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    placeHolderCell.titleLabel.text = @"See Less";
                    return placeHolderCell;
                }
            } else {
                if (self.categories.count == indexPath.row || indexPath.row == 5) {
                    placeHolderCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceHolderCell"];
                    placeHolderCell.titleLabel.text = @"See All";
                    return placeHolderCell;
                }
            }
            filterCell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
            filterCell.delegate = self;
            
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
        case FilterSectionIndexDistance:
            if (!self.showFullDistanceChoices) {
                self.showFullDistanceChoices = YES;
                reloadNeeded = YES;
            }
            break;
        case FilterSectionIndexSortBy:
            if (!self.showFullSortModes) {
                self.showFullSortModes = YES;
                reloadNeeded = YES;
            }
            break;
        case FilterSectionIndexCategory:
            if (indexPath.row + 1 == [tableView numberOfRowsInSection:FilterSectionIndexCategory]) {
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

#pragma mark - private methods

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

- (void)initFilteringData {
    self.selectedCategories = [NSMutableSet set];
    self.sectionTitles = [NSArray arrayWithObjects:@"Most Popular", @"Distance", @"Sort by", @"Category", nil];
    self.sortFilterIndex = 0;
    self.radiusFilterIndex = 0;
    self.dealsFilter = NO;
    
    self.showFullCategories = NO;
    self.showFullDistanceChoices = NO;
    self.showFullSortModes = NO;
    
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

@end
