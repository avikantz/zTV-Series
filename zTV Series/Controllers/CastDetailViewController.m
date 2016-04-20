//
//  CastDetailViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 4/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "CastDetailViewController.h"

@interface CastDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *personNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personAgeLabel;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CastDetailViewController {
	NSMutableArray *filmography;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.navigationItem.title = self.actor.personName;
	
	self.personNameLabel.text = self.actor.personName;
	
	self.personAgeLabel.text = [NSString stringWithFormat:@"%@ | %i", self.actor.sex, arc4random_uniform(20) + 20];
	
	[self fetchFilmography];
	[self checkFavourite];
	
}

- (void)fetchFilmography {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT cname, name FROM Cast NATURAL JOIN TVShow WHERE aid = %li", self.actor.aid];
			
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			
			filmography = [NSMutableArray arrayWithArray:results];
			
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

- (void)checkFavourite {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		NSError *error;
		
		NSString *favQueryString = [NSString stringWithFormat:@"SELECT * FROM LikesActor WHERE uid = %li AND aid = %li", [DBManager sharedManager].user.uid, self.actor.aid];
		
		NSArray *favs = [[DBManager sharedManager] dbExecuteQuery:favQueryString error:&error];
		BOOL isFavourite = (favs.count > 0);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (isFavourite)
				[self.favButton setImage:[UIImage imageNamed:@"30StarFilled"] forState:UIControlStateNormal];
			else
				[self.favButton setImage:[UIImage imageNamed:@"30StarEmpty"] forState:UIControlStateNormal];
			
		});
		
	});
	
}

- (IBAction)favAction:(id)sender {
	
	NSError *error;
	
	NSString *favQueryString = [NSString stringWithFormat:@"SELECT * FROM LikesActor WHERE uid = %li AND aid = %li", [DBManager sharedManager].user.uid, self.actor.aid];
	
	NSArray *favs = [[DBManager sharedManager] dbExecuteQuery:favQueryString error:&error];
	NSString *updateString;
	if (favs.count > 0) {
		updateString = [NSString stringWithFormat:@"DELETE FROM LikesActor WHERE uid = %li AND aid = %li", [DBManager sharedManager].user.uid, self.actor.aid];
	}
	else {
		updateString = [NSString stringWithFormat:@"INSERT INTO LikesActor (uid, aid) VALUES (%li, %li)", [DBManager sharedManager].user.uid, self.actor.aid];
	}
	if (![[DBManager sharedManager] dbExecuteUpdate:updateString error:&error]) {
		NSLog(@"%@", error.localizedDescription);
	}
	
	[self checkFavourite];
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return filmography.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
	
	NSDictionary *dict = [filmography objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [dict objectForKey:@"name"];
	cell.detailTextLabel.text = [dict objectForKey:@"cname"];
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [UIView new];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
