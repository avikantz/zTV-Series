//
//  CastTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 4/20/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "CastTableViewController.h"
#import "CastTableViewCell.h"
#import "CastDetailViewController.h"
#import "Cast.h"

@interface CastTableViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation CastTableViewController {
	NSMutableArray *actors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	actors = [NSMutableArray new];
	
	self.navigationItem.title = [NSString stringWithFormat:@"%@ | Cast", self.show.name];
	
	self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	self.tableView.backgroundView = self.backgroundImageView;
	
	[self.backgroundImageView sd_setImageWithURL:self.show.imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		self.backgroundImageView.image = [image applyTintEffectWithColor:GLOBAL_BACK_COLOR :12.0];
	}];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	
}

- (void)viewWillAppear:(BOOL)animated {
	[self fetchActors];
}

- (void)fetchActors {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		@try {
			
			NSError *error;
			
			NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM Actor NATURAL JOIN Cast WHERE sid = %li", self.show.sid];
			
			NSArray *results = [[DBManager sharedManager] dbExecuteQuery:queryString error:&error];
			
			actors = [Cast returnArrayFromJSONStructure:results];
			
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return actors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CastTableViewCell *cell;
	
	if (indexPath.row % 2 == 0)
		cell = [tableView dequeueReusableCellWithIdentifier:@"personCell1" forIndexPath:indexPath];
	else
		cell = [tableView dequeueReusableCellWithIdentifier:@"personCell2" forIndexPath:indexPath];
		
	Cast *actor = [actors objectAtIndex:indexPath.row];
	
	cell.titleLabel.text = actor.personName;
	cell.subtitleLabel.text = actor.characterName;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CastDetailViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CastDetailVC"];
	
	Cast *actor = [actors objectAtIndex:indexPath.row];
	
	cdvc.actor = actor;
	
	[self.navigationController pushViewController:cdvc animated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
