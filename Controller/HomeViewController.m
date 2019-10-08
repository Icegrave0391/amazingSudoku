//
//  HomeViewController.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/25.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "HomeViewController.h"
#import "Sudoku.h"
@interface HomeViewController ()
@property(nonatomic, strong)Sudoku * sudoku;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)test{
    self.sudoku = [[Sudoku alloc] initWithLevel:1];
    NSLog(@"map : %@", self.sudoku.mapArr);
    NSLog(@"sol : %@", self.sudoku.solArr);
}

@end
