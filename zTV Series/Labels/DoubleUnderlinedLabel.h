//
//  DoubleUnderlinedLabel.h
//
//  Created by Avikant Saini on 12/14/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubleUnderlinedLabel : UILabel

@property IBInspectable CGFloat lineWidth;
@property IBInspectable CGFloat offset;
@property (strong, nonatomic) IBInspectable UIColor *lineColor;

@end
