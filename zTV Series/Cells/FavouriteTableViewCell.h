//
//  FavouriteTableViewCell.h
//  zTV Series
//
//  Created by Avikant Saini on 4/17/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *episodeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeAirdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeNoLabel;

@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end
