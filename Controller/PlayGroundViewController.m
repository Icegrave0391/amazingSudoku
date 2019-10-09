//
//  PlayGroundViewController.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "PlayGroundViewController.h"
#import "BoardUnitView.h"

@interface PlayGroundViewController ()
@property(nonatomic, strong)NSMutableArray * boardUnitArr;
@property(nonatomic, strong)BoardUnitView * selectedCell;
@end

@implementation PlayGroundViewController

- (instancetype)initWithSudokuLevel:(SudokuLevel)level{
    self = [super init];
    if(self){
        self.sudoku = [[Sudoku alloc] initWithLevel:level];
        NSLog(@"%@", self.sudoku.mapArr);
        //init board unit arr
        [self initBoardUnitArr];
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //test
    self.view.backgroundColor = UIColor.whiteColor;
    NSLog(@"sudokuARR : %@",self.sudoku.mapArr);
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            BoardUnitView * view = self.boardUnitArr[i][j];
            printf("row:%ld col:%ld status:%ld number:%ld\n",(long)view.row, (long)view.column, (long)view.unitStatus, (long)[view.unitNumber integerValue]);
        }printf("\n");
    }
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

//- (NSMutableArray *)setBoardArrWithCurrentSudoku:(Sudoku *)sudoku{
//    NSMutableArray * tempArr = [NSMutableArray array];
//    for(int i = 0 ; i < 9 ; i++){
//        NSMutableArray * tempArr2D = [NSMutableArray array];
//        for(int j = 0 ; j < 9 ; j++){
////            BoardUnitView * unitView = [[BoardUnitView alloc] initWithSudokuNumber:sudoku.currentSolArr[i][j]];
////            [tempArr2D addObject:unitView];
//        }
//        [tempArr addObject:tempArr2D];
//    }
//    return tempArr;
//}
#pragma mark - controller UI
- (void)setUpUI{
    
}

#pragma mark - click
- (void)cellClicked:(UITapGestureRecognizer *)tap{
    BoardUnitView * sender = (BoardUnitView *)tap.view;
    if(sender.unitStatus != UnitStatusInitial){
        if(self.selectedCell){
            self.selectedCell.unitStatus = self.selectedCell.lastStatus;      //给予上一个状态
            self.selectedCell.lastStatus = UnitStatusSelected;
            self.selectedCell = nil;
        }
        self.selectedCell = sender;
    }
}

- (void)setSelectedCell:(BoardUnitView *)selectedCell{
    _selectedCell = selectedCell;
    selectedCell.lastStatus = selectedCell.unitStatus;
    selectedCell.unitStatus = UnitStatusSelected;
}
@end
