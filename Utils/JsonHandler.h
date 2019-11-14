//
//  JsonHandler.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/11/14.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonHandler : NSObject
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;                  //将字典转化为json
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonStr;      //将json转化为字典
@end

NS_ASSUME_NONNULL_END
