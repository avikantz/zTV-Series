//
//  EpisodeDetailViewController.h
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpisodeDetailViewController : UIViewController

@property (nonatomic, strong) TVShow *show;
@property (nonatomic, strong) Episode *episode;

@end