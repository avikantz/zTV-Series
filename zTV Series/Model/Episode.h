//
//  Episode.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episode : NSObject

@property (nonatomic) NSInteger sid;

@property (nonatomic) NSInteger sno;

@property (nonatomic) NSInteger eno;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *overview;

@property (nonatomic, strong) NSString *airdate;

@property (nonatomic, strong) NSURL *imageURL;

- (TVShow *)show;

- (instancetype)initWithDict:(id)dict;

+ (NSMutableArray <Episode *> *)returnArrayFromJSONStructure:(id)json;

@end
