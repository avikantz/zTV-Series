//
//  ShowsTableViewCell.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genresLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelCountryLabel;

- (void)fillUsingShow:(TVShow *)show;

@end
