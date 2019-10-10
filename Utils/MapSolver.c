//
//  MapSolver.c
//  amazingSudoku
//
//  Created by Triste on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#include "MapSolver.h"


int judge_with_row(int array[][9], int i, int j, int num){
    if(!num)return 1;
    int flag = 1;
    for(int k = 0; k < 9; k++){
        if(k == j) continue;
        if(array[i][k] == num){
            flag = 0;
            break;
        }
    }
    return flag;
}

int judge_with_col(int array[][9], int i, int j, int num){
    if(!num)return 1;
    int flag = 1;
    for(int k = 0; k < 9; k++){
        if(k == i) continue;
        if(array[k][j] == num){
            flag = 0;
            break;
        }
    }
    return flag;
}

int judge_with_mat(int array[][9], int i, int j, int num){
    if(!num)return 1;
    int flag = 1, mat_row = i/3*3, mat_col = j/3*3;
    for(int a = 0; a < 3; a++){
        for(int b = 0; b < 3; b++){
            if(a+mat_row == i && b+mat_col == j) continue;
            if(array[a+mat_row][b+mat_col] == num) flag = 0;
        }
    }
    return flag;
}

int ok_with_row(int array[][9], int i, int j){
    int flag = 1;
    int cnt[10] = {0};
    for(int k = 0; k < 9; k++) cnt[array[i][k]] = 1;
    for(int i = 1; i <= 9; i++){
        if(!cnt[i]) {
            flag = 0;
            break;
        }
    }
    return flag;
}

int ok_with_col(int array[][9], int i, int j){
    int flag = 1;
    int cnt[10] = {0};
    for(int k = 0; k < 9; k++) cnt[array[k][j]] = 1;
    for(int i = 1; i <= 9; i++){
        if(!cnt[i]) {
            flag = 0;
            break;
        }
    }
    return flag;
}

int ok_with_mat(int array[][9], int i, int j){
    int flag = 1, mat_row = i/3*3, mat_col = j/3*3, cnt[10] = {0};
    for(int a = 0; a < 3; a++){
        for(int b = 0; b < 3; b++){
            cnt[array[a+mat_row][b+mat_col]] = 1;
        }
    }
    for(int i = 1; i <= 9; i++){
        if(!cnt[i]) {
            flag = 0;
            break;
        }
    }
    return flag;
}
