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
@property(nonatomic, strong)Sudoku * sudoku;
//arguments properties
@property(nonatomic, assign)NSTimeInterval playTime;
@property(nonatomic, assign)SudokuLevel level;

- (instancetype)initWithSudokuLevel:(SudokuLevel)level;
@end

NS_ASSUME_NONNULL_END
