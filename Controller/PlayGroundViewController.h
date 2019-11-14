//
//  PlayGroundViewController.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sudoku.h"
NS_ASSUME_NONNULL_BEGIN

@interface PlayGroundViewController : UIViewController

//model
@property(nonatomic, strong)Sudoku * sudoku;             //数独模型
//arguments properties
@property(nonatomic, assign)NSTimeInterval playTime;     //游戏时间
@property(nonatomic, assign)SudokuLevel level;           //游戏等级

- (instancetype)initWithSudokuLevel:(SudokuLevel)level andNet:(BOOL)abool;  //根据等级生成游戏
@end

NS_ASSUME_NONNULL_END
