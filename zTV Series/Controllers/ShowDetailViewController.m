//
//  ShowDetailViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "EpisodeDetailViewController.h"

@interface ShowDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *genresLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UILabel *premieredLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowDetailViewController {
	NSMutableArray *episodes;
	NSMutableArray *orderedEpisodes;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
	
	self.title = self.show.name;
	self.genresLabel.text = self.show.genres;
	self.statusLabel.text = self.show.status;
	self.channelLabel.text = [NSString stringWithFormat:@"%@ | %@", self.show.channel, self.show.country];
	self.premieredLabel.text = self.show.premiered;
	self.ratingLabel.text = self.show.rating;
	self.overviewLabel.text = self.show.overview;
	
	[self.backgroundImageView sd_setImageWithURL:self.show.imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		self.backgroundImageView.image = [image applyDarkEffect];
	}];
	
	self.backgroundImageView.clipsToBounds = YES;
	
	episodes = [NSMutableArray new];
	orderedEpisodes = [NSMutableArray new];
	
	self.tableView.tableFooterView = [UIView new];
	
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
	self.tableView.separatorEffect = vibrancyEffect;
	
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
	self.navigationController.view.backgroundColor = [UIColor clearColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:17.f], NSForegroundColorAttributeName: GLOBAL_BACK_COLOR};
	
	[self fetchEpisodes];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = nil;
	self.navigationController.navigationBar.backgroundColor = nil;
	self.navigationController.view.backgroundColor = nil;
	self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:17.f], NSForegroundColorAttributeName: [UIColor darkTextColor]};
}

- (void)fetchEpisodes {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Episode WHERE sid = %li ORDER BY sno, eno", self.show.sid];
			
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			
//			NSLog(@"Results : %@", results);
			
			episodes = [Episode returnArrayFromJSONStructure:results];
			
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
	return orderedEpisodes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[orderedEpisodes objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"episodesCell" forIndexPath:indexPath];
	
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"episodesCell"];
	
	Episode *episode = [[orderedEpisodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%lix%.2li", episode.sno, episode.eno];
	
	cell.detailTextLabel.text = episode.name;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"Season %li", section + 1];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	if ([segue.identifier isEqualToString:@"EpisodeDetailSegue"]) {
		
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		
		Episode *episode = [[orderedEpisodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		EpisodeDetailViewController *edvc = [segue destinationViewController];
		
		edvc.show = self.show;
		edvc.episode = episode;
		
	}
	
}


@end
