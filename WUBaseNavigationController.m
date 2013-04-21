//
//  WUBaseNavigationController.m
//
//  Created by Jackie CHEUNG on 12-11-14.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "WUBaseNavigationController.h"
CGFloat const WUBaseNavigationControllerTransitionDuration  = .4f;
CGFloat const WUBaseNavigationControllerHideShowBarDuration = .3f;

@interface WUBaseNavigationController ()<UINavigationBarDelegate>
@property (nonatomic,weak) UINavigationBar *navigationBar;
@end

@implementation WUBaseNavigationController
#pragma mark Transition 
/**
    @name   Push transition animation
    @params fromViewController   transition from which view controller that will be disappear at the last
    @params toViewControoler     transtion to which viewController
    @params duration             duration
    @params direction            direction
    @params completion           completion block
 */
- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                            duration:(NSTimeInterval)duration
                           direction:(WUBaseNavigationControllerTranstionDirection)direction
                          completion:(void (^)(BOOL))completion{
    
    NSAssert(fromViewController != toViewController, @"from viewController should not equal to to viewController");
    
    [self _configureViewControllerFrame:toViewController];
    
    CGRect fromOriginalRect = fromViewController.view.frame;
    CGRect fromModifiedRect = fromViewController.view.frame;
    
    CGRect toOriginalRect   = toViewController.view.frame;
    CGRect toModifiedRect   = toViewController.view.frame;
    
    switch (direction) {
        case WUBaseNavigationControllerTranstionDirectionFromTop:
            fromModifiedRect.origin.y   = CGRectGetMaxY(fromViewController.view.frame);
            toOriginalRect.origin.y     = CGRectGetMinY(toViewController.view.frame) - CGRectGetHeight(toViewController.view.bounds);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromBottom:
            fromModifiedRect.origin.y   = CGRectGetMinY(fromViewController.view.frame) - CGRectGetHeight(fromViewController.view.bounds);
            toOriginalRect.origin.y     = CGRectGetMaxY(toViewController.view.frame);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromLeft:
            fromModifiedRect.origin.x   = CGRectGetMaxX(fromViewController.view.frame);
            toOriginalRect.origin.x     = CGRectGetMinX(toViewController.view.frame) - CGRectGetWidth(toViewController.view.bounds);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromRight:
            fromModifiedRect.origin.x   = CGRectGetMinX(fromViewController.view.frame) - CGRectGetWidth(fromViewController.view.bounds);
            toOriginalRect.origin.x     = CGRectGetMaxX(toViewController.view.frame);
            break;
        default:
            break;
    }

    fromViewController.view.frame = fromOriginalRect;
    toViewController.view.frame   = toOriginalRect;
    
    [self.view addSubview:fromViewController.view];
    [self.view addSubview:toViewController.view];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         fromViewController.view.frame = fromModifiedRect;
                         toViewController.view.frame   = toModifiedRect;
                     }completion:^(BOOL finished){
                         if(finished) [fromViewController.view removeFromSuperview];
                         if(completion) completion(finished);
                     }];
    
    /** calling transitionFromViewController will move toViewController view in the front.so we need to move navigationBar in the front */
    [self.view bringSubviewToFront:self.navigationBar];
}

/**
    @name navigation bar transion animation
    @discussion we need to deal with different situration when performing different direction transion,and when it's not transitioning.
    @params hidden          hidden or not
    @params duration        animation duration
    @params direction       transion direction.it's actually controlled by isAlreadyPoppingNavigationItem flag in _navigationControllerFlags.its 3 bit width variable that not only save WUBaseNavigationControllerTranstionDirection state but also,as it's name indicated,save if navigation controller is in transitioning state.
    @params completion      completion block
 */
