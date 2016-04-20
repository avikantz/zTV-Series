//
//  Cast.h
//  zTV Series
//
//  Created by Avikant Saini on 4/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cast : NSObject

@property (nonatomic) NSInteger sid;
@property (nonatomic) NSInteger aid;
@property (nonatomic, strong) NSString *characterName;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSString *sex;

- (instancetype)initWithDict:(id)dict;

+ (NSMutableArray <Cast *> *)returnArrayFromJSONStructure:(id)json;

@end
