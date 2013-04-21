//
//  SNStackBaseNavigationController.m
//
//  Created by Jackie CHEUNG on 12-11-17.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "SNStackBaseNavigationController.h"
#import "SNLevelViewTrantionGesture.h"
@interface UINavigationBar (SNStackBaseNavigationBar)<NSCopying>
@end

@implementation UINavigationBar (SNStackBaseNavigationBar)
/** confirm to protocol NSCopying to create snapshot */
- (id)copyWithZone:(NSZone *)zone{
    UINavigationBar *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return copy;
}
@end

@interface SNStackBaseNavigationController ()<SNTransitionGestureDataSource>
@property (nonatomic,strong) SNLevelViewTrantionGesture *transitionGesture;
@property (nonatomic,weak) UIViewController *fromViewController; //current transtion from which controller
@property (nonatomic,weak) UIViewController *toViewController; //current trantion to which controller

@property (nonatomic,strong) UIView *fromContentView;
@property (nonatomic,strong) UIView *toContentView;

@property (nonatomic,copy) NSArray *originalViewControllers;

@property (nonatomic,copy) UINavigationBar *snapShotNavigationBar; //false navigationbar

//save navigation bar hidden past state
@property (nonatomic) BOOL wasNavigationBarHidden;
@property (nonatomic) BOOL SavedNavigationBarHiddenState;
@end

@implementation SNStackBaseNavigationController
#pragma mark Property
- (SNBaseNavigationTransitionStyle)navigationTranstionStyle{
    return SNBaseNavigationTransitionStyleStack;
}

#pragma mark duplicated codes
- (void)_configureViewControllerFrame:(UIViewController *)controller hidden:(BOOL)hidden{
    //CGRect do divide in function,it's awesome btw.
    CGRect remainder,slice;
    CGRectDivide(self.view.bounds, &slice, &remainder, hidden ? 0.0f : CGRectGetHeight(self.navigationBar.bounds), CGRectMinYEdge);
    controller.view.frame = remainder;   
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_replaceItemsByControllers:(NSArray *)controllers toItemsByController:(NSArray *)replacingControllers forNavigationBar:(UINavigationBar *)navigationBar animated:(BOOL)animated{
    NSIndexSet *ids = [replacingControllers indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop){
        return [controllers containsObject:obj];
    }];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:replacingControllers.count];
    [replacingControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UINavigationItem *navigationItem = nil;
        if([ids containsIndex:idx]){
            @try {
                navigationItem = [navigationBar.items objectAtIndex:idx];
            }@catch (NSException *exception) {
                NSLog(@"encouter excpetion : %@",exception);
                return ;
            }
        }else{
            UIViewController *controller = (UIViewController *)obj;
            if (controller.navigationItem) {
                navigationItem = controller.navigationItem;
            }else{
                navigationItem = [[UINavigationItem alloc] initWithTitle:controller.title];
                navigationItem.leftItemsSupplementBackButton = YES;
            }
        }
        [items addObject:navigationItem];
    }];
    
    [navigationBar setItems:items animated:NO];
}

#pragma mark animation
- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                            duration:(NSTimeInterval)duration
                           direction:(SNBaseNavigationControllerTranstionDirection)direction
                          completion:(void (^)(BOOL))completion{    
    /*!FIX : only support dirtion from left or from right animtion now */
    WWViewTransitionType type;
    if(direction == SNBaseNavigationControllerTranstionDirectionFromLeft)
        type = SNViewTransitionTypeReverse;
    else if(direction == SNBaseNavigationControllerTranstionDirectionFromRight)
        type = SNViewTransitionTypeForward;
    else {
        type = SNViewTransitionTypeForward;
    }
    
    [self.transitionGesture beginTransitionAnimation:type completion:^(void){
        if(completion) completion(YES);
    }];
}

