//
//  MapCreater.c
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#include "MapCreater.h"
int sudokuBoard[9][9] = {0};
int sudokuSolution[9][9] = {0};
int r[9][10] = {0};
int c[9][10] = {0};
int b[9][10] = {0};
int recursionSudoku(int sudoku[9][9], int arow , int aline);
void createSudoku(int sudoku[9][9]){
    //随机生成第一行
    int j ;
    srand((unsigned int)time(NULL)) ;
    for (int i = 0; i < 9 ; i++) {
        sudoku[0][i] = rand() % 9 + 1 ; //random from sudoku[0][0] - sudoku[0][9] with random 1 - 9
        j = 0 ;
        while (j < i) {                 //checkout duplication
            if(sudoku[0][i] == sudoku[0][j]){
                sudoku[0][i] = rand() % 9 + 1 ;
                j = 0 ;
            }else{
                j++ ;
            }
        }
    }
    //generate other rows
    int bool1 = recursionSudoku(sudoku, 1, 0);
    while (!bool1) {
        bool1 = recursionSudoku(sudoku, 1, 0) ;
    }
}
int recursionSudoku(int sudoku[9][9], int arow , int aline){
    if( arow < 9 && aline < 9){
        int saver[10] = {1,1,1,1,1,1,1,1,1,1} ;  //占位
        int step ;
        //check duplication numbers and mark 0
        for (step = 0 ; step < arow; step++) {
            saver[sudoku[step][aline]] = 0 ;     //mark the number that the line used
        }
        for (step = 0 ; step < aline ; step++){
            saver[sudoku[arow][step]] = 0 ;      //mark the number that the row used
        }
        for (step = arow / 3 * 3; step <= arow ; step++) {            //mark 3*3 grids used
            if(step == arow){
                for (int lineStp = aline / 3 * 3 ; lineStp < aline ; lineStp++) {
                    saver[sudoku[step][lineStp]] = 0 ;
                }
            }
            else{
                for (int lineStp = aline / 3 * 3; lineStp < aline / 3 * 3 + 3; lineStp++) {
                    saver[sudoku[step][lineStp]] = 0 ;
                }
            }
        }
        
        int flag = 0 ;
        for (int num = 1 ; num <= 9 && flag == 0 ; num++) {
            if(saver[num]){
                flag = 1 ;
                sudoku[arow][aline] = num ;
                if(aline == 8 && arow != 8){     //recursion the next row until the row9
                    if(recursionSudoku(sudoku, arow + 1 , 0)) return 1 ;
                    else flag = 0 ;
                }
                else if(aline != 8){             //recursion the next line until the line9
                    if(recursionSudoku(sudoku, arow, aline + 1)) return 1 ;
                    else flag = 0 ;
                }
            }
        }
        if(!flag){
            sudoku[arow][aline] = 0 ;
            return 0 ;
        }
    }
    return 1 ;
}


void createStartingBoard(int sudoku[9][9], int board[9][9], int holes){
    //    int i, j, k ;
    srand((unsigned int)time(NULL)) ;
    //copy sudoku
    for (int i = 0 ; i < 9 ; i++) {
        for (int j = 0 ; j < 9 ; j++) {
            board[i][j] = sudoku[i][j] ;
        }
    }
}

//solve
int DFSSovleSudoku(int sudokuBoard[9][9], int r[9][10], int c[9][10], int b[9][10]){
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            if(sudokuBoard[i][j] == 0) {
                int k = i / 3 * 3 + j / 3;
                // 尝试填入1~9
                for(int n = 1; n < 10; n++) {
                    if(!r[i][n] && !c[j][n] && !b[k][n]) {
                        // 尝试填入一个数
                        r[i][n] = 1;
                        c[j][n] = 1;
                        b[k][n] = 1;
                        sudokuBoard[i][j] = n;
                        // 检查是否满足数独正解
                        if(DFSSovleSudoku(sudokuBoard, r, c, b))return 1 ;
                        // 不满足则回溯
                        r[i][n] = 0;
                        c[j][n] = 0;
                        b[k][n] = 0;
                        sudokuBoard[i][j] = 0;
                    }
                }
                // 尝试所有数字都不满足则回溯
                return 0;
            }
        }
        
    }
    
    return 1;
}

