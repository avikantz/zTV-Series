//
//  ZUser.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ZUser.h"

@implementation ZUser

- (instancetype)initWithDict:(id)dict {
	
	self = [super init];
	
	if (self) {
		
		@try {
			
			self.uid = [dict[@"uid"] integerValue];
			
			self.fullName = [NSString stringWithFormat:@"%@", dict[@"fullname"]];
			
			self.username = [NSString stringWithFormat:@"%@", dict[@"username"]];
			
		}
		@catch (NSException *exception) {
			NSLog(@"User parse error: %@", exception.reason);
		}
		
	}
	
	return self;
}

+ (NSMutableArray<ZUser *> *)returnArrayFromJSONStructure:(id)json {
	
	NSMutableArray *users = [NSMutableArray new];
	
	@try {
		
		for (id dict in json) {
			
			ZUser *user = [[ZUser alloc] initWithDict:dict];
			
			[users addObject:user];
			
		}
		
	}
	@catch (NSException *exception) {
		NSLog(@"User parse error: %@", exception.reason);
	}
	
	return users;
}

@end
