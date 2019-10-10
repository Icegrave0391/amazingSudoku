//
//  PlayGroundViewController.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "PlayGroundViewController.h"
#import "BoardUnitView.h"
#import <Masonry.h>
#import "MapSolver.h"
#import "NSArray+TwoDArray.h"

@interface PlayGroundViewController ()
@property(nonatomic, strong)NSMutableArray * boardUnitArr;
@property(nonatomic, strong)BoardUnitView * selectedCell;
@property(nonatomic, strong)NSArray <UIImageView *> * inputArr;
@end

@implementation PlayGroundViewController

- (instancetype)initWithSudokuLevel:(SudokuLevel)level{
    self = [super init];
    if(self){
        self.sudoku = [[Sudoku alloc] initWithLevel:level];
//        NSLog(@"%@", self.sudoku.mapArr);
        //init board unit arr
        [self initBoardUnitArr];
        //init input arr
        [self initInputArr];
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //test
//    self.view.backgroundColor = UIColor.whiteColor;
//    NSLog(@"sudokuARR : %@",self.sudoku.mapArr);
//    for(int i = 0; i < 9; i++){
//        for(int j = 0; j < 9; j++){
//            BoardUnitView * view = self.boardUnitArr[i][j];
//            printf("row:%ld col:%ld status:%ld number:%ld\n",(long)view.row, (long)view.column, (long)view.unitStatus, (long)[view.unitNumber integerValue]);
//        }printf("\n");
//    }
    //Set UI
    [self setUpUI];
}

#pragma mark - board unit arr
- (void)initBoardUnitArr{
    self.boardUnitArr = [NSMutableArray array];
    for(int i = 0 ; i < 9 ; i++){
        NSMutableArray * tempArr2D = [NSMutableArray array];
        for (int j = 0; j < 9; j++) {
            NSNumber * number = self.sudoku.mapArr[i][j];
            BoardUnitView * unitView = [[BoardUnitView alloc] init];
            //assign unitview status & number
            if([number integerValue]){
                unitView.unitStatus = UnitStatusInitial;
                unitView.unitNumber = [NSNumber numberWithInteger:[number integerValue]];
                [unitView setInitialImageWithNumber:unitView.unitNumber];
            }
            else{
                unitView.unitStatus = UnitStatusNormal;
                unitView.unitNumber = [NSNumber numberWithInteger:0];
            }
            //assign unitview row & colomn
            unitView.row = i;
            unitView.column = j;
            //assign tap gesture
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClicked:)];
            [unitView addGestureRecognizer:tap];
            //
            [tempArr2D addObject:unitView];
        }
        [self.boardUnitArr addObject:tempArr2D];
    }
}

- (void)initInputArr{
    //9 : clear,  10 : 0,  11 : new
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0; i < 12; i++){
        UIImageView * imgView = [[UIImageView alloc] init];
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputClicked:)];
        [imgView addGestureRecognizer:tap];
        [tempArr addObject:imgView];
    }
    self.inputArr = [NSArray arrayWithArray:tempArr];
}

#pragma mark - controller UI
const float kCellViewWidth = 40.f;
const float kCellViewHeight = 40.f;
const float kCellLeading = 29.f;
const float kCellTop = 227.f;
const float kCell3Spacing = 2.f;

