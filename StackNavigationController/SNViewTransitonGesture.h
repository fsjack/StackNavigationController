//
//  SNViewTransitonGesture.h
//
//  Created by Jackie on 12-10-21.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNGesture.h"
@class SNViewTransitonGesture;

typedef NS_ENUM(NSInteger, WWTranstionGestureViewLevel) {
    SNTranstionGestureViewLevelBottom,
    SNTranstionGestureViewLevelTop
};

typedef NS_ENUM(NSInteger, WWViewTransitionType) {
    SNViewTransitionTypeForward = 1,
    SNViewTransitionTypeReverse = 2
};

@protocol SNTransitionGestureDataSource <NSObject>
@required
//tell Datasource to return view on given level
- (UIView *)gesture:(SNViewTransitonGesture *)gestureRecongizer transitionViewOnLevel:(WWTranstionGestureViewLevel)viewLevel;

@optional
/** tell datasource to return the gesutre.its optional delegate method.why it's need to open to user it's because transtion gesture support to hidden from behind then user have no way out to disable the gesture,then gesture property is necessary */
@property (nonatomic,readonly)UIGestureRecognizer *gesture;
/** ask datasource should handle this gesture or not */
- (BOOL)gestureShouldHandleTransition:(SNViewTransitonGesture *)gestureRecognizer;

- (void)gesture:(SNViewTransitonGesture *)gestureRecongizer WillBeginTransitionFromView:(UIView *)fromView toView:(UIView *)toView;
- (void)gesture:(SNViewTransitonGesture *)gestureRecongizer didEndTransitionFromView:(UIView *)fromView toView:(UIView *)toView isCanceld:(BOOL)gestureIsCanceled;

@end


extern CGFloat const kSNCommitTransitionDefaultLength;
/**
 * Its abstract class and have no effect on view transtion.You can write your own gesutre by subclassing this class and you can take a look at the WWLevelViewTransitionGesture for the reference.
 */
@interface SNViewTransitonGesture : SNGesture{
@protected
    struct {
        unsigned int isGesturePrepared:1;
        unsigned int isTransitioning:2;
        unsigned int isTransitionCanceled:1;
        unsigned int isGestureTransitioning:1;
    }_transitionGestureFlags;
}

@property (nonatomic,weak) id<SNTransitionGestureDataSource> dataSource;

@property (nonatomic,readonly) UIPanGestureRecognizer *gesture;
@property (nonatomic,readonly) UIView *bottomView;
@property (nonatomic,readonly) UIView *topView;

@property (nonatomic,readonly) BOOL isTransitioning;
@property (nonatomic,readonly) BOOL isGestureTransitioning;

/**---------------------------------------------------------------------------------------
 * @name Initialtion
 *--------------------------------------------------------------------------------------- */
+ (id)gestureWithContentView:(UIView *)view DataSource:(id <SNTransitionGestureDataSource>)dataSource;

/**---------------------------------------------------------------------------------------
 * @name Animation
 *--------------------------------------------------------------------------------------- */
- (void)beginTransitionAnimation:(WWViewTransitionType)direction completion:(void (^)(void))completion;

@end

/** protected method.subclass should rewrite these methods and you should NEVER call this mehod directly*/
@interface SNViewTransitonGesture (WWViewTransitonGestureProtectedMethod)
- (void)prepareGestureAnimation;
- (void)stopGestureAnimation;
- (void)gesture:(UIPanGestureRecognizer *)gesture translation:(CGPoint)translation;
@end