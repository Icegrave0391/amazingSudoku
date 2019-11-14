//
//  NSArray+TwoDArray.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/25.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "NSArray+TwoDArray.h"

@implementation NSArray (TwoDArray)

+ (NSArray *)convert2DArray:(int [9][9])arr{
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0 ; i < 9 ; i ++){
        NSMutableArray * tempArr2D = [NSMutableArray array];
        for(int j = 0 ; j < 9 ; j ++){
            NSNumber *obj = [NSNumber numberWithInt:arr[i][j]];
            [tempArr2D addObject:obj];
        }
        [tempArr addObject:tempArr2D];
    }
    return [NSArray arrayWithArray:tempArr];
}

+ (intArr)convert2DNSArray:(NSArray *)array{
    static int tempArr[9][9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            NSNumber * number = array[i][j];
            int intValue = [number intValue];
            tempArr[i][j] = intValue;
        }
    }
    return tempArr;
}

+ (NSArray *)twoDArrayFromArray:(NSArray *)array{
    NSMutableArray * tempArr = [NSMutableArray array];
    for(int i = 0 ; i < 9 ; i ++){
        NSMutableArray * tempArr2D = [NSMutableArray array];
        for(int j = 0 ; j < 9 ; j ++){
            NSNumber *obj = array[i * 9 + j];
            [tempArr2D addObject:obj];
        }
        [tempArr addObject:tempArr2D];
    }
    return [NSArray arrayWithArray:tempArr];
}
@end