- (void)transitionNavigationBarHidden:(BOOL)hidden
                             duration:(NSTimeInterval)duration
                            direction:(WUBaseNavigationControllerTranstionDirection)direction
                           completion:(void (^)(BOOL))completion{
    
    UINavigationBar *navigationBar = self.navigationBar;
    if(navigationBar.hidden == hidden) return;
    
    navigationBar.frame = navigationBar.bounds;
    CGRect originalRect = navigationBar.bounds;
    CGRect modifiedRect = navigationBar.bounds;
    
    void (^defaultAnimation)(void) = nil; /** need to change view controller view frame when performing default navigation bar hidden animation */
    
    switch (direction) {
        case WUBaseNavigationControllerTranstionDirectionFromTop:
            if(hidden) modifiedRect.origin.y = CGRectGetMinY(navigationBar.frame) + CGRectGetHeight(self.view.bounds);
            else       originalRect.origin.y = CGRectGetMinY(navigationBar.frame) - CGRectGetHeight(self.view.bounds);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromBottom:
            if(hidden) modifiedRect.origin.y = CGRectGetMinY(navigationBar.frame) - CGRectGetHeight(self.view.bounds);
            else       originalRect.origin.y = CGRectGetMinY(navigationBar.frame) + CGRectGetHeight(self.view.bounds);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromLeft:
            if(hidden) modifiedRect.origin.x = CGRectGetMinX(navigationBar.frame) + CGRectGetWidth(navigationBar.bounds);
            else       originalRect.origin.x = CGRectGetMinX(navigationBar.frame) - CGRectGetWidth(navigationBar.bounds);
            break;
        case WUBaseNavigationControllerTranstionDirectionFromRight:
            if(hidden) modifiedRect.origin.x = CGRectGetMinX(navigationBar.frame) - CGRectGetWidth(navigationBar.bounds);
            else       originalRect.origin.x = CGRectGetMinX(navigationBar.frame) + CGRectGetWidth(navigationBar.bounds);
            break;
        default:
            if(hidden) modifiedRect.origin.y = CGRectGetMinY(navigationBar.frame) - CGRectGetHeight(navigationBar.bounds);
            else       originalRect.origin.y = CGRectGetMinY(navigationBar.frame) - CGRectGetHeight(navigationBar.bounds);
            WUBaseNavigationController * __weak weakSelf = self;
            defaultAnimation = ^{
                [weakSelf _configureViewControllerFrame:weakSelf.topViewController];
            };
            break;
    }
    
    navigationBar.frame  = originalRect;
    navigationBar.hidden = NO;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         navigationBar.frame = modifiedRect;
                         if(defaultAnimation) defaultAnimation();
                     }completion:completion];
}

#pragma mark Init
/** Default initialtion configuration */
- (void)_configureDefault{
    [self _configureNavigationBar];
    [self setNavigationBarHidden:NO];
}

- (void)_configureNavigationBar{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationBar             = navigationBar;
    self.navigationBar.delegate    = self;
    [self.view addSubview:navigationBar];
}

/** reset the controller view frame to fit self.view screen size and the navigation bar size */
- (void)_configureViewControllerFrame:(UIViewController *)controller{
    //CGRect do divide in function,it's awesome btw.
    CGRect remainder,slice;
    CGRectDivide(self.view.bounds, &slice, &remainder, self.isNavigationBarHidden ? 0.0f : CGRectGetHeight(self.navigationBar.bounds), CGRectMinYEdge);
    controller.view.frame = remainder;
    
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_setRootViewController:(UIViewController *)rootViewController{
    /** better way but not still got bug yet */
//    [self setViewControllers:[NSArray arrayWithObject:rootViewController] animated:NO];
    
    [rootViewController beginAppearanceTransition:YES animated:NO];
    [rootViewController willMoveToParentViewController:self];
    [self addChildViewController:rootViewController];
    [self.view addSubview:rootViewController.view];
    [self _configureViewControllerFrame:rootViewController];
    [rootViewController didMoveToParentViewController:self];
    [rootViewController endAppearanceTransition];
    
    [self.navigationBar pushNavigationItem:rootViewController.navigationItem animated:NO];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super init];
    if(self){
        [self _configureDefault];        
        [self _setRootViewController:rootViewController];
        [self.view bringSubviewToFront:self.navigationBar];
    }
    return self;
}

#pragma mark Navigation Item
/** replacing with new view controllers stack.if new stack contain old view controller we will find it and reuse corresponding navigation item without creating new one */
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

    [navigationBar setItems:items animated:animated];
}

