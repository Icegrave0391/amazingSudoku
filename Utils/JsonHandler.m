//
//  JsonHandler.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/11/14.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "JsonHandler.h"

@implementation JsonHandler
+ (NSString *)dictionaryToJson:(NSDictionary *)dic{
    NSError * err = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonStr{
    if(jsonStr == nil){
        return nil;
    }
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError * err = nil;
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
        NSLog(@"json解析失败 :%@", err);
        return nil;
    }
    return dic;
}
@end
