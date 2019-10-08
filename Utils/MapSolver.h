//
//  MapSolver.h
//  amazingSudoku
//
//  Created by Triste on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#ifndef MapSolver_h
#define MapSolver_h

#include <stdio.h>

#endif /* MapSolver_h */

int judge_with_col(int array[][9], int i, int j, int num);
int judge_with_row(int array[][9], int i, int j, int num);
int judge_with_mat(int array[][9], int i, int j, int num);
int ok_with_col(int array[][9], int i, int j);
int ok_with_row(int array[][9], int i, int j);
int ok_with_mat(int array[][9], int i, int j);
