//
//  SNGesture.h
//
//  Created by Jackie CHEUNG on 12-12-20.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNGesture : NSObject
- (void)enableGesture:(BOOL)isEnabled; //subclass should overrider this method

@property (nonatomic,readonly) UIView *contentView;

@end

@interface UIView (UIViewSNGestures)
@property(nonatomic,copy) NSArray *gestures;

- (void)addGesture:(SNGesture *)gesture;
- (void)removeGesture:(SNGesture *)gesture;

@end