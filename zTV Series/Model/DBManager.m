//
//  DBManager.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "DBManager.h"

@interface DBManager ()

@property (nonatomic, strong) FMDatabase *database;

@property (nonatomic, strong) NSString *username;

@end

@implementation DBManager

- (instancetype)initWithDatabasePath:(NSString *)path {
	
	self = [super init];
	
	if (self) {
		self.database = [FMDatabase databaseWithPath:path];
	}
	
	return self;
}

- (void)dbManagerOpenDatabaseWithPath:(NSString *)path {
	
	self.database = [FMDatabase databaseWithPath:path];
	
	if (![self.database open]) {
		NSLog(@"Database Opening Error");
	}
	
}

- (void)dbManagerCloseDatabase {
	
	if (![self.database close]) {
		NSLog(@"Database Closing Error");
	}
	
}

- (BOOL)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password error:(NSError *__autoreleasing *)error {
	
	NSArray *arr = [self dbExecuteQuery:[NSString stringWithFormat:@"SELECT * FROM User WHERE username = '%@'", username] error:nil];
	
	if (arr.count > 0) {
		
		NSLog(@"User already exists, logging in...");
		
		self.username = username;
		
		NSString *savedPassword;
		
		@try {
			savedPassword = [NSString stringWithFormat:@"%@", [[arr firstObject] valueForKey:@"password"]];
			self.uid = [NSString stringWithFormat:@"%@", [[arr firstObject] valueForKey:@"uid"]];
		}
		@catch (NSException *exception) {
			NSLog(@"Exception in getting uids %@", exception.reason);
		}
		
		if (![password isEqualToString:savedPassword]) {
			*error = [NSError errorWithDomain:@"Password Mismatch!" code:401 userInfo:nil];
			return NO;
		}
		
		*error = nil;
		return YES;
	}
	
	NSString *queryString = [NSString stringWithFormat:@"INSERT INTO User (username, password) VALUES ('%@', '%@')", username, password];
	
	if (![self.database executeUpdate:queryString values:nil error:error])
		return NO;
	
	NSLog(@"Signinu up in user: %@", username);
	
	self.username = username;
	
	@try {
		NSArray *arr = [self dbExecuteQuery:[NSString stringWithFormat:@"SELECT uid FROM User WHERE username = '%@'", username] error:nil];
		self.uid = [NSString stringWithFormat:@"%@", [[arr firstObject] valueForKey:@"uid"]];
	}
	@catch (NSException *exception) {
		NSLog(@"Getting ID error: %@", exception.reason);
	}
	
	return YES;
}

- (id)dbExecuteQuery:(NSString *)query error:(NSError *__autoreleasing *)error {
	
	FMResultSet *fmrset = [self.database executeQuery:query values:nil error:error];
	
	NSMutableArray *columnNames = [NSMutableArray new];
	NSMutableArray *results = [NSMutableArray new];
	
	for (int i = 0; i < [fmrset columnCount]; ++i) {
		
		NSString *cname = [fmrset columnNameForIndex:i];
		
		[columnNames addObject:cname];
		
	}
	
	while ([fmrset next]) {
		
		NSMutableDictionary *dict = [NSMutableDictionary new];
		
		for (NSString *cname in columnNames)
			[dict setObject:[fmrset objectForColumnName:cname] forKey:cname];
		
		[results addObject:dict];
		
	}
	
	return results;
}

- (BOOL)dbExecuteUpdate:(NSString *)query error:(NSError *__autoreleasing *)error {
	
	if (![self.database executeUpdate:query values:nil error:error])
		return NO;
	
	return YES;
	
}

+ (DBManager *)sharedManager {
	static DBManager *manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

@end
