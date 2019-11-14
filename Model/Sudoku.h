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
@property(nonatomic, strong)NSArray * mapArr;  //map board               //数独棋盘
@property(nonatomic, strong)NSMutableArray * currentSolArr;              //当前解答棋盘
@property(nonatomic, strong)NSArray * solArr;  //solution                //答案棋盘

- (instancetype)initWithLevel:(SudokuLevel)level;                        //生成数独模型

- (id)initWithDict:(NSDictionary *)aDict;                                //从字典中解析模型
- (NSDictionary *)dictionaryFromSudoku;                                  //将模型转化为字典
//- (NSDictionary *)attributesMapDictionary;
@end

NS_ASSUME_NONNULL_END
