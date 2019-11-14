//
//  NetworkManager.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/11/14.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
NS_ASSUME_NONNULL_BEGIN
typedef enum {
GET,
POST,
PUT,
DELETE,
HEAD
} HTTPMethod;
typedef void (^requestSuccessBlock)(NSDictionary *dic);
//请求失败回调block
typedef void (^requestFailureBlock)(NSError *error);
@interface NetworkManager : NSObject

+ (instancetype)sharedManager;
@property(nonatomic, strong)NSString * host;
@end

NS_ASSUME_NONNULL_END