#pragma mark Navigation Push
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated{
    if(viewController == self.topViewController) return;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [viewControllers addObject:viewController];

    [viewController willMoveToParentViewController:self];
    id __weak weakSelf = self;
    [self setViewControllers:viewControllers
                    animated:animated
                  completion:^(void){
                      [viewController didMoveToParentViewController:weakSelf];
                  }];
}

#pragma mark Navigation Pop
- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated{
    
    if(viewController == self.topViewController) return @[];
    
    NSArray *removedControllers = nil;
    NSArray *remainControllers  = nil;
    @try {
        /** get viewControllers will be removed */
        NSInteger idx          = [self.viewControllers indexOfObject:viewController];
        removedControllers     = [self.viewControllers subarrayWithRange:NSMakeRange(idx+1, self.viewControllers.count-idx-1)];
        remainControllers      = [self.viewControllers subarrayWithRange:NSMakeRange(0, idx+1)];
    }@catch (NSException *exception) {
        NSLog(@"popToViewController ecounter excpetion:%@",exception);
        return @[];
    }
    
    UIViewController *fromViewController = self.topViewController;
    [viewController willMoveToParentViewController:self];
    [fromViewController willMoveToParentViewController:nil];
    id __weak weakSelf = self;
    [self setViewControllers:remainControllers
                    animated:animated
                  completion:^(void){
                      [fromViewController didMoveToParentViewController:nil];
                      [viewController didMoveToParentViewController:weakSelf];
                  }];
    
    return removedControllers;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    if(self.viewControllers.count < 2) return nil;

    UIViewController *topViewController = self.topViewController;
    UIViewController *toViewController   = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
    
    [self popToViewController:toViewController animated:animated];
    return topViewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    if(self.viewControllers.count <= 1) return @[];
    return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

#pragma mark set View Controllers
- (void)setViewControllers:(NSArray *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    [self setViewControllers:viewControllers animated:animated completion:nil];
}

/** primary navigation method */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(void))completion{
    if(_navigationControllerFlags.isTransitioning) return;
    
    BOOL pop = [self.viewControllers containsObject:viewControllers.lastObject];
    _navigationControllerFlags.isNavigationControllerPoping = pop;
    
    /** decide what direction is transtion from */
    _navigationControllerFlags.isTransitioning = pop ? WUBaseNavigationControllerTranstionDirectionFromLeft : WUBaseNavigationControllerTranstionDirectionFromRight;
    _navigationControllerFlags.isTransitioning = animated ? _navigationControllerFlags.isTransitioning : NO;
    
    UIViewController *fromViewController = self.topViewController;
    UIViewController *toViewController   = viewControllers.lastObject;
    NSArray *originalViewControllers     = self.viewControllers;
    
    /*!!! we have done all view hierarchy managing work before going to transition */
    WUBaseNavigationController * __weak weakSelf = self;    
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIViewController *viewController = (UIViewController *)obj;
        [viewController removeFromParentViewController];
    }];
    
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIViewController *viewController = (UIViewController *)obj;
        [weakSelf addChildViewController:viewController];
    }];
    
    void (^beginTransitionBlock)(void) = ^{
        [toViewController beginAppearanceTransition:YES animated:animated];
        [fromViewController beginAppearanceTransition:NO animated:animated];
        
        [weakSelf.delegate navigationController:self willShowViewController:toViewController animated:animated];
    };
    
    /** completion block will be called right after view transtion animation is done */
    void (^endTransitionBlock)(BOOL finsihed) = ^(BOOL finished){
        if(finished){
            if(completion) completion();
            [fromViewController endAppearanceTransition];
            [toViewController endAppearanceTransition];
            _navigationControllerFlags.isTransitioning              = NO;
            _navigationControllerFlags.isNavigationControllerPoping = NO;
            
            [weakSelf.delegate navigationController:self didShowViewController:toViewController animated:animated];
        }
    };
    
    void (^resetNavigationItemAnimated)(BOOL animated) = ^(BOOL animated){
        if(!_navigationControllerFlags.isAlreadyPoppingNavigationItem)
            [weakSelf _replaceItemsByControllers:originalViewControllers toItemsByController:viewControllers forNavigationBar:self.navigationBar animated:animated];
    };
    
    /*!! no animation if viewControllers.lastObject == self.topViewController  */
    if(self.viewControllers.lastObject == originalViewControllers.lastObject || !originalViewControllers.count) {
        beginTransitionBlock();
        resetNavigationItemAnimated(NO);
        [self.view addSubview:toViewController.view];
        [self _configureViewControllerFrame:toViewController];        
        endTransitionBlock(YES);
        return;
    }
    
    /*!!! since we have done all view hierarchy managing work before going to transition,when we subclass navigation controller and rewrite our own custom transtion animation,you got to remember that view hierarchy have been changed,so you probably need to save the oringal stack for backup.  */
    beginTransitionBlock();
    if(pop){
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:animated ? WUBaseNavigationControllerTransitionDuration : 0.0f
                                 direction:_navigationControllerFlags.isTransitioning
                                completion:endTransitionBlock];
    }else{
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:animated ? WUBaseNavigationControllerTransitionDuration : 0.0f
                                 direction:_navigationControllerFlags.isTransitioning
                                completion:endTransitionBlock];
    }
    
    resetNavigationItemAnimated(animated);
}


