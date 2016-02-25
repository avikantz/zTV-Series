//
//  Episode.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "Episode.h"

@implementation Episode

- (instancetype)initWithDict:(id)dict {
	
	self = [super init];
	
	if (self) {
		
		@try {
			
			self.sid = [dict[@"sid"] integerValue];
			
			self.sno = [dict[@"sno"] integerValue];
			
			self.eno = [dict[@"eno"] integerValue];
			
			self.name = [NSString stringWithFormat:@"%@", dict[@"name"]];
			
			self.overview = [NSString stringWithFormat:@"%@", dict[@"overview"]];
			
			self.airdate = [NSString stringWithFormat:@"%@", dict[@"airdate"]];
			
			self.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", dict[@"imageURL"]]];
			
		}
		@catch (NSException *exception) {
			NSLog(@"Episode parsing exception: %@", exception.reason);
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

+ (NSMutableArray<Episode *> *)returnArrayFromJSONStructure:(id)json {
	
	NSMutableArray *episodes = [NSMutableArray new];
	
	@try {
		
		for (id dict in json) {
			
			Episode *episode = [[Episode alloc] initWithDict:dict];
			
			[episodes addObject:episode];
			
		}
		
	}
	@catch (NSException *exception) {
		NSLog(@"Episode parsing exception: %@", exception.reason);
	}
	
	return episodes;
}

@end
