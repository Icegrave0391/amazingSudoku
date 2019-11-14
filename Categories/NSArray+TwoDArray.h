//
//  NSArray+TwoDArray.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/25.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (TwoDArray)

typedef int (*intArr)[9];
+ (NSArray *)convert2DArray:(int[_Nullable 9][9])arr;        //将C类型二维数组转化为NSArray
+ (intArr)convert2DNSArray:(NSArray *)array;                 //将NSArray转化为C类型二维数组

@end

NS_ASSUME_NONNULL_END
