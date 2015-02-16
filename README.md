## Yelp

This is a Yelp search app using the [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api).

It is only optimized for iPhone 6.

Time spent: `25 hours`

### Features

#### Required

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height
   - [x] Custom cells should have the proper Auto Layout constraints
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [x] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), radius (meters), deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] You can use the default UISwitch for on/off states. Optional: implement a custom switch
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [x] Display some of the available Yelp categories (choose any 3-4 that you want).

#### Optional

- [x] Search results page
   - [x] Infinite scroll for restaurant results
   - [x] Implement map view of restaurant results
   - [x] Cutomize the annotation view and callout on the map
   - [x] Clicking business row or annotation callout on the map will swith to business detail page. Meantime it will trigger an API call for individual business to get review data
   - [x] Get user current location data and use it for search
   - [x] Show user current location on the map
   - [x] Pull down to refresh
- [x] Filter page
   - [x] Radius filter should expand as in the real Yelp app
   - [x] Categories should show a subset of the full list with a "See All" row to expand. Category list is here: http://www.yelp.com/developers/documentation/category_list (Links to an external site.)
   - [x] Implement "See Less" row to collapse categories
- [x] Implement the restaurant detail page.

### Walkthrough

![Video Walkthrough](yelpDemo.gif)

Credits
---------
* [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api)
* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
* [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
