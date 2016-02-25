//
//  RawQueryViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/24/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "RawQueryViewController.h"

@interface RawQueryViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RawQueryViewController {
	NSMutableArray *results;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	results = [NSMutableArray new];

	SVHUD_SHOW;
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	self.tableView.emptyDataSetDelegate = self;
	self.tableView.emptyDataSetSource = self;
	
}

- (void)viewDidAppear:(BOOL)animated {
	
	if (self.queryString) {
		
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

#pragma mark - DZN Empty Data Set Source

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
	return GLOBAL_BACK_COLOR;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
	
	NSString *text = @"No rows loaded";
	
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:18.f],
								 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
	
	return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
	
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:22.f]};
	
	return [[NSAttributedString alloc] initWithString:@"Back" attributes:attributes];
}

#pragma mark - DZN Empty Data Set Source

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
	return (results.count == 0);
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
