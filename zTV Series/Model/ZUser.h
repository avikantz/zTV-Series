//
//  ZUser.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZUser : NSObject

@property (nonatomic) NSInteger uid;

@property (nonatomic, strong) NSString *fullName;

@property (nonatomic, strong) NSString *username;

- (instancetype)initWithDict:(id)dict;

+ (NSMutableArray <ZUser *> *)returnArrayFromJSONStructure:(id)json;

@end
