//
//  NetworkManager.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/11/14.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "NetworkManager.h"
#define HOSTURL @"http://172.20.10.5:65432/"
//static const int port = 65432;
@interface NetworkManager ()
@property(nonatomic, strong)AFHTTPSessionManager * manager;
@end

@implementation NetworkManager
static NetworkManager * sharedManager = nil;

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[NetworkManager alloc] init];
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 200;
        config.allowsCellularAccess = YES;
        AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:HOSTURL] sessionConfiguration:config];
        manager.requestSerializer.timeoutInterval = 200;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"application/json", @"text/json", @"text/javascript", @"text/html", @"image/png", nil];
        sharedManager.manager = manager;
    });
    return sharedManager;
}

- (instancetype)init{
    if ((self = [super init])) {
    }
    return self;
}

- (NSString *)host{
    if(!_host){
        static NSString * ahost = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            NSURL * sourceURL = [NSURL URLWithString:@"zcq/sudoku.json"
//                                       relativeToURL:sharedManager.manager.baseURL];
            NSURL * sourceURL = self.manager.baseURL;
            ahost = sourceURL.absoluteString;
        });
        _host = ahost;
    }
    return _host;
}


- (NSString *)getHost{
    if(!_getHost){
            static NSString * ahost = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSURL * sourceURL = [NSURL URLWithString:@"write.json"
                                           relativeToURL:sharedManager.manager.baseURL];
//                NSURL * sourceURL = self.manager.baseURL;
                ahost = sourceURL.absoluteString;
            });
            _getHost = ahost;
        }
        return _getHost;
}
- (NSString *)firstGetURL{
    NSURL * sourceURL = [NSURL URLWithString:@"sudoku.json"
    relativeToURL:sharedManager.manager.baseURL];
    return sourceURL.absoluteString;
}

- (NSString *)GetURL{
    NSURL * sourceURL = [NSURL URLWithString:@"write.json"
    relativeToURL:sharedManager.manager.baseURL];
    return sourceURL.absoluteString;
}

-(int)networkStatusChangeAFN
{
    //1.获得一个网络状态监听管理者
   AFNetworkReachabilityManager *manager =  [AFNetworkReachabilityManager sharedManager];
    //2.监听状态的改变(当网络状态改变的时候就会调用该block)
    __block int val;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*
         AFNetworkReachabilityStatusUnknown          = -1,  未知
         AFNetworkReachabilityStatusNotReachable     = 0,   没有网络
         AFNetworkReachabilityStatusReachableViaWWAN = 1,    3G|4G
         AFNetworkReachabilityStatusReachableViaWiFi = 2,   WIFI
         */
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi");
                val = 2;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G");
                val = 1;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                val = 0;
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                val = -1;
                break;
            default:
                val = -1;
                break;
        }
    }];
    //3.手动开启 开始监听
    [manager startMonitoring];
    return val;
}

- (void)requestWithMethod:(HTTPMethod)method
             WithPath:(NSString *)path
           WithParams:(NSDictionary*)params
     WithSuccessBlock:(requestSuccessBlock)success
      WithFailurBlock:(requestFailureBlock)failure
{
switch (method) {
    case GET:{
         [self.manager GET:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
               NSLog(@"JSON: %@", responseObject);
               success(responseObject);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
               NSLog(@"Error: %@", error);
               failure(error);
            }];
            break;
       }
    case POST:{
         [self.manager POST:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
              NSLog(@"JSON: %@", responseObject);
               success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//               [alert show];
                failure(error);
            }];
            break;
        }
    default:
        break;
    }
}
@end
