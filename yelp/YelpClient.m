//
//  YelpClient.m
//  yelp
//
//  Created by Yingming Chen on 2/10/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "YelpClient.h"

@implementation YelpClient

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken accessSecret:(NSString *)accessSecret {
    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v2/"];
    self = [super initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
    if (self) {
        BDBOAuthToken *token = [BDBOAuthToken tokenWithToken:accessToken secret:accessSecret expiration:nil];
        [self.requestSerializer saveAccessToken:token];
    }
    return self;
}

- (AFHTTPRequestOperation *)searchWithTerm:(NSString *)term userLocation:(CLLocationCoordinate2D)userLocation params:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    NSDictionary *defaultParams = @{@"term": term};
    NSMutableDictionary *finalParams = [defaultParams mutableCopy];
    NSString *coordinate = [NSString stringWithFormat:@"%f,%f", userLocation.latitude, userLocation.longitude];
    [finalParams setObject:coordinate forKey:@"ll"];
    if (params) {
        [finalParams addEntriesFromDictionary:params];
    }
    return [self GET:@"search" parameters:finalParams success:success failure:failure];
}

- (AFHTTPRequestOperation *)searchBusiness:(NSString *)businessId success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *businessSearch = [NSString stringWithFormat:@"business/%@", businessId];
    return [self GET:businessSearch parameters:nil success:success failure:failure];
}

@end
