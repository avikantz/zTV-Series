//
//  LoginTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/24/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "LoginTableViewController.h"

@interface LoginTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentUsername"])
		self.usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUsername"];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentPassword"])
		self.passwordField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentPassword"];
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1 && indexPath.row == 0) {
		
		// Present Tab Bar VC
		
		[[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"currentUsername"];
		[[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"currentPassword"];
		
		if (self.usernameField.text.length < 3) {
			SVHUD_FAILURE(@"Username less than 3 characters long");
			return;
		}
		if (self.passwordField.text.length < 3) {
			SVHUD_FAILURE(@"Password less than 3 characters long");
			return;
		}
		
		NSError *error;
		if (![[DBManager sharedManager] loginUserWithUsername:self.usernameField.text andPassword:self.passwordField.text error:&error]) {
			SVHUD_FAILURE(error.localizedDescription);
			return;
		}
		
		UITabBarController *tabbarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
		
		[self.navigationController presentViewController:tabbarVC animated:YES completion:^{
			self.view.window.rootViewController = tabbarVC;
		}];
		
	}
	
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
