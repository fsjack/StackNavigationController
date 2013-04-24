//
//  SNViewTransitonGesture.m
//
//  Created by Jackie on 12-10-21.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "SNViewTransitonGesture.h"
const CGFloat kSNCommitTransitionDefaultLength = 100.0f;

@interface SNViewTransitonGesture()<UIGestureRecognizerDelegate>
@property (nonatomic,weak) UIView *internalBottomView;
@property (nonatomic,weak) UIView *internalTopView;

@property (nonatomic,strong) UIPanGestureRecognizer * internalGestureRecognizer;

@property (nonatomic,copy) void (^animationCompletionBlock)(void);
@end

#pragma mark - Implementation
@implementation SNViewTransitonGesture
#pragma mark Class Method
+ (id)gestureWithContentView:(UIView *)view DataSource:(id <SNTransitionGestureDataSource>)dataSource{
    SNViewTransitonGesture *transitionGesture   = [[[self class] alloc] init];
    transitionGesture.dataSource                = dataSource;
    transitionGesture.internalGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:transitionGesture action:@selector(panGesture:)];
    transitionGesture.gesture.delegate          = transitionGesture;
    
    [view addGesture:transitionGesture];
    
    return transitionGesture;
}

#pragma mark Property
- (UIView *)bottomView{
    return self.internalBottomView;
}

- (UIView *)topView{
    return self.internalTopView;
}

- (UIPanGestureRecognizer *)gesture{
    return self.internalGestureRecognizer;
}

- (BOOL)isTransitioning{
    return _transitionGestureFlags.isTransitioning;
}

- (BOOL)isGestureTransitioning{
    return _transitionGestureFlags.isGestureTransitioning;
}

#pragma mark Logic
- (void)enableGesture:(BOOL)isEnabled{
    if(isEnabled)
        [self.contentView addGestureRecognizer:self.gesture];
    else
        [self.contentView removeGestureRecognizer:self.gesture];
}

#pragma mark Animation
- (void)beginTransitionAnimation:(WWViewTransitionType)direction completion:(void (^)(void))completion{
    _transitionGestureFlags.isTransitioning = direction;
    self.animationCompletionBlock = completion;    
    if(!_transitionGestureFlags.isGesturePrepared) [self prepareGestureAnimation];
}

#pragma mark UIGestureRecognizerDelegate
- (void)panGesture:(UIPanGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        /** initial everything that needed to be prepared.like handling view hierarchy.*/
        _transitionGestureFlags.isGestureTransitioning = YES;
        [self prepareGestureAnimation];
        
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        /** subclass need to rewrite gesture:translation: method to react to the change of translation value */
        CGPoint translation = [gesture translationInView:self.topView];
        if(translation.x < 0.0f) return;
        [self gesture:gesture translation:translation];
        
    }else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        /** when you put your finger out of screeen.gesture will automatically run the animation to fill blank space */
        CGPoint translation = [gesture translationInView:self.topView];
        if(translation.x > kSNCommitTransitionDefaultLength){
            [self beginTransitionAnimation:SNViewTransitionTypeReverse completion:nil];
        }else{
            _transitionGestureFlags.isTransitionCanceled = YES;
            [self beginTransitionAnimation:SNViewTransitionTypeForward completion:nil];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(_transitionGestureFlags.isTransitioning) return NO;
    
    if([self.dataSource respondsToSelector:@selector(gestureShouldHandleTransition:)])
        return [self.dataSource gestureShouldHandleTransition:self];
    else
        return !_transitionGestureFlags.isTransitioning;
}

@end

@implementation SNViewTransitonGesture (WWViewTransitonGestureProtectedMethod)
- (void)prepareGestureAnimation{
    if([self.dataSource respondsToSelector:@selector(gesture:WillBeginTransitionFromView:toView:)]){
        [self.dataSource gesture:self WillBeginTransitionFromView:self.bottomView toView:self.topView];
    }
    
    self.internalBottomView = [self.dataSource gesture:self transitionViewOnLevel:SNTranstionGestureViewLevelBottom];
    self.internalTopView    = [self.dataSource gesture:self transitionViewOnLevel:SNTranstionGestureViewLevelTop];
    
    NSAssert((self.internalBottomView && self.internalTopView), @"from view or to view could not be nil");
    
    _transitionGestureFlags.isGesturePrepared  = YES;
    if(!_transitionGestureFlags.isTransitioning)
        _transitionGestureFlags.isTransitioning    = SNViewTransitionTypeReverse;
}

/** this method were called when subclass finish the animation.mainly do the clean up work */
- (void)stopGestureAnimation{
    if([self.dataSource respondsToSelector:@selector(gesture:didEndTransitionFromView:toView:isCanceld:)]){
        [self.dataSource gesture:self didEndTransitionFromView:self.bottomView toView:self.topView isCanceld:_transitionGestureFlags.isTransitionCanceled];
    }
    
    self.internalBottomView   = nil;
    self.internalTopView      = nil;
    
    if(self.animationCompletionBlock) self.animationCompletionBlock();
    self.animationCompletionBlock = nil;
    
    _transitionGestureFlags.isGesturePrepared      = NO;
    _transitionGestureFlags.isTransitioning        = NO;
    _transitionGestureFlags.isTransitionCanceled   = NO;
    _transitionGestureFlags.isGestureTransitioning = NO;    
}

/** we do nothing */
- (void)gesture:(UIPanGestureRecognizer *)gesture translation:(CGPoint)translation{
}
@end