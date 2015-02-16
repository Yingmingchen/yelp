//
//  Header.h
//  yelp
//
//  Created by Yingming Chen on 2/12/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#ifndef yelp_Utils_h
#define yelp_Utils_h

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#endif