- (void)transitionNavigationBarHidden:(BOOL)hidden
                             duration:(NSTimeInterval)duration
                            direction:(SNBaseNavigationControllerTranstionDirection)direction
                           completion:(void (^)(BOOL))completion{
    
    void (^animationCompletionBlock)(BOOL finished) = ^(BOOL finished){
        if(finished){
            //synchronize state
            self.wasNavigationBarHidden = self.isNavigationBarHidden;
        }
        if(completion) completion(finished);
    };
    
    if(!direction && !self.transitionGesture.isGestureTransitioning){
        /** if no tranistion underway */        
        [super transitionNavigationBarHidden:hidden
                                    duration:duration
                                   direction:direction
                                  completion:animationCompletionBlock];
    }else{
        /*!! since we have handed over transtion animation to transtion gesture so we no need to run animation here.*/
        self.wasNavigationBarHidden = self.navigationBar.hidden;
        [UIView animateWithDuration:SNLevelViewTrantionGestureAnimationDurtion
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:nil
                         completion:animationCompletionBlock];
    }
}


#pragma mark View Recycle
- (void)viewDidLoad{
    [super viewDidLoad];
    SNLevelViewTrantionGesture *gesture = [SNLevelViewTrantionGesture gestureWithContentView:self.view DataSource:self];
    self.transitionGesture = gesture;
}

#pragma mark Property
- (UIView *)_toContentViewWithNavigationBarHidden:(BOOL)hidden{
    if (!_toContentView){
        [self _configureViewControllerFrame:self.toViewController hidden:hidden];
        
        UIView *toView          = [[UIView alloc] initWithFrame:self.view.bounds];
        toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.toContentView      = toView;
        
        [toView addSubview:self.toViewController.view];
    }
    return _toContentView;
}

- (UIView *)_fromContentViewWithNavigationBarHidden:(BOOL)hidden{
    if(!_fromContentView){
        [self _configureViewControllerFrame:self.fromViewController hidden:hidden];            
        
        UIView *fromView          = [[UIView alloc] initWithFrame:self.view.bounds];
        fromView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.fromContentView      = fromView;
        
        [fromView addSubview:self.fromViewController.view];
    }
    return _fromContentView;
}

- (UIView *)fromContentView{
    return [self _fromContentViewWithNavigationBarHidden:self.isNavigationBarHidden];
}

- (UIView *)toContentView{
    return [self _toContentViewWithNavigationBarHidden:self.isNavigationBarHidden];
}

#pragma mark BaseNavigationController
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(void))completion{
    
    if(self.transitionGesture.isTransitioning) return;
    
    self.fromViewController      = self.topViewController;
    self.toViewController        = viewControllers.lastObject;
    self.originalViewControllers = self.viewControllers;

    [super setViewControllers:viewControllers animated:animated completion:completion];
}

#pragma mark WWTransitionGestureDataSource
- (BOOL)gestureShouldHandleTransition:(SNViewTransitonGesture *)gestureRecognizer{
    if(self.viewControllers.count < 2) return NO;
    else return YES;
}

