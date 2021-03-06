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

- (void)fetchShowsOrderedBy:(NSString *)ordering {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM TVShow WHERE sid NOT IN (SELECT sid FROM Following WHERE uid = %li) %@", [DBManager sharedManager].user.uid, ordering];
			
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
			dispatch_async(dispatch_get_main_queue(), ^{
				SVHUD_HIDE;
				[self.tableView reloadData];
				[self updateSearchResultsForSearchController:self.searchController];
			});
		}
		
	});
	
}

- (void)fetchShows {
	
	[self fetchShowsOrderedBy:@"ORDER BY name"];
	
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


- (IBAction)sortAction:(id)sender {
	
	UIAlertAction *nameSortAction = [UIAlertAction actionWithTitle:@"Name (Ascending)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self fetchShowsOrderedBy:@"ORDER BY name"];
	}];
	UIAlertAction *nameSortAction2 = [UIAlertAction actionWithTitle:@"Name (Descending)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self fetchShowsOrderedBy:@"ORDER BY name DESC"];
	}];
	UIAlertAction *premieredSortAction = [UIAlertAction actionWithTitle:@"Newest First" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self fetchShowsOrderedBy:@"ORDER BY premiered DESC"];
	}];
	UIAlertAction *premieredSortAction2 = [UIAlertAction actionWithTitle:@"Oldest First" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self fetchShowsOrderedBy:@"ORDER BY premiered"];
	}];
	UIAlertAction *ratingSortAction = [UIAlertAction actionWithTitle:@"Rating" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self fetchShowsOrderedBy:@"ORDER BY rating"];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sort" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	[alertController addAction:nameSortAction];
	[alertController addAction:nameSortAction2];
	[alertController addAction:premieredSortAction];
	[alertController addAction:premieredSortAction2];
	[alertController addAction:ratingSortAction];
	[alertController addAction:cancel];
	
	[self.navigationController presentViewController:alertController animated:YES completion:nil];
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
