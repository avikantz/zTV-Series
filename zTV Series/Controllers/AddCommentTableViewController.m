//
//  AddCommentTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "AddCommentTableViewController.h"
#import "GCPlaceholderTextView.h"

@interface AddCommentTableViewController ()

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *commentTextView;

@end

@implementation AddCommentTableViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[self.commentTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
	
	if (self.commentTextView.text.length < 3) {
		SVHUD_FAILURE(@"Comment length less than three characters!");
		return;
	}
	
	@try {
		
		NSError *error;
		
		NSString *queryString = [NSString stringWithFormat:@"INSERT INTO CommentE (uid, sid, sno, eno, comment) VALUES (%li, %li, %li, %li, '%@')", [DBManager sharedManager].user.uid, self.episode.show.sid, self.episode.sno, self.episode.eno, [self.commentTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"`"]];
		
		if (![[DBManager sharedManager] dbExecuteUpdate:queryString error:&error]) {
			SVHUD_FAILURE(error.localizedDescription);
			return;
		}
		
		SVHUD_SUCCESS(@"Comment added");
		
	}
	@catch (NSException *exception) {
		NSLog(@"Update comment exception: %@", exception.reason);
	}
	@finally {
		
	}
	
	[self cancelAction:nil];
	
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return [NSString stringWithFormat:@"ON %@", self.episode.show.name];
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0)
		return [NSString stringWithFormat:@"%lix%.2li - %@", self.episode.sno, self.episode.eno, self.episode.name];
	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
		[self doneAction:nil];
	}
	
}


@end
