//
//  Comment.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithDict:(id)dict {
	
	self = [super init];
	
	if (self) {
		
		@try {
			
			self.uid = [dict[@"uid"] integerValue];
			
			self.sid = [dict[@"sid"] integerValue];
			
			self.sno = [dict[@"sno"] integerValue];
			
			self.eno = [dict[@"eno"] integerValue];
			
			self.rating = [NSString stringWithFormat:@"%@", dict[@"rating"]];
			
			self.comment = [NSString stringWithFormat:@"%@", dict[@"comment"]];
			
		}
		@catch (NSException *exception) {
			NSLog(@"Comment parse error: %@", exception.reason);
		}
		
	}
	
	return self;
}

- (TVShow *)show {
	
	TVShow *show;
	
	@try {
		
		NSError *error;
		
		NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM TVShow WHERE sid = %li", self.sid];
		
		NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
		
		NSArray *shows = [TVShow returnArrayFromJSONStructure:results];
		
		show = [shows firstObject];
		
		if (error) {
			SVHUD_FAILURE(error.localizedDescription);
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Fetch error: %@", exception.reason);
	}
	
	return show;
	
}

- (Episode *)episode {
	
	Episode *episode;
	
	@try {
		
		NSError *error;
		
		NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Episode WHERE sid = %li AND sno = %li AND eno = %li", self.sid, self.sno, self.eno];
		
		NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
		
		NSArray *episodes = [Episode returnArrayFromJSONStructure:results];
		
		episode = [episodes firstObject];
		
		if (error) {
			SVHUD_FAILURE(error.localizedDescription);
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Fetch error: %@", exception.reason);
	}
	
	return episode;
	
}

- (ZUser *)user {
	
	ZUser *user;
	
	@try {
		
		NSError *error;
		
		NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM User WHERE uid = %li", self.uid];
		
		NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
		
		NSArray *users = [ZUser returnArrayFromJSONStructure:results];
		
		user = [users firstObject];
		
		if (error) {
			SVHUD_FAILURE(error.localizedDescription);
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Fetch error: %@", exception.reason);
	}
	
	return user;
	
}

+ (NSMutableArray<Comment *> *)returnArrayFromJSONStructure:(id)json {
	
	NSMutableArray *comments = [NSMutableArray new];
	
	@try {
		
		for (id dict in json) {
			
			Comment *comment = [[Comment alloc] initWithDict:dict];
			
			[comments addObject:comment];
			
		}
		
	}
	@catch (NSException *exception) {
		NSLog(@"Parse error: %@", exception.reason);
	}
	
	return comments;
	
}

@end
