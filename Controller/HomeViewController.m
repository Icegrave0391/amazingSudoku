//
//  HomeViewController.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/25.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "HomeViewController.h"
#import "Sudoku.h"
#import "PlayGroundViewController.h"
#import <Masonry.h>
@interface HomeViewController ()
@property(nonatomic, strong)Sudoku * sudoku;
@property(nonatomic, strong)NSArray <UIButton *>* btnArr;
@end

@implementation HomeViewController
const float kCellHeight = 121.f;
const float kCellSpacing = 48.f;
const float kCellWidth = 367.f;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    //test
//    self.view.backgroundColor = [UIColor whiteColor];
//    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    btn.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton * btn2 = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
//    btn2.backgroundColor = [UIColor greenColor];
//    [btn2 setTitle:@"controller跳转" forState:UIControlStateNormal];
//    [self.view addSubview:btn2];
//    [btn2 addTarget:self action:@selector(testcontroller) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

//for testing sudoku map and int map
- (void)test{
    self.sudoku = [[Sudoku alloc] initWithLevel:1];
    NSLog(@"map : %@", self.sudoku.mapArr);
    NSLog(@"sol : %@", self.sudoku.solArr);
    intArr testarr = [NSArray convert2DNSArray:self.sudoku.solArr];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            printf("%d ", testarr[i][j]);
        }printf("\n");
    }
}

- (void)testcontroller{
    PlayGroundViewController * playVC = [[PlayGroundViewController alloc] initWithSudokuLevel:level_3];
    [self presentViewController:playVC animated:YES completion:nil];
}

- (void)setUpUI{
    UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [bgView setFrame:self.view.bounds];
    [self.view addSubview:bgView];
    //top layer
    UIImageView * topLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_topLayer"]];
    [self.view addSubview:topLayer];
    [topLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(@85);
        make.width.mas_equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    //top img
    UIImageView * topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_topImg"]];
    [self.view addSubview:topImg];
    [topImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topLayer.mas_bottom).with.offset(-10);
        make.left.equalTo(self.view.mas_left).with.offset(22);
        make.width.mas_equalTo(@41);
        make.height.mas_equalTo(@31);
    }];
    //top label
    UIImageView * topLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_topLabel"]];
    [self.view addSubview:topLabel];
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topImg.mas_centerY);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(@24);
        make.width.mas_equalTo(@99);
    }];
    //button
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0; i < 4; i++){
        UIButton * btn = [[UIButton alloc] init];
        btn.tag = i+1;
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"card%d",i+1]] forState:UIControlStateNormal];
//        btn.imageView.clipsToBounds = YES;
        [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [tempArr addObject:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kCellHeight);
            make.width.mas_equalTo(kCellWidth);
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).with.offset(133 + i * (kCellHeight + kCellSpacing));
        }];
    }
    self.btnArr = [NSArray arrayWithArray:tempArr];
}

- (void)clickedButton:(UIButton *)sender{
    SudokuLevel level;
    switch (sender.tag) {
        case 1:
            level = level_2;
            break;
        case 2:
            level = level_3;
            break;
        case 3:
            level = level_4;
            break;
        case 4:
            level = level_5;
        default:
            level = level_1;
            break;
    }
    PlayGroundViewController * playVC = [[PlayGroundViewController alloc] initWithSudokuLevel:level];
    [self.navigationController pushViewController:playVC animated:YES];
//    [self presentViewController:playVC animated:YES completion:nil];
}
@end
