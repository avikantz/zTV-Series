//
//  DBManager.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

- (instancetype)initWithDatabasePath:(NSString *)path;

- (void)dbManagerOpenDatabaseWithPath:(NSString *)path;
- (void)dbManagerCloseDatabase;

- (BOOL)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password error:(NSError *__autoreleasing *)error;

- (id)dbExecuteQuery:(NSString *)query error:(NSError *__autoreleasing *)error;

+ (DBManager *)sharedManager;

@end
