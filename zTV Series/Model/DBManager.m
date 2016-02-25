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
	
	NSString *queryString = [NSString stringWithFormat:@"INSERT INTO User (username, password) VALUES (%@, %@)", username, password];
	
	if (![self.database executeUpdate:queryString values:nil error:error])
		return NO;
	
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

+ (DBManager *)sharedManager {
	static DBManager *manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

@end
