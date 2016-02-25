//
//  RawQuerySetupTableViewController.m
//  zTV Series
//
//  Created by Avikant Saini on 2/24/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "RawQuerySetupTableViewController.h"
#import "RawQueryViewController.h"

@interface RawQuerySetupTableViewController ()

@property (weak, nonatomic) IBOutlet UITextView *queryTextView;

@end

@implementation RawQuerySetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastRawQuery"])
		self.queryTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRawQuery"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addKeywordAction:(UIButton *)sender {
	self.queryTextView.text = [NSString stringWithFormat:@"%@%@%@ ", self.queryTextView.text, ([self.queryTextView.text hasSuffix:@"\n"])?@"":@" ", sender.titleLabel.text];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"RawQuerySegue"]) {
		
		[[NSUserDefaults standardUserDefaults] setObject:self.queryTextView.text forKey:@"lastRawQuery"];
		
		RawQueryViewController *rqvc = [segue destinationViewController];
		
		rqvc.queryString = self.queryTextView.text;
		
	}
	
}

@end
