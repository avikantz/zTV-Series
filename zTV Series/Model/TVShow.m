//
//  TVShow.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "TVShow.h"

@implementation TVShow

- (instancetype)initWithDict:(id)dict {
	
	self = [super init];
	
	if (self) {
		
		@try {
			
			self.sid = [dict[@"sid"] integerValue];
			
			self.name = [NSString stringWithFormat:@"%@", dict[@"name"]];
			
			self.genres = [NSString stringWithFormat:@"%@", dict[@"genres"]];
			
			self.overview = [NSString stringWithFormat:@"%@", dict[@"overview"]];
	
			self.channel = [NSString stringWithFormat:@"%@", dict[@"channel"]];
			
			self.country = [NSString stringWithFormat:@"%@", dict[@"country"]];
			
			self.premiered = [NSString stringWithFormat:@"%@", dict[@"premiered"]];
			
			self.status = [NSString stringWithFormat:@"%@", dict[@"status"]];
			
			self.rating = [NSString stringWithFormat:@"%@", dict[@"rating"]];
			
			self.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", dict[@"imageURL"]]];
			
		}
		@catch (NSException *exception) {
			NSLog(@"TVShow init exception: %@", exception.reason);
		}
		
	}
	
	return self;
}

+ (NSMutableArray<TVShow *> *)returnArrayFromJSONStructure:(id)json {
	
	NSMutableArray *shows = [NSMutableArray new];
	
	@try {
		
		for (id dict in json) {
			
			TVShow *show = [[TVShow alloc] initWithDict:dict];
			
			[shows addObject:show];
			
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Error : %s", __PRETTY_FUNCTION__);
	}

	return shows;
	
}

@end
