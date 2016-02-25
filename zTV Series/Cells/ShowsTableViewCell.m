//
//  ShowsTableViewCell.m
//  zTV Series
//
//  Created by Avikant Saini on 2/25/16.
//  Copyright © 2016 avikantz. All rights reserved.
//

#import "ShowsTableViewCell.h"

@implementation ShowsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//- (void)drawRect:(CGRect)rect {
//	
//	[super drawRect:rect];
//	
//	UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//	[bezierPath moveToPoint:CGPointMake(12, self.bounds.size.height - 1)];
//	[bezierPath addLineToPoint:CGPointMake(self.bounds.size.width - 24, self.bounds.size.height - 1)];
//	[UIColor.lightGrayColor setStroke];
//	[bezierPath stroke];
//	
//}

- (void)fillUsingShow:(TVShow *)show {
	
	self.nameLabel.text = show.name;
	self.overviewLabel.text = show.overview;
	self.genresLabel.text = show.genres;
	self.channelCountryLabel.text = [NSString stringWithFormat:@"%@ | %@", show.channel, show.country];
	
	self.backgroundImageView.clipsToBounds = YES;
	[self.backgroundImageView sd_setImageWithURL:show.imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		self.backgroundImageView.image = [image applyExtraLightEffect];
	}];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
