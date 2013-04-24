//
//  SNLevelViewTrantionGesture.m
//
//  Created by Jackie on 12-10-21.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "SNLevelViewTrantionGesture.h"
#import <QuartzCore/QuartzCore.h>
#import "easing.h"

const CGFloat SNLevelViewTrantionGestureAnimationDurtion    = .6f;
const CGFloat SNLevelViewTrantionGestureBottomViewDistance  = 50.0f;

@interface SNLevelViewTrantionGesture()
@property (nonatomic,strong) CADisplayLink *timer;
@property (nonatomic, weak) CALayer *depthLayer;
@property (nonatomic) CGFloat animationProgress;
@property (nonatomic) CGFloat startingTranslationValue;
@end

@implementation SNLevelViewTrantionGesture
#pragma mark init
- (void)_defaultConfiguration{
    self.depthEnabled   = YES;
    self.shadowEnabled  = YES;
}


- (id)init{
    self = [super init];
    if(self) {
        [self _defaultConfiguration];
    }
    return self;
}

#pragma mark Logic
- (void)translateAnimationByTransitionX:(float)transitionX{
    self.topView.transform = CGAffineTransformMakeTranslation(transitionX, 0);
    
    float fraction = self.topView.transform.tx / self.topView.bounds.size.width;
    
    CATransform3D transfrom3D       = CATransform3DIdentity;
    transfrom3D.m34                 = - 1./400;
    self.bottomView.layer.transform   = CATransform3DTranslate(transfrom3D, 0, 0, -SNLevelViewTrantionGestureBottomViewDistance + SNLevelViewTrantionGestureBottomViewDistance*fraction);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.depthLayer.opacity = 0.7f-(0.7f*fraction);
    [CATransaction commit];
}

#pragma mark Gesture
- (void)prepareGestureAnimation{
    [super prepareGestureAnimation];
    
    [self.contentView addSubview:self.topView];
    [self.contentView insertSubview:self.bottomView belowSubview:self.topView];
    
    if(!self.depthLayer && self.depthEnabled){
        CALayer *depthLayer = [[CALayer alloc] init];
        depthLayer.frame = self.bottomView.bounds;
        depthLayer.backgroundColor = [UIColor blackColor].CGColor;
        depthLayer.opacity = 0.0f;
        self.depthLayer = depthLayer;
        [self.bottomView.layer addSublayer:depthLayer];
    }
    
    if(self.shadowEnabled){
        CALayer *layer = self.topView.layer;
        layer.shadowColor   = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.7f;
        layer.shadowOffset  = CGSizeMake(0, 0);
        layer.shadowRadius  = 5.0f;

        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.topView.bounds];
        layer.shadowPath = path.CGPath;
    }
    
    if(_transitionGestureFlags.isTransitioning == SNViewTransitionTypeForward){
        self.topView.transform = CGAffineTransformMakeTranslation(self.contentView.bounds.size.width, 0);
    }
}

- (void)stopGestureAnimation{    
    [self.timer invalidate];
    self.timer = nil;
    
    self.animationProgress          = 0.0f;
    self.startingTranslationValue   = 0.0f;
    
    /* remove depth layer */
    [self.depthLayer removeFromSuperlayer];
    
    /* remove shadow layer */
    self.topView.layer.shadowPath = nil;
    
    if(_transitionGestureFlags.isTransitioning == SNViewTransitionTypeForward)
        [self.bottomView removeFromSuperview];
    else 
        [self.topView removeFromSuperview];
    
    self.topView.layer.transform    = CATransform3DIdentity;
    self.bottomView.layer.transform = CATransform3DIdentity;
    
    [super stopGestureAnimation];    
}

- (void)gesture:(UIPanGestureRecognizer *)gesture translation:(CGPoint)translation{
    [super gesture:gesture translation:translation];
    [self translateAnimationByTransitionX:translation.x];
}


#pragma mark Animation
/**
 refresh_rate = self.timer.duration
 animation_progress += refresh_rate / animation_duration
 */
- (void)animateTranslationByFrame{
    CGFloat fraction;
    if(_transitionGestureFlags.isTransitioning == SNViewTransitionTypeReverse){
        fraction = (CGRectGetWidth(self.contentView.bounds) - self.startingTranslationValue) / CGRectGetWidth(self.contentView.bounds);
    }else{
        fraction = self.startingTranslationValue / CGRectGetWidth(self.contentView.bounds);
    }
    
    self.animationProgress += self.timer.duration / (SNLevelViewTrantionGestureAnimationDurtion * fraction);
    
    if(self.animationProgress > 1.0f){
        [self stopGestureAnimation];
    }else{
        float transitionX,progress;
        progress = QuarticEaseOut(self.animationProgress);
        if(_transitionGestureFlags.isTransitioning == SNViewTransitionTypeReverse){
            transitionX = self.startingTranslationValue + (CGRectGetWidth(self.contentView.bounds) - self.startingTranslationValue) * progress;
        }else{
            transitionX = self.startingTranslationValue * ( 1.0f - progress);
        }
        [self translateAnimationByTransitionX:transitionX];
    }
}

- (void)beginTransitionAnimation:(WWViewTransitionType)direction completion:(void (^)(void))completion{
    [super beginTransitionAnimation:direction completion:completion];
    
    self.startingTranslationValue = self.topView.transform.tx;
    self.animationProgress        = 0.0f;
    
    if(self.timer) [self.timer invalidate];
    
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateTranslationByFrame)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

@end
