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

@property(nonatomic, strong)NSString * host;       //POST 服务端储存位置
@property(nonatomic, strong)NSString * getHost;    //GET 服务端储存位置

+ (instancetype)sharedManager;                     //生成网络模型的单例
-(int)networkStatusChangeAFN;                      //网络状态监测
- (NSString *)firstGetURL;                         //用于GET初始化的数独
- (NSString *)GetURL;                              //用于GET
- (void)requestWithMethod:(HTTPMethod)method       //封装好的请求处理方法
             WithPath:(NSString *)path
           WithParams:(NSDictionary*)params
     WithSuccessBlock:(requestSuccessBlock)success
      WithFailurBlock:(requestFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