int lasVegasCreateSudoku(int n){
//    extern int sudokuBoard[9][9] ;
//    extern int r[9][10] ;
//    extern int c[9][10] ;
//    extern int b[9][10] ;
    int i, j, k, value;
    srand((unsigned int)time(NULL)) ;
    // 初始化
    for(i = 0; i < 9; i++) {
        for(j = 0; j < 9; j++) {
            sudokuBoard[i][j] = 0;
            r[i][j+1] = 0;
            c[i][j+1] = 0;
            b[i][j+1] = 0;
        }
    }
    
    // 随机填入数字
    while(n > 0) {
        i = rand() % 9;
        j = rand() % 9;
        if(sudokuBoard[i][j] == 0) {
            k = i / 3 * 3 + j / 3;
            value = rand() % 9 + 1 ;
            if(!r[i][value] && !c[j][value] && !b[k][value]) {
                sudokuBoard[i][j] = value;
                r[i][value] = 1;
                c[j][value] = 1;
                b[k][value] = 1;
                n--;
            }
        }
    }
    // 检查并且生成一个数组解
    if(DFSSovleSudoku(sudokuBoard, r, c, b))
        return 1;
    else
        return 0;
}

void generateSudokuByDigHoles(int remains){
    extern int sudokuBoard[9][9] ;
    extern int sudokuSolution[9][9] ;
    extern int r[9][10] ;
    extern int c[9][10] ;
    extern int b[9][10] ;
    for (int i = 0 ; i < 9 ; i++) {
        for (int j = 0 ; j < 9 ; j++) {
            sudokuSolution[i][j] = sudokuBoard[i][j] ;
        }
    }
    // 从上到下从左到右的顺序挖洞
    int level = 0 ;
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            if(uniqueSolution(i, j)) {
                int k = i / 3 * 3 + j / 3;
                r[i][sudokuBoard[i][j]] = 0;
                c[j][sudokuBoard[i][j]] = 0;
                b[k][sudokuBoard[i][j]] = 0;
                sudokuBoard[i][j] = 0;
                level++;
                if(81 == level)
                    break;
            }
        }
    }
}

int uniqueSolution(int row, int col){
    extern int sudokuBoard[9][9] ;
    extern int r[9][10] ;
    extern int c[9][10] ;
    extern int b[9][10] ;
    // 挖掉第一个位置一定有唯一解
    if(row == 0 && col == 0)
        return 1;
    
    int k = row / 3 * 3 + col / 3;
    //    boolean[][] trows = new boolean[9][10];
    //    boolean[][] tcols = new boolean[9][10];
    //    boolean[][] tblocks = new boolean[9][10];
    int trows[9][10] = {0};
    int tcols[9][10] = {0};
    int tblocks[9][10] = {0};
    //    int[][] tfield = new int[9][9];
    int tfield[9][9] = {0};
    
    // 临时数组
    for(int i = 0; i < 9; i++) {
        for(int j = 0; j < 9; j++) {
            trows[i][j+1] = r[i][j+1];
            tcols[i][j+1] = c[i][j+1];
            tblocks[i][j+1] = b[i][j+1];
            tfield[i][j] = sudokuBoard[i][j];
        }
    }
    // 假设挖掉这个数字
    trows[row][sudokuBoard[row][col]] = 0;
    tcols[col][sudokuBoard[row][col]] = 0;
    tblocks[k][sudokuBoard[row][col]] = 0;
    
    for(int i = 1; i < 10; i++)
        if(i != sudokuBoard[row][col]) {
            tfield[row][col] = i;
            if(!trows[row][i] && !tcols[col][i] && !tblocks[k][i]) {
                trows[row][i] = 1;
                tcols[col][i] = 1;
                tblocks[k][i] = 1;
                // 更换一个数字之后检查是否还有另一解
                if(DFSSovleSudoku(tfield, trows, tcols, tblocks))
                    return 0;
                trows[row][i] = 0;
                tcols[col][i] = 0;
                tblocks[k][i] = 0;
            }
        }
    // 已尝试所有其他数字发现无解即只有唯一解
    return 1 ;
}

