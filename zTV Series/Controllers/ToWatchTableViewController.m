//
//  ToWatchTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ToWatchTableViewController.h"
#import "ToWatchDetailTableViewController.h"
#import "ToWatchTableViewCell.h"

@interface ToWatchTableViewController ()

@end

@implementation ToWatchTableViewController {
	NSMutableArray *shows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	shows = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
	[self fetchShows];
}

- (void)fetchShows {
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
	
	[cell.seenButton addTarget:self action:@selector(didPressSeenButton:) forControlEvents:UIControlEventTouchUpInside];
	
    return cell;
}

- (void)refershEpisodeInformationForCell:(ToWatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withShow:(TVShow *)show {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT sid, sno, eno, name, airdate FROM Episode WHERE sid = %li EXCEPT SELECT sid, sno, eno, name, airdate FROM (Episode NATURAL JOIN Watched) WHERE sid = %li AND uid = %li", show.sid, show.sid, [DBManager sharedManager].user.uid];
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			show.episodes = [Episode returnArrayFromJSONStructure:results];
		}
		@catch (NSException *exception) {
			NSLog(@"Fetch error: %@", exception.reason);
		}
		@finally {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (show.episodes.count == 0) {
					cell.epsNameLabel.text = @"All Watched!";
					cell.epsCountLabek.text = @"¿";
				}
				else {
					Episode *eps = show.episodes.firstObject;
					cell.epsNameLabel.text = [NSString stringWithFormat:@"%lix%.2li - %@", eps.sno, eps.eno, eps.name];
					cell.epsCountLabek.text = [NSString stringWithFormat:@"%li", show.episodes.count];
				}
			});
		}
	});
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didPressSeenButton:(id)sender {
	CGPoint pointOfOrigin = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointOfOrigin];
	ToWatchTableViewCell *cell = (ToWatchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	TVShow *show = [shows objectAtIndex:indexPath.row];
	Episode *episode = show.episodes.firstObject;
	
	NSString *queryString = [NSString stringWithFormat:@"INSERT INTO Watched (uid, sid, sno, eno) VALUES (%li, %li, %li, %li)", [DBManager sharedManager].user.uid, show.sid, episode.sno, episode.eno];
	NSError *error;
	[[DBManager sharedManager] dbExecuteUpdate:queryString error:&error];
	
	[self refershEpisodeInformationForCell:cell atIndexPath:indexPath withShow:show];
}

- (void)tableViewCell:(ToWatchTableViewCell *)cell pressSeenButtonAtIndexPath:(NSIndexPath *)indexPath forShow:(TVShow *)show {
	
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ToWatchShow"]) {
		ToWatchDetailTableViewController *dvc = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		TVShow *show = [shows objectAtIndex:indexPath.row];
		dvc.show = show;
	}
}

@end
