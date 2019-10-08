//
//  MapCreater.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#ifndef MapCreater_h
#define MapCreater_h

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
enum SudokuLevel{
    level_1 = 0,
    level_2,
    level_3,
    level_4,
    level_5
};
typedef enum SudokuLevel SudokuLevel;

#pragma mark - assist func
//void createSudoku(int sudoku[9][9]);
//void createStartingBoard(int sudoku[9][9], int board[9][9], int holes);
int DFSSovleSudoku(int sudokuBoard[9][9], int r[9][10], int c[9][10], int b[9][10]);
// n means write n random nums #let n = 11
int lasVegasCreateSudoku(int n);
void generateSudokuByDigHoles(int remains);
int uniqueSolution(int row, int line);

#pragma mark - create func
void generateSudoku(SudokuLevel level);
#endif /* MapCreater_h */
