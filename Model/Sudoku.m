//
//  Sudoku.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/9/24.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "Sudoku.h"
#import <objc/runtime.h>
#import "NSArray+TwoDArray.h"
@implementation Sudoku

- (instancetype)initWithLevel:(SudokuLevel)level{
    extern int sudokuBoard[9][9];
    extern int sudokuSolution[9][9];
    self = [super init];
    if(self){
        generateSudoku(level);   //convert to sudoku[][] & sudokusolution[][]
        self.mapArr = [NSArray convert2DArray:sudokuBoard];
        self.currentSolArr = [NSMutableArray arrayWithArray:self.mapArr];
        self.solArr = [NSArray convert2DArray:sudokuSolution];
    }
    return self;
}
#pragma mark dic -> model
//使用字典生成对象
- (id)initWithDict:(NSDictionary *)aDict{
    self = [super init];
    if(self){
        self.mapArr = [NSArray twoDArrayFromArray:aDict[@"mapArr[][]"]];
        self.currentSolArr =[NSMutableArray arrayWithArray:[NSArray twoDArrayFromArray:aDict[@"currentSolArr[][]"]]];
        self.solArr = [NSArray twoDArrayFromArray:aDict[@"solArr[][]"]];
    }
    return self;
}

- (NSDictionary *)dictionaryFromSudoku{
    return @{
        @"mapArr" : self.mapArr,
        @"currentSolArr" : self.currentSolArr,
        @"solArr" : self.solArr
    };
}

- (void)setAttributesDictionary:(NSDictionary *)aDict{
    //映射字典
    NSDictionary * mapDic = [self attributesMapDictionary];
    //子类没有覆写映射字典，生成默认映射字典
    if(mapDic == nil){
        NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:aDict.count];
        for(NSString * key in aDict){
            [tempDic setObject:key forKey:key];
        }
        mapDic = tempDic;
    }
    //遍历映射字典
    NSEnumerator *keyEnumerator = [mapDic keyEnumerator];
    id attributeName = nil;
    while ((attributeName = [keyEnumerator nextObject])) {
        //获得属性的setter
        SEL setter = [self _getSetterWithAttributeName:attributeName];
        if ([self respondsToSelector:setter]) {
            //获得映射字典的值，也就是传入字典的键
            NSString *aDictKey = [mapDic objectForKey:attributeName];
            //获得传入字典的键对应的值，也就是要赋给属性的值
            id aDictValue = [aDict objectForKey:aDictKey];
            //为属性赋值
            [self performSelectorOnMainThread:setter withObject:aDictValue waitUntilDone:[NSThread isMainThread]];
        }
    }
}

- (NSDictionary *)attributesMapDictionary{
    return @{
        @"mapArr[][]" : @"mapArr[][]",
        @"currentSolArr[][]" : @"currentSolArr[][]",
        @"solArr[][]" : @"solArr[][]"
    };
}

- (SEL)_getSetterWithAttributeName:(NSString *)attributeName
{
    NSString *firstAlpha = [[attributeName substringToIndex:1] uppercaseString];
    NSString *otherAlpha = [attributeName substringFromIndex:1];
    NSString *setterMethodName = [NSString stringWithFormat:@"set%@%@:", firstAlpha, otherAlpha];
    return NSSelectorFromString(setterMethodName);
}

#pragma mark - model -> dic
//- (NSDictionary *)dictionaryFromSudoku{
//    unsigned int count = 0;
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
//    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:count];
//    NSDictionary * keyValueMap = [self attributesMapDictionary];
//    
//    for (int i = 0; i < count; i++) {
//        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        id value = [self valueForKey:key];
//        NSLog(@"key = %@, value = %@, value class = %@, changed Key = %@", key, value, NSStringFromClass([value class]), [keyValueMap objectForKey:key]);
//        key = [keyValueMap objectForKey:key];
//        //only add it to dictionary if it is not nil
//        if (key && value) {
//            [dict setObject:value forKey:key];
//        }
//    }
//    free(properties);
//    return dict;
//}
@end
