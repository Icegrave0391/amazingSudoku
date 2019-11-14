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

@property(nonatomic, strong)NSString * host;
@property(nonatomic, strong)NSString * getHost;
+ (instancetype)sharedManager;
-(int)networkStatusChangeAFN;
- (NSString *)firstGetURL;
- (NSString *)GetURL;
- (void)requestWithMethod:(HTTPMethod)method
             WithPath:(NSString *)path
           WithParams:(NSDictionary*)params
     WithSuccessBlock:(requestSuccessBlock)success
      WithFailurBlock:(requestFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
