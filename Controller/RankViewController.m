//
//  RankViewController.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/11.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "RankViewController.h"
#import <Masonry.h>
#import "RankSelButton.h"
@interface RankViewController ()
@property(nonatomic, strong)NSArray <RankSelButton *> * btnArr;
@property(nonatomic, strong)RankSelButton * selectedBtn;
@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    self.selectedBtn = self.btnArr[0];
}

const float kSelBtnWidth = 100.f;
const float kSelBtnHeight = 50.f;
- (void)setUpUI{
    //bg
    UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    bgView.frame = self.view.bounds;
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
    //btn arr bg
    UIImageView * btnBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn-bg"]];
    [self.view addSubview:btnBackGround];
    [btnBackGround mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(17);
        make.right.equalTo(self.view.mas_right).with.offset(-17);
        make.top.equalTo(topLayer.mas_bottom).with.offset(17);
        make.height.mas_equalTo(kSelBtnHeight);
    }];
    //arr
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0; i < 4; i++){
        NSInteger tag = i+1;
        RankSelButton * btn = [[RankSelButton alloc] initWithTag:tag];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).with.offset(7 + i * kSelBtnWidth);
            make.top.equalTo(topLayer.mas_bottom).with.offset(17);
            make.width.mas_equalTo(kSelBtnWidth);
            make.height.mas_equalTo(kSelBtnHeight);
        }];
        [tempArr addObject:btn];
    }
    self.btnArr = [NSArray arrayWithArray:tempArr];
}

- (void)btnClicked:(RankSelButton *)button{
    if(button != self.selectedBtn){
        self.selectedBtn.isSelected = NO;
        self.selectedBtn = button;
        button.isSelected = YES;
    }
}
@end
