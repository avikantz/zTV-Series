//
//  ToWatchTableViewCell.h
//  zTV Series
//
//  Created by Avikant Saini on 4/17/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToWatchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *epsCountLabek;

@property (weak, nonatomic) IBOutlet UILabel *showNameLabe;
@property (weak, nonatomic) IBOutlet UILabel *epsNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *seenButton;

@end
