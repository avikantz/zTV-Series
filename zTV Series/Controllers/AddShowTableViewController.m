//
//  AddShowTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "AddShowTableViewController.h"
#import "ShowsTableViewCell.h"

@interface AddShowTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation AddShowTableViewController {
	NSMutableArray *shows;
	NSMutableArray *fshows;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	shows = [NSMutableArray new];
	fshows = [NSMutableArray new];
	
	[self setupSearchController];
	
	self.tableView.emptyDataSetSource = self;
	self.tableView.emptyDataSetDelegate = self;
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[self fetchShows];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[self.searchController.searchBar becomeFirstResponder];
}

- (void)fetchShows {
	
	SVHUD_SHOW;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM TVShow WHERE sid NOT IN (SELECT sid FROM Following WHERE uid = %li) ORDER BY rating DESC", [DBManager sharedManager].user.uid];
			
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			
			//			NSLog(@"Results : %@", results);
			
			shows = [TVShow returnArrayFromJSONStructure:results];
			fshows = [NSMutableArray arrayWithArray:shows];
			
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
			});
		}
		
	});
	
}

- (void)setupSearchController {
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.searchResultsUpdater = self;
	self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
	self.searchController.searchBar.backgroundColor = GLOBAL_BACK_COLOR;
	self.searchController.searchBar.tintColor = [UIColor blackColor];
	self.searchController.dimsBackgroundDuringPresentation = NO;
	self.definesPresentationContext = YES;
	self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (IBAction)doneAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return fshows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    ShowsTableViewCell *cell = (ShowsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"showsCell" forIndexPath:indexPath];
    
	if (cell == nil)
		cell = [[ShowsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"showsCell"];
	
	TVShow *show = [fshows objectAtIndex:indexPath.row];
	
	[cell fillUsingShow:show];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Adding code
	
	SVHUD_SHOW;
	
	TVShow *show = [fshows objectAtIndex:indexPath.row];
	
	NSError *error;
	
	NSString *queryString = [NSString stringWithFormat:@"INSERT INTO Following (uid, sid) VALUES  (%li, %li)", [DBManager sharedManager].user.uid, show.sid];
	
	if (![[DBManager sharedManager] dbExecuteUpdate:queryString error:&error]) {
		SVHUD_FAILURE(error.localizedDescription);
	}
	
	[self fetchShows];
	
	[self updateSearchResultsForSearchController:self.searchController];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

#pragma mark - Search controller results updating | Filtering

- (void)filterForSearchTitle:(NSString *)searchString {
	fshows = [NSMutableArray arrayWithArray:shows];
	[fshows filterUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@ OR genres contains [cd] %@", searchString, searchString]];
	[self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	UISearchBar *searchBar = searchController.searchBar;
	if (searchBar.text.length > 0)
		[self filterForSearchTitle:searchBar.text];
	else {
		fshows = [NSMutableArray arrayWithArray:shows];
		[self.tableView reloadData];
	}
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

#pragma mark - DZN Empty Data Set Source

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
	return (fshows.count == 0);
}


@end
