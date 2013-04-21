//
//  SNBaseNavigationController.h
//
//  Created by Jackie CHEUNG on 12-11-14.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#ifndef QUARTZCORE_H
#warning "QuartzCore framework not found in project, or not included in precompiled header. transition animation functionality will not be available."
#endif

extern CGFloat const SNBaseNavigationControllerTransitionDuration;
extern CGFloat const SNBaseNavigationControllerHideShowBarDuration;

typedef NS_ENUM(NSInteger, SNBaseNavigationControllerTranstionDirection) {
    SNBaseNavigationControllerTranstionDirectionFromTop     = 1,
    SNBaseNavigationControllerTranstionDirectionFromBottom  = 2,
    SNBaseNavigationControllerTranstionDirectionFromLeft    = 3,
    SNBaseNavigationControllerTranstionDirectionFromRight   = 4
};

typedef NS_ENUM(NSInteger, SNBaseNavigationTransitionStyle) {
    SNBaseNavigationTransitionStyleDefault,  // Push/Pop tranistion style
    SNBaseNavigationTransitionStyleStack     // Stack transiton style
};

/*!
 SNBaseNavigationController manages a stack of view controllers and a navigation bar.
 It performs horizontal view transitions for pushed and popped views while keeping the navigation bar in sync.
 
 Most clients will not need to subclass SNBaseNavigationController.
 
 If a navigation controller is nested in a tabbar controller, it uses the title and toolbar attributes of the bottom view controller on the stack.
 
 SNBaseNavigationController is rotatable if its top view controller is rotatable.
 Navigation between controllers with non-uniform rotatability is currently not supported.
 */
@protocol SNBaseNavigationControllerDelegate;
@interface SNBaseNavigationController : UIViewController{ //Simple Factory Pattern
@protected
    struct {
        unsigned int isAlreadyPoppingNavigationItem:1;
        unsigned int isTransitioning:3;
        unsigned int isNavigationBarHidden:1;
        unsigned int isNavigationControllerPoping:1;
    } _navigationControllerFlags;
}
/** Convenience method pushes the root view controller without animation. */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/** Uses a horizontal slide transition. Has no effect if the view controller is already in the stack. */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/** Returns the popped controller. */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

/** Pops view controllers until the one specified is on top. Returns the popped controllers. */
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
/** Pops until there's only a single view controller left on the stack. Returns the popped controllers. */
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

/** The top view controller on the stack. */
@property (nonatomic,readonly,retain) UIViewController *topViewController;
/** Return modal view controller if it exists. Otherwise the top view controller. */
@property (nonatomic,readonly,retain) UIViewController *visibleViewController;

/** The current view controller stack. */
@property (nonatomic,copy) NSArray *viewControllers;
/** If animated is YES, then simulate a push or pop depending on whether the new top view controller was previously in the stack. */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated NS_AVAILABLE_IOS(3_0);

/** Hide or show the navigation bar. If animated, it will transition vertically using UINavigationControllerHideShowBarDuration. */
@property (nonatomic,getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

/** The navigation bar managed by the controller. Pushing, popping or setting navigation items on a managed navigation bar is not supported. */
@property (nonatomic,readonly) UINavigationBar *navigationBar;

@property(nonatomic, weak) id<SNBaseNavigationControllerDelegate> delegate;

/** NavigationController transition style*/
@property (nonatomic,readonly) SNBaseNavigationTransitionStyle navigationTranstionStyle;

@end

@interface SNBaseNavigationController (SNBaseNavigationControllerCreation)
/** Convenience method generate navigation controller with different transition style. */
+ (id)navigationWithRootController:(UIViewController *)rootViewController navigationTransitionStyle:(SNBaseNavigationTransitionStyle)transtionStyle;
@end

/** SHOULD NOT call or rewrite these method except for that you want to wirte your own transtion animation */
@interface SNBaseNavigationController (SNBaseNavigationControllerProtectedMethod)
- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                            duration:(NSTimeInterval)duration
                           direction:(SNBaseNavigationControllerTranstionDirection)direction
                          completion:(void (^)(BOOL))completion;

- (void)transitionNavigationBarHidden:(BOOL)hidden
                             duration:(NSTimeInterval)duration
                            direction:(SNBaseNavigationControllerTranstionDirection)direction
                           completion:(void (^)(BOOL))completion;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(void))completion NS_AVAILABLE_IOS(3_0);
@end

@protocol SNBaseNavigationControllerDelegate <NSObject>
@optional
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(SNBaseNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(SNBaseNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end


@interface UIViewController (SNBaseNavigationController)
@property(nonatomic,readonly,retain) SNBaseNavigationController *baseNavigationController;
@property(nonatomic,readonly,retain) UINavigationController *navigationController;
@end
