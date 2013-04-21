//
//  SNCDViewController.m
//  StackNavigationControllerDemo
//
//  Created by Jackie CHEUNG on 13-4-22.
//  Copyright (c) 2013年 Jackie. All rights reserved.
//

#import "SNCDViewController.h"

@interface SNCDViewController ()

@end

@implementation SNCDViewController

- (id)init{
    self = [super init];
    if(self){
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navigationController.viewControllers.count%2 animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)loadView{
    [super loadView];
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 50, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"pop" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 100, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"pop to root" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(popToRoot) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 150, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"pop to second view  controller" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(secondViewController) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 200, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"set view controllers" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(setViewControllers) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 250, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"show/hide navigation bar" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(hidenavigationbar) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(button.bounds), 300, CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds))];
    [self.view addSubview:button];
}

- (void)push{
    SNCDViewController *viewController = [[SNCDViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popToRoot{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)secondViewController{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)hidenavigationbar{
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (void)setViewControllers{
    NSArray *viewControllers = @[ [[SNCDViewController alloc] init],[self.navigationController.viewControllers objectAtIndex:2],[[SNCDViewController alloc] init]];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @(self.navigationController.viewControllers.count).stringValue;
    
    //    if(self.navigationController.viewControllers.count % 2 == 0)
    //        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
