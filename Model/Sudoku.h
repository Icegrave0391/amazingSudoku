//
//  Sudoku.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+TwoDArray.h"
#import "MapCreater.h"
NS_ASSUME_NONNULL_BEGIN
@interface Sudoku : NSObject
@property(nonatomic, strong)NSArray * mapArr;  //map board
@property(nonatomic, strong)NSMutableArray * currentSolArr;
@property(nonatomic, strong)NSArray * solArr;  //solution

- (instancetype)initWithLevel:(SudokuLevel)level;
@end

NS_ASSUME_NONNULL_END
