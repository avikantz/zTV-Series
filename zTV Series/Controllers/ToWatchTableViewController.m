//
//  ToWatchTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ToWatchTableViewController.h"
#import "ToWatchTableViewCell.h"

@interface ToWatchTableViewController ()

@end

@implementation ToWatchTableViewController {
	NSMutableArray *shows;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];

	shows = [NSMutableArray new];
	[self fetchShows];
	
}

- (void)fetchShows {
	SVHUD_SHOW;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM TVShow WHERE sid IN (SELECT sid FROM Following WHERE uid = %li)", [DBManager sharedManager].user.uid];
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
				SVHUD_HIDE;
				[self.tableView reloadData];
			});
		}
	});
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToWatchTableViewCell *cell = (ToWatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"toWatchCell" forIndexPath:indexPath];
    if (cell == nil)
		cell = [[ToWatchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"toWatchCell"];
	
	TVShow *show = [shows objectAtIndex:indexPath.row];
	
	cell.showNameLabe.text = show.name;
	[self refershEpisodeInformationForCell:cell atIndexPath:indexPath withShow:show];
	
    return cell;
}

- (void)refershEpisodeInformationForCell:(ToWatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withShow:(TVShow *)show {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Episode WHERE sid = %li AND ((sid, sno, eno) IN (SELECT sid, sno, eno FROM Watched WHERE uid = %li AND sid = %li))", show.sid, [DBManager sharedManager].user.uid, show.sid];
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			NSLog(@"Results = %@", results);
			show.episodes = [Episode returnArrayFromJSONStructure:results];
		}
		@catch (NSException *exception) {
			NSLog(@"Fetch error: %@", exception.reason);
		}
		@finally {
			dispatch_async(dispatch_get_main_queue(), ^{
				Episode *eps = show.episodes.firstObject;
				cell.epsNameLabel.text = [NSString stringWithFormat:@"%lix%.2li - %@", eps.sno, eps.sno, eps.name];
				cell.epsCountLabek.text = [NSString stringWithFormat:@"%li", show.episodes.count];
			});
		}
	});
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
