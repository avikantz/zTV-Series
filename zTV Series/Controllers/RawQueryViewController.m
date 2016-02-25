//
//  RawQueryViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/24/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "RawQueryViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface RawQueryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RawQueryViewController {
	NSMutableArray *results;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	results = [NSMutableArray new];
	
	if (self.queryString) {
		
		SVHUD_SHOW;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			
			@try {
				NSError *error;
				results = [[DBManager sharedManager] dbExecuteQuery:self.queryString error:&error];
				
//				NSLog(@"Results : %@", results);
				
				if (error) {
					SVHUD_FAILURE(error.localizedDescription);
					return;
				}
			}
			@catch (NSException *exception) {
				NSLog(@"Fetch error: %@", exception.reason);
			}
			@finally {
				SVHUD_HIDE;
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.tableView reloadData];
					self.navigationItem.title = [NSString stringWithFormat:@"%li Results", results.count];
				});
			}
			
		});
		
	}
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rawQueryCell" forIndexPath:indexPath];
	
	NSDictionary *dict = [results objectAtIndex:indexPath.row];
	
	NSMutableString *string = [NSMutableString new];
	
	[dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[string appendFormat:@"%@ : %@\n", key, obj];
	}];
	
	if ([string hasSuffix:@"\n"])
		[string replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(string.length - 4, 4)];
	
	cell.textLabel.text = string;
	
	return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

@end
