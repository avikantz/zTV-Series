//
//  FavouritesTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "FavouriteTableViewCell.h"
#import "EpisodeDetailViewController.h"

@interface FavouritesTableViewController ()

@end

@implementation FavouritesTableViewController {
	NSMutableArray *shows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated {
	[self fetchShows];
}

- (void)fetchShows {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM TVShow WHERE sid IN (SELECT sid FROM Following WHERE uid = %li) ORDER BY name", [DBManager sharedManager].user.uid];
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			shows = [TVShow returnArrayFromJSONStructure:results];
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
				[self.tableView reloadData];
				[self fetchFavsForAllShows];
			});
		}
	});
}

- (void)fetchFavsForAllShows {
	for (NSInteger i = 0; i < shows.count; ++i) {
		[self fetchFavsForShowAtSection:i];
	}
}

- (void)fetchFavsForShowAtSection:(NSInteger)section {
	TVShow *show = [shows objectAtIndex:section];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Episode NATURAL JOIN FavouriteE WHERE sid = %li AND uid = %li", show.sid, [DBManager sharedManager].user.uid];
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			show.episodes = [Episode returnArrayFromJSONStructure:results];
		}
		@catch (NSException *exception) {
			NSLog(@"Fetch error: %@", exception.reason);
		}
		@finally {
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (show.episodes.count > 0) {
					[self.tableView reloadData];
				}
			});
		}
	});
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return shows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	TVShow *show = [shows objectAtIndex:section];
    return show.episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteTableViewCell *cell = (FavouriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"favCell" forIndexPath:indexPath];
	if (cell == nil)
		cell = [[FavouriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"favCell"];
    // Configure the cell...
	
	TVShow *show = [shows objectAtIndex:indexPath.section];
	Episode *episode = [show.episodes objectAtIndex:indexPath.row];
	
	cell.episodeNoLabel.text = [NSString stringWithFormat:@"%lix%.2li", episode.sno, episode.eno];
	cell.episodeNameLabel.text = episode.name;
	cell.episodeAirdateLabel.text = episode.airdate;
	
	[cell.favButton addTarget:self action:@selector(unfavouriteEpisode:) forControlEvents:UIControlEventTouchUpInside];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	TVShow *show = [shows objectAtIndex:section];
	return [NSString stringWithFormat:@"%@ (%li)", show.name, show.episodes.count];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)unfavouriteEpisode:(id)sender {
	CGPoint location = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
	TVShow *show = [shows objectAtIndex:indexPath.section];
	Episode *episode = [show.episodes objectAtIndex:indexPath.row];
	@try {
		NSError *error;
		NSString *queryString = [NSString stringWithFormat:@"DELETE FROM FavouriteE WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, show.sid, episode.sno, episode.eno];
		if (![[DBManager sharedManager] dbExecuteUpdate:queryString error:&error]) {
			NSLog(@"Error: %@", error.localizedDescription);
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%s | Unable to delete", __PRETTY_FUNCTION__);
	}
	@finally {
		[self fetchFavsForShowAtSection:indexPath.section];
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

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
	
	NSString *text = @"Add a show first from the add page.";
	
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:14.f],
								 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
	
	return [[NSAttributedString alloc] initWithString:text attributes:attributes];
	
}

#pragma mark - DZN Empty Data Set Source

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
	return (shows.count == 0);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailSegueFav"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		TVShow *show = [shows objectAtIndex:indexPath.section];
		Episode *episode = [show.episodes objectAtIndex:indexPath.row];
		EpisodeDetailViewController *edvc = [segue destinationViewController];
		edvc.show = show;
		edvc.episode = episode;
	}
}

@end
