//
//  Comment.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVShow, Episode, ZUser;

@interface Comment : NSObject

@property (nonatomic) NSInteger uid;
@property (nonatomic) NSInteger sid;
@property (nonatomic) NSInteger sno;
@property (nonatomic) NSInteger eno;

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *rating;

- (ZUser *)user;
- (TVShow *)show;
- (Episode *)episode;

- (instancetype)initWithDict:(id)dict;

+ (NSMutableArray <Comment *> *)returnArrayFromJSONStructure:(id)json;

@end
