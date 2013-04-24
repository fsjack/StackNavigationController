//
//  SNLevelViewTrantionGesture.h
//
//  Created by Jackie on 12-10-21.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "SNViewTransitonGesture.h"

extern const CGFloat SNLevelViewTrantionGestureAnimationDurtion;
extern const CGFloat SNLevelViewTrantionGestureBottomViewDistance;

/** FIX: new direction transtion is needed. */

@interface SNLevelViewTrantionGesture : SNViewTransitonGesture
@property (nonatomic) BOOL shadowEnabled; //enable shadow below the top view.default YES
@property (nonatomic) BOOL depthEnabled; //enable the depth effect on the bottom view.default YES

@end