#pragma mark Property
- (WUBaseNavigationTransitionStyle)navigationTranstionStyle{
    return WUBaseNavigationTransitionStyleDefault;
}

- (UIViewController *)topViewController{
    return self.viewControllers.lastObject;
}

- (UIViewController *)visibleViewController{
    return self.topViewController;
}

- (NSArray *)viewControllers{
    return self.childViewControllers;
}

- (BOOL)isNavigationBarHidden{
    return _navigationControllerFlags.isNavigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated{
    if(hidden == self.isNavigationBarHidden) return;
    
    _navigationControllerFlags.isNavigationBarHidden = hidden;
    /** if you call setNavigationBarHidden in viewWillAppear:,this animation will be synchronized with navigaiton controller transtion animation.*/
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        if(finished) {
            self.navigationBar.hidden = hidden;
            self.navigationBar.frame  = self.navigationBar.bounds;
        }
    };
    
    if(animated)
        [self transitionNavigationBarHidden:hidden
                                   duration:WUBaseNavigationControllerTransitionDuration
                                  direction:_navigationControllerFlags.isTransitioning
                                 completion:completionBlock];
    else
        completionBlock(YES);
}

#pragma mark navigationBar delegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item{ 
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if(_navigationControllerFlags.isTransitioning) return NO;
    
    if(!_navigationControllerFlags.isAlreadyPoppingNavigationItem){
        _navigationControllerFlags.isAlreadyPoppingNavigationItem = YES;
        [self popViewControllerAnimated:YES];
    }
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item{
    _navigationControllerFlags.isAlreadyPoppingNavigationItem = NO;
}
#pragma mark View Recycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#import "WUStackBaseNavigationController.h"
@implementation WUBaseNavigationController (WUBaseNavigationControllerCreation)
/** Factory Method : generate different product depend on transitionStyle passing in. */
+ (id)navigationWithRootController:(UIViewController *)rootViewController navigationTransitionStyle:(WUBaseNavigationTransitionStyle)transtionStyle{
    WUBaseNavigationController *navigationController = nil;
    switch (transtionStyle) {
        case WUBaseNavigationTransitionStyleStack:
            navigationController = [[WUStackBaseNavigationController alloc] initWithRootViewController:rootViewController];
            break;
        default:
            navigationController = [[WUBaseNavigationController alloc] initWithRootViewController:rootViewController];
            break;
    }
    return navigationController;
}
@end

@implementation UIViewController (WUBaseNavigationController)
- (WUBaseNavigationController *)baseNavigationController{
    WUBaseNavigationController *baseNavigationController = (WUBaseNavigationController *)self.parentViewController;
    if([baseNavigationController isKindOfClass:[WUBaseNavigationController class]]) return baseNavigationController;
    else return nil;
}

- (UINavigationController *)navigationController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController) {
        if([parentViewController isKindOfClass:[UINavigationController class]] || [parentViewController isKindOfClass:[WUBaseNavigationController class]]) break;
        else parentViewController = (UIViewController *)[parentViewController nextResponder];
    }
    return (UINavigationController *)parentViewController;
}

@end
