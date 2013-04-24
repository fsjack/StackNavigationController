//
//  SNGesture.m
//
//  Created by Jackie CHEUNG on 12-12-20.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "SNGesture.h"
#import <objc/runtime.h>

@interface SNGesture ()
@property (nonatomic,weak) UIView *internalContentView;
@end

@implementation SNGesture
- (void)enableGesture:(BOOL)isEnabled{
    NSAssert(nil, @"subclass must overrider this method");
}

- (UIView *)contentView{
    return self.internalContentView;
}

@end

static char kSNGesturesObjectKey;
@implementation UIView (UIViewSNGestures)
- (void)setGestures:(NSArray *)gestures{
    objc_setAssociatedObject(self, &kSNGesturesObjectKey, gestures, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)gestures{
    return objc_getAssociatedObject(self, &kSNGesturesObjectKey);
}


- (void)addGesture:(SNGesture *)gesture{
    gesture.internalContentView = self;
    [gesture enableGesture:YES];
    if(!self.gestures){
        NSArray *gestures = [NSArray arrayWithObject:gesture];
        self.gestures = gestures;
    }else{
        if([self.gestures containsObject:gesture]) return;
        self.gestures = [self.gestures arrayByAddingObject:gesture];
    }
}

- (void)removeGesture:(SNGesture *)gesture{
    if(gesture.internalContentView == self) {
        [gesture enableGesture:NO];
        gesture.internalContentView = nil;
    }
    if(gesture && [self.gestures containsObject:gesture]){
        NSMutableArray *gestures = [NSMutableArray arrayWithArray:self.gestures];
        [gestures removeObject:gesture];
        self.gestures = gestures;
    }
}

@end