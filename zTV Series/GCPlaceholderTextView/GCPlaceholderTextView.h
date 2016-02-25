//
//  GCPlaceholderTextView.h
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-16.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCPlaceholderTextView : UITextView 

@property (nonatomic, strong) IBInspectable NSString *placeholder;

@property (nonatomic, strong) IBInspectable UIColor *realTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) IBInspectable UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

@end
