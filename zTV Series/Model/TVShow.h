//
//  TVShow.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVShow : NSObject

@property (nonatomic) NSInteger sid;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *genres;

@property (nonatomic, strong) NSString *overview;

@property (nonatomic, strong) NSString *channel;

@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong) NSString *premiered;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *rating;

@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, strong) NSArray *episodes;

- (instancetype)initWithDict:(id)dict;

+ (NSMutableArray <TVShow *> *)returnArrayFromJSONStructure:(id)json;

@end