- (void)gesture:(SNViewTransitonGesture *)gestureRecongizer WillBeginTransitionFromView:(UIView *)fromView toView:(UIView *)toView{
    /**!!!
     Either calling gestureRecongizer.beginTransitionAnimation or using gesture will come here.
     
     ------------------------------------------------------------------------
     WHAT THE DIFFERENT BETWEEN GESTURE AND ANIMATION
     ------------------------------------------------------------------------
     is view hierarchy managing work have been done when run animation while it's totally different when using gesture.
     */
    if(gestureRecongizer.isGestureTransitioning){
        /** we need to save all state in case that gesture could be canceled then we are able to recover  */
        self.fromViewController      = self.topViewController;
        self.toViewController        = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
        self.originalViewControllers = self.viewControllers;
        
        [self.fromViewController removeFromParentViewController];
        [self.toViewController beginAppearanceTransition:YES animated:NO];
        [self.toViewController endAppearanceTransition];
        self.SavedNavigationBarHiddenState = self.wasNavigationBarHidden;
        
        _navigationControllerFlags.isAlreadyPoppingNavigationItem = YES;
        [self.navigationBar popNavigationItemAnimated:NO];
        
        _navigationControllerFlags.isNavigationControllerPoping = YES;
    }

            
    /** snapShotNavigationBar is a copy of self.navigation bar,which means they are totally the same.but snapshot support to be the previous state of bar so we need to change its state */
    self.snapShotNavigationBar                          = self.navigationBar;
    self.snapShotNavigationBar.frame                    = self.snapShotNavigationBar.bounds;
    self.snapShotNavigationBar.userInteractionEnabled   = NO;
    self.snapShotNavigationBar.hidden                   = self.wasNavigationBarHidden;
    [self _replaceItemsByControllers:self.viewControllers toItemsByController:self.originalViewControllers forNavigationBar:self.snapShotNavigationBar animated:NO];
}

- (UIView *)gesture:(SNViewTransitonGesture *)gestureRecongizer transitionViewOnLevel:(WWTranstionGestureViewLevel)viewLevel{
    /*!! this method will be called twice to return view required respectivly.So DO NOT put alloc things here or you can put it under switch statement! */
    switch (viewLevel) {
        case SNTranstionGestureViewLevelBottom:{
            //view on the bottom.probably different depend on what view controller we are poping,could be the root view or any view of view controller in the stack.
            UIView *bottomView = nil;
            if(_navigationControllerFlags.isNavigationControllerPoping){
                bottomView = [self _toContentViewWithNavigationBarHidden:self.isNavigationBarHidden];
                [bottomView addSubview:self.navigationBar];
            }else{
                bottomView = [self _fromContentViewWithNavigationBarHidden:self.wasNavigationBarHidden];
                [bottomView addSubview:self.snapShotNavigationBar];
            }
            
            return bottomView;
            
        }case SNTranstionGestureViewLevelTop:{
            //view on the top
            UIView *topView = nil;
            if(_navigationControllerFlags.isNavigationControllerPoping){
                topView = [self _fromContentViewWithNavigationBarHidden:self.wasNavigationBarHidden];
                [topView addSubview:self.snapShotNavigationBar];
            }else{
                topView = [self _toContentViewWithNavigationBarHidden:self.isNavigationBarHidden];
                [topView addSubview:self.navigationBar];
            }
            
            return topView;
        }
    }
    return nil;
}

- (void)gesture:(SNViewTransitonGesture *)gestureRecongizer didEndTransitionFromView:(UIView *)fromView toView:(UIView *)toView isCanceld:(BOOL)gestureIsCanceled{
    /*! there's serveral situration when this method is called.
        1.you call push or pop view controller method then gesture run the animation and come here.then you should do nothing since push or pop controller method have done the controller hierarchy managing work.
        2.you use gesture to swap views then come here.
        3.gesutre is canceled in midway.
     */
    if(gestureRecongizer.isGestureTransitioning && gestureIsCanceled){
        [self _replaceItemsByControllers:self.viewControllers toItemsByController:self.originalViewControllers forNavigationBar:self.navigationBar animated:NO];
        [self addChildViewController:self.fromViewController];
        
        [self.view addSubview:self.fromViewController.view];
        [self setNavigationBarHidden:self.SavedNavigationBarHiddenState];
    }else{
        [self.view addSubview:self.toViewController.view];
    }
    
    [self.view addSubview:self.navigationBar];
    
    [self.fromContentView removeFromSuperview];
    [self.toContentView removeFromSuperview];
    [self.snapShotNavigationBar removeFromSuperview];
    
    self.fromContentView = nil;
    self.toContentView   = nil;
    
    self.snapShotNavigationBar   = nil;
    self.fromViewController      = nil;
    self.toViewController        = nil;
    self.originalViewControllers = nil;
}

@end
