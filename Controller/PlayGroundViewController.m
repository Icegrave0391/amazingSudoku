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
@end

@implementation PlayGroundViewController

- (instancetype)initWithSudokuLevel:(SudokuLevel)level{
    self = [super init];
    if(self){
        self.sudoku = [[Sudoku alloc] initWithLevel:level];
        
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - board unit arr
- (void)initBoardUnitArr{
    self.boardUnitArr = [NSMutableArray array];
//    for(
}
- (NSMutableArray *)setBoardArrWithCurrentSudoku:(Sudoku *)sudoku{
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0 ; i < 9 ; i++){
        NSMutableArray * tempArr2D = [NSMutableArray array];
        for(int j = 0 ; j < 9 ; j++){
            BoardUnitView * unitView = [[BoardUnitView alloc] initWithSudokuNumber:sudoku.currentSolArr[i][j]];
            [tempArr2D addObject:unitView];
        }
        [tempArr addObject:tempArr2D];
    }
    return tempArr;
}
//- (void)setBoardUnitArr:(NSMutableArray *)boardUnitArr
@end
