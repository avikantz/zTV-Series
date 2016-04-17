//
//  EpisodeDetailViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "EpisodeDetailViewController.h"
#import "AddCommentTableViewController.h"
#import "DoubleUnderlinedLabel.h"

@interface EpisodeDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *seasonEpisodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeOverviewLabel;
@property (weak, nonatomic) IBOutlet DoubleUnderlinedLabel *commentsLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *seenButton;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;

@end

@implementation EpisodeDetailViewController {
	NSMutableArray *comments;
	
	BOOL isFavourite;
	BOOL isWatched;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.navigationItem.title = self.show.name;
	
	self.seasonEpisodeLabel.text = [NSString stringWithFormat:@"Season %.2li | Episode %.2li", self.episode.sno, self.episode.eno];
	self.episodeNameLabel.text = self.episode.name;
	self.episodeOverviewLabel.text = self.episode.overview;
	
	[self.backgroundImageView sd_setImageWithURL:self.episode.imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		self.backgroundImageView.image = [image applyDarkEffect];
	}];
	
	self.backgroundImageView.clipsToBounds = YES;
	
	comments = [NSMutableArray new];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
	self.tableView.separatorEffect = vibrancyEffect;
	
	[self checkFavouriteAndWatched];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
	self.navigationController.view.backgroundColor = [UIColor clearColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:17.f], NSForegroundColorAttributeName: GLOBAL_BACK_COLOR};
	
	[self fetchComments];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = nil;
	self.navigationController.navigationBar.backgroundColor = nil;
	self.navigationController.view.backgroundColor = nil;
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:17.f], NSForegroundColorAttributeName: [UIColor darkTextColor]};
}

- (void)fetchComments {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM CommentE WHERE sid = %li AND sno = %li AND eno = %li", self.show.sid, self.episode.sno, self.episode.eno];
			
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			
			//			NSLog(@"Results : %@", results);
			
			comments = [Comment returnArrayFromJSONStructure:results];
			
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

#pragma mark - Favourite and Watched

- (void)checkFavouriteAndWatched {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		NSError *error;
		
		NSString *favQueryString = [NSString stringWithFormat:@"SELECT * FROM FavouriteE WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
		
		NSArray *favs = [[DBManager sharedManager] dbExecuteQuery:favQueryString error:&error];
		isFavourite = (favs.count > 0);
		
		NSString *watQueryString = [NSString stringWithFormat:@"SELECT * FROM Watched WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
		
		NSArray *wata = [[DBManager sharedManager] dbExecuteQuery:watQueryString error:&error];
		isWatched = (wata.count > 0);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (isFavourite)
				[self.favButton setImage:[UIImage imageNamed:@"30StarFilled"] forState:UIControlStateNormal];
			else
				[self.favButton setImage:[UIImage imageNamed:@"30StarEmpty"] forState:UIControlStateNormal];
			
			if (isWatched)
				[self.seenButton setImage:[UIImage imageNamed:@"30EyeFilled"] forState:UIControlStateNormal];
			else
				[self.seenButton setImage:[UIImage imageNamed:@"30EyeEmpty"] forState:UIControlStateNormal];
			
			[self.view layoutIfNeeded];
			
		});
		
	});
	
}

- (IBAction)seenAction:(id)sender {
	
	NSString *queryString;
	
	if (isWatched)
		queryString = [NSString stringWithFormat:@"DELETE FROM Watched WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
	else
		queryString = [NSString stringWithFormat:@"INSERT INTO Watched (uid, sid, sno, eno) VALUES (%li, %li, %li, %li)", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
	
	NSError *error;
	
	if (![[DBManager sharedManager] dbExecuteUpdate:queryString error:&error]) {
		SVHUD_FAILURE(error.localizedDescription);
	}
	
	[self checkFavouriteAndWatched];
	
}

- (IBAction)favouriteAction:(id)sender {
	
	NSString *queryString;
	
	if (isFavourite)
		queryString = [NSString stringWithFormat:@"DELETE FROM FavouriteE WHERE uid = %li AND sid = %li AND sno = %li AND eno = %li", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
	else
		queryString = [NSString stringWithFormat:@"INSERT INTO FavouriteE (uid, sid, sno, eno) VALUES (%li, %li, %li, %li)", [DBManager sharedManager].user.uid, self.show.sid, self.episode.sno, self.episode.eno];
	
	NSError *error;
	
	if (![[DBManager sharedManager] dbExecuteUpdate:queryString error:&error]) {
		SVHUD_FAILURE(error.localizedDescription);
	}
	
	[self checkFavouriteAndWatched];
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell" forIndexPath:indexPath];
	
	Comment *comment = [comments objectAtIndex:indexPath.row];
	
	cell.textLabel.text = comment.user.username;
	
	cell.detailTextLabel.text = comment.comment;
	
	return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"AddCommentSegue"]) {
		
		UINavigationController *navc = [segue destinationViewController];
		
		AddCommentTableViewController *actvc = [navc.viewControllers firstObject];
		
		actvc.episode = self.episode;
		
	}
	
}

@end
