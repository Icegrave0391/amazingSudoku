//
//  Sudoku.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "Sudoku.h"

@implementation Sudoku

- (instancetype)initWithLevel:(SudokuLevel)level{
    extern int sudokuBoard[9][9];
    extern int sudokuSolution[9][9];
    self = [super init];
    if(self){
        generateSudoku(level);   //convert to sudoku[][] & sudokusolution[][]
        self.mapArr = [NSArray convert2DArray:sudokuBoard];
        self.currentSolArr = [NSMutableArray arrayWithArray:self.mapArr];
        self.solArr = [NSArray convert2DArray:sudokuSolution];
    }
    return self;
}
@end
