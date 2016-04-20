//
//  Cast.m
//  zTV Series
//
//  Created by Avikant Saini on 4/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "Cast.h"

@implementation Cast

- (instancetype)initWithDict:(id)dict {
	
	self = [super init];
	
	if (self) {
		
		@try {
			
			self.sid = [dict[@"sid"] integerValue];
			
			self.aid = [dict[@"aid"] integerValue];
			
			self.personName = [NSString stringWithFormat:@"%@", dict[@"name"]];
			
			self.characterName = [NSString stringWithFormat:@"%@", dict[@"cname"]];
			
			self.sex = [NSString stringWithFormat:@"%@", dict[@"sex"]];
			
		}
		@catch (NSException *exception) {
			NSLog(@"TVShow init exception: %@", exception.reason);
		}
		
	}
	
	return self;
}

+ (NSMutableArray<Cast *> *)returnArrayFromJSONStructure:(id)json {
	
	NSMutableArray *casts = [NSMutableArray new];
	
	@try {
		
		for (id dict in json) {
			
			Cast *cast = [[Cast alloc] initWithDict:dict];
			
			[casts addObject:cast];
			
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Error : %s", __PRETTY_FUNCTION__);
	}
	
	return casts;
	
}

@end