void generateSudoku(SudokuLevel level){
    //create sudoku
//    while(!lasVegasCreateSudoku(11));
    switch (level) {
        case level_1:
//            generateSudokuByDigHoles(36);
            creatSudoku(0, sudokuBoard, sudokuSolution);
            break;
            break;
        case level_2:
//            generateSudokuByDigHoles(28);
            creatSudoku(0, sudokuBoard, sudokuSolution);
            break;
        case level_3:
//            generateSudokuByDigHoles(23);
            creatSudoku(1, sudokuBoard, sudokuSolution);
            break;
        case level_4:
//            generateSudokuByDigHoles(20);
            creatSudoku(2, sudokuBoard, sudokuSolution);
            break;
        case level_5:
//            generateSudokuByDigHoles(17);
            creatSudoku(3, sudokuBoard, sudokuSolution);
            break;
        default:
            break;
    }
}

#pragma mark - version 2
void creatSudoku(int difficuties, int global_sudoku[][9], int global_solution[][9]){
    float rate;
    if (difficuties == 0) rate = 0.7;
    else if(difficuties == 1) rate = 0.6;
    else if(difficuties == 2) rate = 0.5;
    else rate = 0.4;

    int seed[81] ={
1,2,3,4,5,6,7,8,9,
4,5,6,7,8,9,1,2,3,
7,8,9,1,2,3,4,5,6,
2,1,4,3,6,5,8,9,7,
3,6,5,8,9,7,2,1,4,
8,9,7,2,1,4,3,6,5,
5,3,1,6,4,2,9,7,8,
6,4,2,9,7,8,5,3,1,
9,7,8,5,3,1,6,4,2,
    };
    int * sudoku = (int *)malloc(81*sizeof(int));
    for(int i = 0; i < 81; i++) sudoku[i] = seed[i];
    srand((unsigned int)(time(NULL)));
    int times = rand()%100+200;
    while(times--){
        int isRow;
        int choose = rand()%3,operation = rand()%3,c1,c2;
        choose *= 3;
        if(rand()/(double)(RAND_MAX) > 0.5) isRow = 1;
        else isRow = 0;
        if(operation == 0) {c1 = 1;c2 = 2;}
        else if(operation == 1){c1 = 1;c2 = 3;}
        else{c1 = 2;c2 = 3;}
        c1 += choose;
        c2 += choose;
        int change[9];
        if(isRow){
            memcpy(change, sudoku+c1*9, 9*sizeof(int));
            memcpy(sudoku+c1*9, sudoku+c1*9-9, 9*sizeof(int));
            memcpy(sudoku+c1*9-9, change, 9*sizeof(int));
        }
        else{
            for(int i = 0; i < 9; i++){
                change[i] = *(sudoku+i*9+c1-1);
                *(sudoku+i*9+c1-1) = *(sudoku+i*9+c2-1);
                *(sudoku+i*9+c2-1) = change[i];
            }
        }
    }
    for(int i = 0; i < 81; i++){
        if(sudoku[i] == 1) sudoku[i] = 9;
        else if(sudoku[i] == 9) sudoku[i] = 1;
        if(sudoku[i] == 4) sudoku[i] = 2;
        else if(sudoku[i] == 2) sudoku[i] = 4;
    }
    int * solution = (int *) malloc(81*sizeof(int));
    memcpy(solution, sudoku, 81*sizeof(int));
    for(int i = 0; i < 81; i++){
        float r = rand()/(double)(RAND_MAX);
        if(r > rate) {
            sudoku[i] = 0;
        }
    }
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            global_sudoku[i][j] = sudoku[i*9+j];
            global_solution[i][j] = solution[i*9+j];
        }
    }
//    return;
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            printf("%d", global_sudoku[i][j]);
        }printf("\n");
    }
}