const float kInputCellWidth = 138.f;
const float kInputCellHeight = 53.f;
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
    //navigation
    UIButton * nav = [[UIButton alloc] initWithFrame:CGRectMake(30, 44, 17, 30)];
    [self.view addSubview:nav];
    [nav setImage:[UIImage imageNamed:@"nav"] forState:UIControlStateNormal];
    [nav addTarget:self action:@selector(navReturn) forControlEvents:UIControlEventTouchUpInside];
    //cells
    for(int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++) {
            int col3Num = j / 3;
            int row3Num = i / 3;
            BoardUnitView * unitView = (BoardUnitView * )self.boardUnitArr[i][j];
            [self.view addSubview:unitView];
            [unitView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_left).with.offset(kCellLeading + j * kCellViewWidth + col3Num * kCell3Spacing);
                make.height.width.mas_equalTo(kCellViewWidth);
                make.top.equalTo(self.view.mas_top).with.offset(kCellTop + i * kCellViewHeight + row3Num * kCell3Spacing);
            }];
        }
    }
    //inputs
    for(int i = 0; i < 12; i++){
        UIImageView * imgView = self.inputArr[i];
        [self.view addSubview:imgView];
        if(i < 9){
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"input_%d",i+1]];
        }
        else if(i == 9){
            imgView.image = [UIImage imageNamed:@"input_clear"];
        }
        else if(i == 10){
            imgView.image = [UIImage imageNamed:@"input_0"];
        }
        else{
            imgView.image = [UIImage imageNamed:@"input_new"];
        }
        int rownum = (i+1) / 3;
        if(!((i+1)%3)){
            rownum -= 1;
        }
        int colnum = i % 3;
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(600 + rownum * kInputCellHeight);
            make.left.equalTo(self.view.mas_left).with.offset(colnum * kInputCellWidth);
            make.width.mas_equalTo(kInputCellWidth);
            make.height.mas_equalTo(kInputCellHeight);
        }];
    }
}

