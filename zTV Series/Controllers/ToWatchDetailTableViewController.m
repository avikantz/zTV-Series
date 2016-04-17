//
//  ToWatchDetailTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 4/17/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ToWatchDetailTableViewController.h"
#import "EpisodeDetailViewController.h"
#import "ToWatchTableViewCell.h"

@interface ToWatchDetailTableViewController ()

@end

@implementation ToWatchDetailTableViewController {
	NSMutableArray *episodes;
	NSMutableArray *orderedEpisodes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = self.show.name;
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Episodes" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated {
	@try {
		NSError *error;
		NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Episode WHERE sid = %li ORDER BY sno, eno", self.show.sid];
		NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
		episodes = [Episode returnArrayFromJSONStructure:results];
	}
	@catch (NSException *exception) {
		NSLog(@"Fetch error: %@", exception.reason);
	}
	@finally {
	}
	
	orderedEpisodes = [NSMutableArray new];
	NSInteger fsno = [(Episode *)[episodes firstObject] sno];
	NSMutableArray *epsSec = [NSMutableArray new];
	for (NSInteger i = 0; i < episodes.count; ++i) {
		Episode *episode = [episodes objectAtIndex:i];
		if (episode.sno == fsno)
			[epsSec addObject:episode];
		else {
			[orderedEpisodes addObject:epsSec];
			epsSec = [NSMutableArray arrayWithObject:episode];
			fsno = episode.sno;
		}
	}
	[orderedEpisodes addObject:epsSec];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return orderedEpisodes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[orderedEpisodes objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ToWatchTableViewCell *cell = (ToWatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"toWatchCell" forIndexPath:indexPath];
	if (cell == nil)
		cell = [[ToWatchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"toWatchCell"];
	
	Episode *episode = [[orderedEpisodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	cell.epsCountLabek.text = [NSString stringWithFormat:@"%li", episode.eno];
	cell.showNameLabe.text = episode.name;
	cell.epsNameLabel.text = episode.airdate;
	
	UIButton *seenButton = cell.seenButton;
	[self configureSeenButton:seenButton forCell:cell atIndexPath:indexPath withEpisode:episode];
	[seenButton addTarget:self action:@selector(didPressSeenButton:) forControlEvents:UIControlEventTouchUpInside];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"Season %li", section + 1];
}

- (void)configureSeenButton:(UIButton *)seenButton forCell:(ToWatchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withEpisode:(Episode *)episode {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@try {
			NSError *error;
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Watched WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li",[DBManager sharedManager].user.uid, episode.sid, episode.sno, episode.eno];
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			if (results.count > 0) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[seenButton setImage:[UIImage imageNamed:@"30EyeFilled"] forState:UIControlStateNormal];
					[seenButton setImage:[UIImage imageNamed:@"30EyeEmpty"] forState:UIControlStateHighlighted];
				});
			}
			else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[seenButton setImage:[UIImage imageNamed:@"30EyeEmpty"] forState:UIControlStateNormal];
					[seenButton setImage:[UIImage imageNamed:@"30EyeFilled"] forState:UIControlStateHighlighted];
				});
			}
		}
		@catch (NSException *exception) {
			NSLog(@"Fetch error: %@", exception.reason);
		}
		@finally {
		}
	});
}

- (void)didPressSeenButton:(id)sender {
	CGPoint pointOfOrigin = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointOfOrigin];
	ToWatchTableViewCell *cell = (ToWatchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	UIButton *seenButton = cell.seenButton;
	Episode *episode = [[orderedEpisodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	@try {
		NSError *error;
		NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Watched WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li",[DBManager sharedManager].user.uid, episode.sid, episode.sno, episode.eno];
		NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
		NSString *updateString;
		if (results.count > 0) {
			updateString = [NSString stringWithFormat:@"DELETE FROM Watched WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, episode.sid, episode.sno, episode.eno];
		}
		else {
			updateString = [NSString stringWithFormat:@"INSERT INTO Watched (uid, sid, sno, eno) VALUES (%li, %li, %li, %li)", [DBManager sharedManager].user.uid, episode.sid, episode.sno, episode.eno];
		}
		[[DBManager sharedManager] dbExecuteUpdate:updateString error:&error];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self configureSeenButton:seenButton forCell:cell atIndexPath:indexPath withEpisode:episode];
		});
	}
	@catch (NSException *exception) {
		NSLog(@"Fetch error: %@", exception.reason);
	}
	@finally {
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailSegueToWatch"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		Episode *episode = [[orderedEpisodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		EpisodeDetailViewController *edvc = [segue destinationViewController];
		edvc.show = self.show;
		edvc.episode = episode;
	}
}

@end