- (void)navReturn{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - click
- (void)cellClicked:(UITapGestureRecognizer *)tap{
    BoardUnitView * sender = (BoardUnitView *)tap.view;
    if(sender.unitStatus != UnitStatusInitial){
        if(self.selectedCell){
//            self.selectedCell.unitStatus = self.selectedCell.lastStatus;      //给予上一个状态
//            self.selectedCell.lastStatus = UnitStatusSelected;
            self.selectedCell.isSelected = NO;
            self.selectedCell = nil;
        }
        self.selectedCell = sender;
    }
}

- (void)setSelectedCell:(BoardUnitView *)selectedCell{
    _selectedCell = selectedCell;
    _selectedCell.isSelected = YES;
//    selectedCell.lastStatus = selectedCell.unitStatus;
//    selectedCell.unitStatus = UnitStatusSelected;
}

- (void)inputClicked:(UIGestureRecognizer *)tap{
    UIImageView * imgView = (UIImageView * )tap.view;
    NSInteger index = [self.inputArr indexOfObject:imgView];
    if(index < 9 || index == 10){
        if(self.selectedCell){
            NSInteger intNum = index < 9 ? index+1 : 0;
            self.selectedCell.unitStatus = UnitStatusNormal;
            self.selectedCell.unitNumber = [NSNumber numberWithInteger:intNum];
            [self updateCurrentSudokuWithCell:self.selectedCell];
            
            intArr arr = [NSArray convert2DNSArray:self.sudoku.currentSolArr];
            //rejudge satisfy
            if(self.selectedCell.rowSatisfied){
                [self updateSatisfiedRowWithRow:self.selectedCell.row
                                         AndCol:self.selectedCell.column
                                         intArr:arr];
            }
            if(self.selectedCell.colSatisfied){
                [self updateSatisfiedColWithRow:self.selectedCell.row
                                         AndCol:self.selectedCell.column
                                         intArr:arr];
            }
            if(self.selectedCell.matSatisfied){
//                NSInteger row_start = self.selectedCell.row / 3 * 3;
//                NSInteger col_start = self.selectedCell.column / 3 * 3;
                [self updateSatisfiedMatWithRow:self.selectedCell.row
                                         andCol:self.selectedCell.column
                                         intArr:arr];
            }
            
            //fill cell
            if([self judgeLegitimacyWithCell:self.selectedCell]){
                [self updateOKCellsWithCell:self.selectedCell];
            }
            else{
                self.selectedCell.unitStatus = UnitStatusWrong;
            }
            
            //rejudge wrong
            [self updateRowWrongCellsWithRow:self.selectedCell.row
                                      intArr:arr];
            [self updateColWrongCellsWithCol:self.selectedCell.column
                                      intArr:arr];
            [self updateMatWrongCellsWithStartRow:self.selectedCell.row / 3 * 3
                                      andStartCol:self.selectedCell.column / 3 * 3
                                           intArr:arr];
        }
    }
}

#pragma mark - update
- (void)updateCurrentSudokuWithCell:(BoardUnitView *)unitView{
    NSNumber * number = unitView.unitNumber;
    NSInteger row = unitView.row;
    NSInteger col = unitView.column;
    self.sudoku.currentSolArr[row][col] = number;
}

#pragma mark - judge
- (BOOL)judgeLegitimacyWithCell:(BoardUnitView *)unitView{
    int intNum = [unitView.unitNumber intValue];
    int row = [[NSNumber numberWithInteger:unitView.row] intValue];
    int col = [[NSNumber numberWithInteger:unitView.column] intValue];
    intArr arr = [NSArray convert2DNSArray:self.sudoku.currentSolArr];
    if(judge_with_col(arr, row, col, intNum) && judge_with_row(arr, row, col, intNum) && judge_with_mat(arr, row, col, intNum)){
        return YES;
    }
    return NO;
}

- (void)updateOKCellsWithCell:(BoardUnitView *)unitView{
//    int intNum = [unitView.unitNumber intValue];
    int row = [[NSNumber numberWithInteger:unitView.row] intValue];
    int col = [[NSNumber numberWithInteger:unitView.column] intValue];
    intArr arr = [NSArray convert2DNSArray:self.sudoku.currentSolArr];
    if(ok_with_row(arr, row, col) && [self judgeRowLegitimacyWithCell:unitView]){
        for(int i = 0; i < 9; i++){
            BoardUnitView * unit = (BoardUnitView *)self.boardUnitArr[row][i];
            if(unit.couldModified){
                unit.rowSatisfied = YES;
                unit.unitStatus = UnitStatusSatisfied;
            }
        }
    }
    if(ok_with_col(arr, row, col) && [self judgeColLegitimacyWithCell:unitView]){
        for(int i = 0; i < 9; i++){
            BoardUnitView * unit = (BoardUnitView *)self.boardUnitArr[i][col];
            if(unit.couldModified){
                unit.colSatisfied = YES;
                unit.unitStatus = UnitStatusSatisfied;
            }
        }
    }
    if(ok_with_mat(arr, row, col) && [self judgeMatLegitimacyWithCell:unitView]){
        int row_start = 3 * (row / 3);
        int row_end = row_start + 3;
        int col_start = 3 * (col / 3);
        int col_end = col_start + 3;
        for(int i = row_start; i < row_end; i++){
            for (int j = col_start; j < col_end; j++) {
                BoardUnitView * unit = (BoardUnitView *)self.boardUnitArr[i][j];
                if(unit.couldModified){
                    unit.matSatisfied = YES;
                    unit.unitStatus = UnitStatusSatisfied;
                }
            }
        }
    }
    BOOL notSaf = !ok_with_mat(arr, row, col) && !ok_with_col(arr, row, col) && !ok_with_row(arr, row, col);
    BOOL conflicSaf = (ok_with_mat(arr, row, col) && ![self judgeMatLegitimacyWithCell:unitView]) || (ok_with_col(arr, row, col) && ![self judgeColLegitimacyWithCell:unitView]) || (ok_with_row(arr, row, col) && ![self judgeRowLegitimacyWithCell:unitView]);
    if(notSaf || conflicSaf){
        if(unitView.couldModified){
            unitView.unitStatus = UnitStatusNormal;
        }
    }
}

- (BOOL)judgeRowLegitimacyWithCell:(BoardUnitView *)unitView{
    NSInteger row = unitView.row;
    for(int i = 0; i < 9; i++){
        BoardUnitView * cell = self.boardUnitArr[row][i];
        if(cell.unitStatus == UnitStatusWrong)return NO;
    }
    return YES;
}

- (BOOL)judgeColLegitimacyWithCell:(BoardUnitView *)unitView{
    NSInteger col = unitView.column;
    for(int i = 0; i < 9; i++){
        BoardUnitView * cell = self.boardUnitArr[i][col];
        if(cell.unitStatus == UnitStatusWrong)return NO;
    }
    return YES;
}

- (BOOL)judgeMatLegitimacyWithCell:(BoardUnitView *)unitView{
    int row = [[NSNumber numberWithInteger:unitView.row] intValue];
    int col = [[NSNumber numberWithInteger:unitView.column] intValue];
    int row_start = 3 * (row / 3);
    int row_end = row_start + 3;
    int col_start = 3 * (col / 3);
    int col_end = col_start + 3;
    for(int i = row_start; i < row_end; i++){
        for(int j = col_start; j < col_end; j++){
            BoardUnitView * unit = (BoardUnitView *)self.boardUnitArr[i][j];
            if(unit.unitStatus == UnitStatusWrong)return NO;
        }
    }
    return YES;
}

- (void)updateRowWrongCellsWithRow:(NSInteger)row intArr:(intArr)arr{
    for(int i = 0; i < 9; i++){
        BoardUnitView * unitView = self.boardUnitArr[row][i];
        if(unitView.unitStatus == UnitStatusWrong){
            if([self judgeLegitimacyWithCell:unitView])unitView.unitStatus = UnitStatusNormal;
        }
    }
}

- (void)updateColWrongCellsWithCol:(NSInteger)col intArr:(intArr)arr{
    for(int i = 0; i > 9; i++){
        BoardUnitView * unitView = self.boardUnitArr[i][col];
        if(unitView.unitStatus == UnitStatusWrong){
            if([self judgeLegitimacyWithCell:unitView])unitView.unitStatus = UnitStatusNormal;
        }
    }
}

- (void)updateMatWrongCellsWithStartRow:(NSInteger)row_start andStartCol:(NSInteger)col_start intArr:(intArr)arr{
    int row_end = (int)row_start + 3;
    int col_end = (int)col_start + 3;
    for(int row = (int)row_start; row < row_end; row++){
        for(int col = (int)col_start; col < col_end; col++){
            BoardUnitView * unitView = self.boardUnitArr[row][col];
            if(unitView.unitStatus == UnitStatusWrong){
                if([self judgeLegitimacyWithCell:unitView])unitView.unitStatus = UnitStatusNormal;
            }
        }
    }
    
}

- (void)updateSatisfiedRowWithRow:(NSInteger)row AndCol:(NSInteger)col intArr:(intArr)arr{
    if(!ok_with_row(arr, (int)row, (int)col)){
        for(int i = 0; i < 9; i++){
            BoardUnitView * unitView = self.boardUnitArr[row][i];
            unitView.rowSatisfied = NO;
            unitView.unitStatus = UnitStatusNormal;
        }
    }
}

- (void)updateSatisfiedColWithRow:(NSInteger)row AndCol:(NSInteger)col intArr:(intArr)arr{
    if(!ok_with_col(arr, (int)row, (int)col)){
        for(int i = 0; i < 9; i++){
            BoardUnitView * unitView = self.boardUnitArr[i][col];
            unitView.rowSatisfied = NO;
            unitView.unitStatus = UnitStatusNormal;
        }
    }
}

- (void)updateSatisfiedMatWithRow:(NSInteger)row andCol:(NSInteger)col intArr:(intArr)arr{
    if(!ok_with_mat(arr, (int)row, (int)col)){
        int row_start = (int)row / 3 * 3;
        int col_start = (int)col / 3 * 3;
        int row_end = row_start + 3;
        int col_end = col_start + 3;
        for (int row = row_start; row < row_end; row++) {
            for (int col = col_start; col < col_end; col++) {
                BoardUnitView * unitView = self.boardUnitArr[row][col];
                unitView.matSatisfied = NO;
                unitView.unitStatus = UnitStatusNormal;
            }
        }
    }
}
@end
