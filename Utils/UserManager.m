//
//  UserManager.m
//  Parities
//
//  Created by LAgagggggg on 2018/9/25.
//  Copyright © 2018 Parities. All rights reserved.
//

#import "UserManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "PARNetAPIManager.h"
#import "Address.h"
#import "LoginViewController.h"
#import "Auction.h"
#import "UserManager+LoginControl.h"
#import "AuctionsManager+AuctionStatusEnumAdapter.h"
#import "IdolDetail.h"

@interface UserManager ()

@property (readwrite, nonatomic, strong) User * currentUser;

@end

@implementation UserManager

@synthesize currentUser=_currentUser;

static NSString * const currentUserArchiveKey=@"currentUserCache";

+ (instancetype)sharedManager {
    static UserManager * shared_manager=nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared_manager=[[self alloc] init];
        //先尝试获取缓存的用户信息 再从网络更新
        [shared_manager setUpAskForLogin];
        NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
        NSData * currentUserData=[userDefaults objectForKey:currentUserArchiveKey];
        if (currentUserData) {
            shared_manager.currentUser=[NSKeyedUnarchiver unarchiveObjectWithData:currentUserData];
            DebugLog(@"========Loaded CurrentUser Cache========");
        }
        [shared_manager requestCurrentUserInformationCompleteHandler:^(User * user) {
        }];
    });
    return shared_manager;
}

+ (User *)currentUser {
    return [UserManager sharedManager].currentUser;
}

- (void)setCurrentUser:(User *)currentUser {
    _currentUser=currentUser;
    //缓存当前用户信息
    [PARNetAPIClient sharedManager].jsonWebToken=currentUser.id;
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    if (currentUser) {//有用户
        DebugLog(@"========Updated CurrentUser Cache========");
        NSData * currentUserData=[NSKeyedArchiver archivedDataWithRootObject:currentUser];
        [userDefaults setObject:currentUserData forKey:currentUserArchiveKey];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[[PARNetAPIManager sharedManager] aliyunOSSClient] class];//更新aliyunOSS服务
            [[NotificationManager sharedManager] reloadCurrentUserNotificationsCompleteHandler:nil];
        });

    } else {//没有用户
        DebugLog(@"========Deleted CurrentUser Cache========");
        [userDefaults removeObjectForKey:currentUserArchiveKey];
    }
}

#pragma mark - login

- (void)requestLoginVerifyCodeForPhoneNumber:(NSString *)phoneNumber completeHandler:(void (^)(NSInteger timeWait, NSInteger timeLive))block {
    NSDictionary * param=@{@"phoneNumber": phoneNumber};
    [[PARNetAPIManager sharedManager] requestVerifyCodeWithParams:param andBlock:^(NSDictionary * data, NSError * _Nonnull error) {
        DebugLog(@"%s\n%@", __func__, data);
        if (data) {
            NSDictionary * dict=data[@"data"];
            NSInteger timeWait=[dict[@"timeToWait"] integerValue];
            NSInteger timeLive=[dict[@"timeToLive"] integerValue];
            block(timeWait, timeLive);
        } else {
            block(0, 0);
        }
    }];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode completeHandler:(void (^)(BOOL success, User * user))block {
    NSDictionary * params=@{@"phoneNumber": phoneNumber,
            @"verifyCode": verifyCode};
    [[PARNetAPIManager sharedManager] requestLoginWithParams:params andBlock:^(NSDictionary * _Nullable data, NSError * _Nonnull error) {
        DebugLog(@"%s\n%@", __func__, data);
        BOOL success=[data[@"success"] boolValue];
        if (success && data[@"data"]) {
            NSDictionary * dict=[data[@"data"] objectForKey:@"user"];
            User * user=[[User alloc] initWithDict:dict];
            self.currentUser=user;
            //获取详细用户信息
            [self requestCurrentUserInformationCompleteHandler:nil];
            block(success, user);
        } else {
            self.currentUser=nil;
            block(success, nil);
        }
    }];
}

- (void)logout {
    self.currentUser=nil;
    [PARNetAPIClient sharedManager].jsonWebToken=@"";
}

- (void)showLoginViewControllerAtViewController:(UIViewController *)viewController loginCompleteHandler:(void (^)(BOOL success))block {
    if (self.currentUser==nil) {
        LoginViewController * loginVC=[[LoginViewController alloc] init];
        loginVC.loginSuccessBlock=block;
        UINavigationController * loginNav=[[UINavigationController alloc] initWithRootViewController:loginVC];
        [viewController presentViewController:loginNav animated:YES completion:nil];
    }

}

#pragma mark - user info

- (void)requestCurrentUserInformationCompleteHandler:(void (^)(User * user))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    verified\n"
                     "    id\n"
                     "    name\n"
                     "    avatarURL\n"
                     "    phoneNumber\n"
                     "    eula\n"
                     "    type\n"
                     "    gender\n"
                     "    birthday\n"
                     "    points\n"
                     "    temporary__AlipayId\n"
                     "    defaultAddress{\n"
                     "      id\n"
                     "    \tname\n"
                     "    \tphone\n"
                     "    \tprovince\n"
                     "    \tcity\n"
                     "    \tdistrict\n"
                     "    \tdetail\n"
                     "    }"
                     "  }\n"
                     "}";
    NSDictionary * params=@{
            @"query": query
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * _Nonnull header, NSDictionary * _Nullable data, NSError * _Nonnull nullable) {
        DebugLog(@"%s\n%@", __func__, data);
        NSDictionary * userData=[data[@"data"] objectForKey:@"me"];
        if (userData && ![userData isEqual:[NSNull null]]) {
            User * user=[[User alloc] initWithDict:userData];
            self.currentUser=user;
            if (block) {
                block(user);
            }

        } else {
            self.currentUser=nil;
            if (block) {
                block(nil);
            }
        }

    }];
}

- (void)requestAddressArrayForCurrentUserCompleteHandler:(void (^)(NSArray<Address *> * __nullable addresses))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    addresses{\n"
                     "      id\n"
                     "      name\n"
                     "      phone\n"
                     "      province\n"
                     "      city\n"
                     "      district\n"
                     "      detail\n"
                     "      isDefault\n"
                     "    }\n"
                     "  }\n"
                     "}";
    NSDictionary * params=@{
            @"query": query
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * _Nonnull header, NSDictionary * _Nullable data, NSError * _Nonnull nullable) {
        DebugLog(@"%s\n%@", __func__, data);
        NSDictionary * meDict=[data[@"data"] objectForKey:@"me"];
        if (meDict && ![meDict isEqual:[NSNull null]]) {
            NSArray * addressesJson=meDict[@"addresses"];
            NSMutableArray<Address *> * addresses=[[NSMutableArray alloc] init];
            for (NSDictionary * addressJson in addressesJson) {
                Address * address=[[Address alloc] initWithDict:addressJson];
                [addresses addObject:address];
            }
            block(addresses);
        } else {
            block(nil);
        }

    }];
}


- (void)verifiedUserWithName:(NSString *)name idCardNumber:(NSString *)idNum completeHandler:(void (^)(BOOL verified))block {
    NSString * query=@"mutation($name:String!,$idNum:String!){\n"
                     "  matchIdentity(name:$name,id:$idNum)\n"
                     "}";
    NSDictionary * variables=@{
            @"name": name ?: @"",
            @"idNum": idNum ?: @""
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
                    @"query": query,
                    @"variables": variables
            }
            Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
                DebugLog(@"========Identity========\n%@", data);
                BOOL verified=(data[@"data"] && data[@"data"]!=[NSNull null] && data[@"data"][@"matchIdentity"] && [data[@"data"][@"matchIdentity"] boolValue]);
                if (verified) {
                    self.currentUser.verified=YES;
                    block(YES);
                } else {
                    block(NO);
                }
            }];
}


#pragma mark - mutation

- (void)agreeOnEULACompleteHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation{\n"
                     "  updateUser(newUser:{\n"
                     "    eula:true\n"
                     "  }){\n"
                     "    eula\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========EULA========\n%@", data);
        BOOL eulaTrue=(data[@"data"] && data[@"data"][@"updateUser"] && [data[@"data"][@"updateUser"][@"eula"] boolValue]);
        if (eulaTrue) {
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)updateUserInfo:(User *)userInfo avatarImage:(nullable UIImage *)image completeHandler:(void (^)(BOOL success, User * user))block {
    if (image) {//有图片则先将图片上传至OSS
        NSString * objectKey=[NSString stringWithFormat:@"%@AvatarImage%ld.png", userInfo.id, (long) [[NSDate date] timeIntervalSince1970]];
        NSDictionary * callBackVar=@{
                @"x:media": @"mediaTypeAvatar",
                @"x:uploader": userInfo.name
        };
        [[PARNetAPIManager sharedManager] uploadPNGImage:image ObjectKey:objectKey CallBackVar:callBackVar SuccessHandler:^(BOOL success, NSString * URL) {
            if (success) {
                userInfo.avatarURL=URL;
                [self updateUserInfo:userInfo HasAvatar:YES SuccessHandler:^(BOOL success, User * user) {
                    if (success) {
                        block(YES, user);
                    } else {
                        block(NO, nil);
                    }
                }];
            } else {
                block(NO, nil);
            }
        }];
    } else {
        [self updateUserInfo:userInfo HasAvatar:NO SuccessHandler:block];
    }

}


- (void)updateUserInfo:(User *)userInfo HasAvatar:(BOOL)hasAvatar SuccessHandler:(void (^)(BOOL success, User * user))block {
    NSString * query;
    NSDictionary * variables;
    if (hasAvatar) {
        query=@"mutation($name:String!,$avatarURL:URL!,$gender:String!,$birthday:Date!,$alipayID:String){\n"
              "  updateUser(\n"
              "    newUser:{\n"
              "      name:$name\n"
              "      avatarURL:$avatarURL\n"
              "      gender:$gender\n"
              "      birthday:$birthday\n"
              "      temporary__AlipayId:$alipayID\n"
              "    }\n"
              "  ){\n"
              "    verified\n"
              "    id\n"
              "    name\n"
              "    avatarURL\n"
              "    phoneNumber\n"
              "    eula\n"
              "    type\n"
              "    gender\n"
              "    birthday\n"
              "    points\n"
              "    temporary__AlipayId\n"
              "    defaultAddress{\n"
              "      id\n"
              "    \tname\n"
              "    \tphone\n"
              "    \tprovince\n"
              "    \tcity\n"
              "    \tdistrict\n"
              "    \tdetail\n"
              "    }"
              "  }\n"
              "}";
        variables=@{
                @"name": userInfo.name?:@"",
                @"avatarURL": userInfo.avatarURL?:@"",
                @"gender": userInfo.gender?:@"",
                @"birthday": @(userInfo.birthday),
                @"alipayID": userInfo.temporary__AlipayId?:@""
        };
    } else {
        query=@"mutation($name:String!,$gender:String!,$birthday:Date!,$alipayID:String){\n"
              "  updateUser(\n"
              "    newUser:{\n"
              "      name:$name\n"
              "      gender:$gender\n"
              "      birthday:$birthday\n"
              "      temporary__AlipayId:$alipayID\n"
              "    }\n"
              "  ){\n"
              "    verified\n"
              "    id\n"
              "    name\n"
              "    avatarURL\n"
              "    phoneNumber\n"
              "    eula\n"
              "    type\n"
              "    gender\n"
              "    birthday\n"
              "    points\n"
              "    temporary__AlipayId\n"
              "    defaultAddress{\n"
              "      id\n"
              "    \tname\n"
              "    \tphone\n"
              "    \tprovince\n"
              "    \tcity\n"
              "    \tdistrict\n"
              "    \tdetail\n"
              "    }"
              "  }\n"
              "}";
        variables=@{
                @"name": userInfo.name?:@"",
                @"gender": userInfo.gender?:@"",
                @"birthday": @(userInfo.birthday),
                @"alipayID": userInfo.temporary__AlipayId?:@""
        };
    }
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========update user info========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            NSDictionary * userData=data[@"data"][@"updateUser"];
            User * user=[[User alloc] initWithDict:userData];
            self.currentUser=user;
            block(YES, user);
        } else {
            block(NO, nil);
        }
    }];
}

- (void)updateUserAlipayID:(NSString *)alipayID completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($alipayID:String){\n"
                     "  updateUser(\n"
                     "    newUser:{\n"
                     "      temporary__AlipayId:$alipayID\n"
                     "    }\n"
                     "  ){\n"
                     "    verified\n"
                     "    id\n"
                     "    name\n"
                     "    avatarURL\n"
                     "    phoneNumber\n"
                     "    eula\n"
                     "    type\n"
                     "    gender\n"
                     "    birthday\n"
                     "    points\n"
                     "    temporary__AlipayId\n"
                     "    defaultAddress{\n"
                     "      id\n"
                     "    \tname\n"
                     "    \tphone\n"
                     "    \tprovince\n"
                     "    \tcity\n"
                     "    \tdistrict\n"
                     "    \tdetail\n"
                     "    }"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"alipayID": alipayID
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========update alipayID========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            NSDictionary * userData=data[@"data"][@"updateUser"];
            User * user=[[User alloc] initWithDict:userData];
            self.currentUser=user;
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)addAddress:(Address *)address completeHandler:(void (^)(BOOL success, Address * result))block {
    NSString * query=@"mutation($name:String!,$phone:String!,$province:String!\n"
                     "$city:String!,$district:String!,$detail:String!,$isDefault:Boolean!){\n"
                     "  addAddress(\n"
                     "    address:{\n"
                     "      name:$name\n"
                     "      phone:$phone\n"
                     "      province:$province\n"
                     "      city:$city\n"
                     "      district:$district\n"
                     "      detail:$detail\n"
                     "      isDefault:$isDefault\n"
                     "    }\n"
                     "  ){\n"
                     "    id\n"
                     "    name\n"
                     "    phone\n"
                     "    province\n"
                     "    city\n"
                     "    district\n"
                     "    detail\n"
                     "    isDefault"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"name": address.name ?: @"",
            @"phone": address.phone ?: @"",
            @"province": address.regions[0] ?: @"",
            @"city": address.regions[1] ?: @"",
            @"district": address.regions[2] ?: @"",
            @"detail": address.detail ?: @"",
            @"isDefault": @(address.isDefault)
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            NSDictionary * addressDict=(data[@"data"])[@"addAddress"];
            Address * result=[[Address alloc] initWithDict:addressDict];
            block(YES, result);
        } else {
            block(NO, nil);
        }
    }];
}

- (void)deleteAddress:(Address *)address completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($_id:ObjectId!){\n"
                     "  removeAddress(addressId:$_id)\n"
                     "}";
    NSDictionary * variables=@{
            @"_id": address.id ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"%@", data);
        id hasError=data[@"errors"];
        if (!hasError) {
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)createOrderWithAuction:(Auction *)auction address:(Address *)address completeHandler:(void (^)(Auction * _Nullable auction, Order * _Nullable order))block {
    NSString * query=@"mutation ($itemId:ObjectId!,$addressId:ObjectId!){\n"
                     "  buyerCreateOrder(itemId:$itemId,addressId:$addressId){\n"
                     "    orderId\n"
                     "    orderType\n"
                     "    amount\n"
                     "    subject\n"
                     "    timeToExpire\n"
                     "    address{\n"
                     "      id\n"
                     "      name\n"
                     "      phone\n"
                     "      province\n"
                     "      city\n"
                     "      district\n"
                     "      detail\n"
                     "    }\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemId": auction.id ?: @"",
            @"addressId": address.id ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Create Auction Order========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            NSDictionary * dict=data[@"data"][@"buyerCreateOrder"];
            Order * order=[[Order alloc] initWithDict:dict];
            block(auction, order);
        } else {
            block(nil, nil);
        }
    }];
}

- (void)gotoAlipayWithOrder:(Order *)order completeHandeler:(void (^)(NSDictionary * resultDict))block {
    NSString * query=@"mutation($orderID:String!){\n"
                     "  payWithAlipay(orderId:$orderID){\n"
                     "    requestString\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"orderID": order.orderId ?: @""
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query, @"variables": variables} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========goto Alipay========\n%@", data);
        NSDictionary * dict=data[@"data"];
        if ([dict isKindOfClass:NSDictionary.class] && dict[@"payWithAlipay"]) {
            NSString * orderStr=[dict[@"payWithAlipay"] objectForKey:@"requestString"];
            NSString * schemeStr=@"Parities";
            [[AlipaySDK defaultService] payOrder:orderStr fromScheme:schemeStr callback:^(NSDictionary * resultDic) {
                block(resultDic);
            }];
        }

    }];
}

- (void)bidOnAcution:(Auction *)auction offer:(double)offer isAnonymous:(BOOL)isAnonymous completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation ($itemId:ObjectId!,$price:Float!,$isAnonymous:Boolean){\n"
                     "  bid(itemId:$itemId,price:$price,isAnonymous:$isAnonymous){\n"
                     "    id\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemId": auction.id ?: @"",
            @"price": @(offer),
            @"isAnonymous": @(isAnonymous)
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Bid On Action========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)bidWithoutBargainOnAcution:(Auction *)auction isAnonymous:(BOOL)isAnonymous completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation ($itemId:ObjectId!,$isAnonymous:Boolean){\n"
                     "  bidWithoutBargain(itemId:$itemId,isAnonymous:$isAnonymous){\n"
                     "    id\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemId": auction.id ?: @"",
            @"isAnonymous": @(isAnonymous)
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Bid No Bargain Action========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)bidOnIdol:(IdolDetail *)idol offer:(double)offer completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($id:ObjectId!,$price:Float!){\n"
                     "  wishingWellBid(id:$id,price:$price){\n"
                     "    highestBid\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"id": idol.id ?: @"",
            @"price": @(offer),
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"=======Bid On Idol=======\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)createOrderWithIdol:(IdolDetail *)idol phoneNumber:(NSString *)phoneNumber completeHandler:(void (^)(Order * _Nullable order))block {
    NSString * query=@"mutation($id:ObjectId!,$phoneNumber:String!){\n"
                     "  wishingWellBuyerCreateOrder(id:$id,phoneNumber:$phoneNumber){\n"
                     "    orderId\n"
                     "    createTime\n"
                     "    timeToExpire\n"
                     "    amount\n"
                     "    body\n"
                     "    subject\n"
                     "    phoneNumber\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"id": idol.id ?: @"",
            @"phoneNumber": phoneNumber ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Create Idol Order========\n%@", data);
        id hasError=data[@"errors"];
        if (!hasError && data[@"data"]) {
            NSDictionary * dict=data[@"data"][@"wishingWellBuyerCreateOrder"];
            Order * order=[[Order alloc] initWithDict:dict];
            block(order);
        } else {
            block(nil);
        }
    }];
}


- (void)fetchSellerAuctionsThatNeedToPayDepositCompleteHandler:(nonnull void (^)(NSDictionary<Auction *, Order * > * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    items(status:PayingDeposit,limit:999){\n"
                     "\t\t\tid\n"
                     "    \tphotos\n"
                     "    \ttitle\n"
                     "    \tcategory{\n"
                     "    \t  id\n"
                     "    \t  title\n"
                     "    \t  description\n"
                     "    \t}\n"
                     "    \tstartingPrice\n"
                     "    \tnoBarginPrice\n"
                     "    \thighestBid\n"
                     "    \ttimeToExpire\n"
                     "    \tcollectedCount\n"
                     "    \tremainingTime\n"
                     "      createTime\n"
                     "    \tstatus\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "  \t}\n"
                     "    payments{\n"
                     "      orderType\n"
                     "      orderId\n"
                     "      item{id}\n"
                     "      amount\n"
                     "      subject\n"
                     "      paid\n"
                     "      timeToExpire\n"
                     "      createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"%@", data);
        id hasError=data[@"errors"];
        if (!hasError) {
            if (data[@"data"] && data[@"data"][@"me"]) {
                NSDictionary * myInfo=data[@"data"][@"me"];
                NSArray * itemsDictArr=myInfo[@"items"];
                NSArray * ordersDictArr=myInfo[@"payments"];
                NSMutableDictionary<Auction *, Order *> * resultDict=[[NSMutableDictionary alloc] init];
                for (NSDictionary * itemDict in itemsDictArr) {
                    Auction * auction=[[Auction alloc] initWithDict:itemDict];
                    for (NSDictionary * orderDict in ordersDictArr) {
                        if ([orderDict[@"orderType"] isEqualToString:@"Deposit"] && [orderDict[@"item"][@"id"] isEqualToString:auction.id]) {
                            //找到对应的保证金订单并添加进字典
                            Order * order=[[Order alloc] initWithDict:orderDict];
                            [resultDict setObject:order forKey:auction];
                            break;
                        }
                    }
                }
                block(resultDict.copy);
            } else {
                block(nil);
            }
        } else {
            block(nil);
        }
    }];
}

- (void)fetchSellerAuctionsOfStatus:(AuctionStatus)status extraStatus:(AuctionExtraStatus)extraStatus completeHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * extraStatusString;
    if (status==AuctionStatusEnd && extraStatus!=AuctionExtraStatusNULL) {
        extraStatusString=[NSString stringWithFormat:@",extraStatus:%@", [[AuctionsManager sharedManager] convertAuctionExtraStatusToGraphQLEnum:extraStatus]];
    } else {
        extraStatusString=@"";
    }
    NSString * query=[NSString stringWithFormat:@"query($status:AuctionStatus){\n"
                                                "  me{\n"
                                                "    items(status:$status%@){\n"
                                                "      id\n"
                                                "        title\n"
                                                "        highestBid\n"
                                                "        category{\n"
                                                "          id\n"
                                                "          title\n"
                                                "          description\n"
                                                "        }\n"
                                                "        startingPrice\n"
                                                "        noBarginPrice\n"
                                                "        highestBid\n"
                                                "        timeToExpire\n"
                                                "        collectedCount\n"
                                                "        remainingTime\n"
                                                "        status\n"
                                                "        extraStatus\n"
                                                "        description\n"
                                                "        photos\n"
                                                "        videos\n"
                                                "        certPhotos\n"
                                                "        newDegree\n"
                                                "        highestBidUser{\n__typename\n"
                                                "          name\n"
                                                "        }\n"
                                                "        collectedByMe\n"
                                                "        createTime\n"
                                                "        endedReason\n"
                                                "        review{\n"
                                                "        id\n"
                                                "        images\n"
                                                "        textContent\n"
                                                "        descriptionAccuracy\n"
                                                "      }\n"
                                                "    }\n"
                                                "  }\n"
                                                "}", extraStatusString];
    NSDictionary * variables=@{
            @"status": [[AuctionsManager sharedManager] convertAuctionStatusToGraphQLEnum:status]
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching seller items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"items"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchSellerAuctionsOfStatus:(AuctionStatus)status completeHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    [self fetchSellerAuctionsOfStatus:status extraStatus:AuctionExtraStatusNULL completeHandler:^(NSArray<AuctionDetail *> * array) {
        block(array);
    }];
}

- (void)fetchSellerAuctionInCheckCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    items(status_in:[InFirstCheck,InSecondCheck]){\n"
                     "        id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching seller items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"items"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchSellerAuctionInSellingCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    items(status_in:[InAuction,BuyerPaying]){\n"
                     "        id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching seller items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"items"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchSellerAuctionAwaitingTransportCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    items(status_in:[SellerShipping,TransportingToPlatform,\n"
                     "      PlatformShipping,TransportingToBuyer]){\n"
                     "        id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching seller items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"items"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchSellerAuctionAwaitingShareCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    [self fetchSellerAuctionsOfStatus:AuctionStatusEnd extraStatus:AuctionExtraStatusInShare completeHandler:^(NSArray<AuctionDetail *> * array) {
        block(array);
    }];
}

- (void)fetchSellerAuctionEndedCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    items(status:Ended,extraStatus_in:[AllComplete,TransportingToSeller,PlatformShippingBack]){\n"
                     "      id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        extraStatus\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "        endedReason\n"
                     "        review{\n"
                     "        id\n"
                     "        images\n"
                     "        textContent\n"
                     "        descriptionAccuracy\n"
                     "       }\n"
                     "        firstCheckFailReason\n"
                     "        secondCheckFailReason\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching seller's ended items ========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"items"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)auctionStartShipment:(Auction *)auction expressID:(NSString *)expressID address:(Address *)address completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($itemId:ObjectId!,$expressId:ObjectId!,$addressId:ObjectId!){\n"
                     "  sellerShip(itemId:$itemId,expressId:$expressId,addressId:$addressId){\n"
                     "    id\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemId": auction.id ?: @"",
            @"expressId": expressID ?: @"",
            @"addressId": address.id ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Seller Start Shipment========\n%@", data);
        block(!data[@"errors"] && data[@"data"][@"sellerShip"]);
    }];
}


- (void)fetchAuctionsThatInShoppingCartCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    bidItems(status_in:[InAuction,BuyerPaying]){\n"
                     "        id\n"
                     "        title\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching shoppingCart items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"bidItems"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * bidItemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:bidItemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)likeAuction:(Auction *)auction completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($_id:ObjectId!){\n"
                     "  collectItem(itemId:$_id){\n"
                     "    id\n"
                     "    name\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"_id": auction.id ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Like Item========\n%@", data);
        if (block) {
            if (!data[@"errors"] && data[@"data"][@"collectItem"]) {
                block(YES);
            } else {
                block(NO);
            }
        }

    }];
}

- (void)unLikeAuction:(Auction *)auction completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($_id:ObjectId!){\n"
                     "  removeFromCollection(itemId:$_id){\n"
                     "    id\n"
                     "    name\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"_id": auction.id ?: @"",
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"=======unlike Item========\n%@", data);
        if (block) {
            if (!data[@"errors"] && data[@"data"][@"removeFromCollection"]) {
                block(YES);
            } else {
                block(NO);
            }
        }
    }];
}

- (void)fetchAuctionThatUserLikesCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    collectedItems{\n"
                     "      id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        endedReason\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Fetching ShoppingCart Items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"collectedItems"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)requestVerifyCodeForCurrentUserCompleteHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation{\n"
                     "  sendMeSMS\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{@"query": query} Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Send Me Verify Code========\n%@", data);
        block(data && data[@"data"] && data[@"data"]!=[NSNull null] && data[@"data"][@"sendMeSMS"] && [data[@"data"][@"sendMeSMS"] boolValue]);
    }];
}

- (void)deliveredConfirmOfAuction:(Auction *)auction verifyCode:(NSString *)verifyCode completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($itemId:ObjectId!,$verifyCode:String!){\n"
                     "  confirmReceipt(itemId:$itemId,verifyCode:$verifyCode){\n"
                     "    id\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemId": auction.id ?: @"",
            @"verifyCode": verifyCode ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========delivered confirm========\n%@", data);
        block(data && data[@"data"] && data[@"data"]!=[NSNull null] && data[@"data"][@"confirmReceipt"]);
    }];
}

- (void)fetchBuyerAuctionInWaitingCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    bidItems(status_in:[SellerShipping,TransportingToPlatform,\n"
                     "      InSecondCheck,PlatformShipping,TransportingToBuyer]){\n"
                     "        id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching buyer items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"bidItems"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchBuyerAuctionAwaitingCommentCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    [self fetchBuyerAuctionsOfStatus:AuctionStatusEnd extraStatus:AuctionExtraStatusInReview completeHandler:^(NSArray<AuctionDetail *> * auctionDetails) {
        block(auctionDetails);
    }];
}

- (void)fetchBuyerAuctionAwaitingShareCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    [self fetchBuyerAuctionsOfStatus:AuctionStatusEnd extraStatus:AuctionExtraStatusInShare completeHandler:^(NSArray<AuctionDetail *> * auctionDetails) {
        block(auctionDetails);
    }];
}

- (void)fetchBuyerAuctionEndedCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    bidItems(status:Ended,extraStatus_in:[AllComplete,TransportingToSeller,PlatformShippingBack]){\n"
                     "      id\n"
                     "        title\n"
                     "        highestBid\n"
                     "        category{\n"
                     "          id\n"
                     "          title\n"
                     "          description\n"
                     "        }\n"
                     "        startingPrice\n"
                     "        noBarginPrice\n"
                     "        highestBid\n"
                     "        timeToExpire\n"
                     "        collectedCount\n"
                     "        remainingTime\n"
                     "        status\n"
                     "        extraStatus\n"
                     "        description\n"
                     "        photos\n"
                     "        videos\n"
                     "        certPhotos\n"
                     "        newDegree\n"
                     "        highestBidUser{\n__typename\n"
                     "          name\n"
                     "        }\n"
                     "        collectedByMe\n"
                     "        createTime\n"
                     "        endedReason\n"
                     "        review{\n"
                     "        id\n"
                     "        images\n"
                     "        textContent\n"
                     "        descriptionAccuracy\n"
                     "       }\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching buyer items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"bidItems"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchBuyerAuctionsOfStatus:(AuctionStatus)status extraStatus:(AuctionExtraStatus)extraStatus completeHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block {
    NSString * extraStatusString;
    if (status==AuctionStatusEnd && extraStatus!=AuctionExtraStatusNULL) {
        extraStatusString=[NSString stringWithFormat:@",extraStatus:%@", [[AuctionsManager sharedManager] convertAuctionExtraStatusToGraphQLEnum:extraStatus]];
    } else {
        extraStatusString=@"";
    }
    NSString * query=[NSString stringWithFormat:@"query($status:AuctionStatus){\n"
                                                "  me{\n"
                                                "    bidItems(status:$status%@){\n"
                                                "      id\n"
                                                "        title\n"
                                                "        highestBid\n"
                                                "        category{\n"
                                                "          id\n"
                                                "          title\n"
                                                "          description\n"
                                                "        }\n"
                                                "        startingPrice\n"
                                                "        noBarginPrice\n"
                                                "        highestBid\n"
                                                "        timeToExpire\n"
                                                "        collectedCount\n"
                                                "        remainingTime\n"
                                                "        status\n"
                                                "        extraStatus\n"
                                                "        description\n"
                                                "        photos\n"
                                                "        videos\n"
                                                "        certPhotos\n"
                                                "        newDegree\n"
                                                "        highestBidUser{\n__typename\n"
                                                "          name\n"
                                                "        }\n"
                                                "        collectedByMe\n"
                                                "        createTime\n"
                                                "        endedReason\n"
                                                "        review{\n"
                                                "        id\n"
                                                "        images\n"
                                                "        textContent\n"
                                                "        descriptionAccuracy\n"
                                                "      }\n"
                                                "    }\n"
                                                "  }\n"
                                                "}", extraStatusString];
    NSDictionary * variables=@{
            @"status": [[AuctionsManager sharedManager] convertAuctionStatusToGraphQLEnum:status]
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========fetching buyer items========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemsDictArr=data[@"data"][@"me"][@"bidItems"];
            NSMutableArray<AuctionDetail * > * auctionArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                AuctionDetail * detail=[[AuctionDetail alloc] initWithDict:itemDict];
                [auctionArray addObject:detail];
            }
            block(auctionArray.copy);
        } else {
            block(nil);
        }
    }];
}

- (void)shareAuction:(Auction *)auction completeHandler:(void (^)(BOOL success))block {
    NSString * query=@"mutation($itemID:ObjectId!){\n"
                     "  share(itemId:$itemID){\n"
                     "    id\n"
                     "  }\n"
                     "}";
    NSDictionary * variables=@{
            @"itemID": auction.id ?: @""
    };
    NSDictionary * params=@{
            @"query": query,
            @"variables": variables
    };
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Share Item========\n%@", data);
        if (block) {
            if (!data[@"errors"] && data[@"data"][@"share"]) {
                block(YES);
            } else {
                block(NO);
            }
        }

    }];
}

- (void)commentOnAuction:(Auction *)auction level:(NSUInteger)level text:(NSString *)text images:(NSArray<UIImage *> *)images completeHandler:(void (^)(BOOL success))block {
    NSMutableArray<NSString *> * imageURLs=[[NSMutableArray alloc] init];
    __block NSInteger successCount=0;
    dispatch_group_t uploadGroup=dispatch_group_create();
    dispatch_semaphore_t semaphoreForSuccess=dispatch_semaphore_create(1);
    for (NSUInteger i=0; i<images.count; ++i) {
        UIImage * image=images[i];
        NSString * objectKey=[NSString stringWithFormat:@"%@CommentImage_%ld_No%d.png", self.currentUser.id, (long) [[NSDate date] timeIntervalSince1970], i];
        NSDictionary * callBackVar=@{
                @"x:media": @"mediaTypeComment",
                @"x:uploader": self.currentUser.name
        };
        dispatch_group_enter(uploadGroup);
        [[PARNetAPIManager sharedManager] uploadPNGImage:image ObjectKey:objectKey CallBackVar:callBackVar SuccessHandler:^(BOOL success, NSString * URL) {
            if (success) {
                dispatch_semaphore_wait(semaphoreForSuccess, DISPATCH_TIME_FOREVER);
                imageURLs[i]=URL;
                successCount++;
                dispatch_semaphore_signal(semaphoreForSuccess);
            }
            dispatch_group_leave(uploadGroup);
        }];
    }
    NSString * levelString=[NSString stringWithFormat:@"Level%u", level];
    dispatch_group_notify(uploadGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * query=@"mutation($itemID:ObjectId!,$level:Level!,$textContent:String!,$images:[URL!]!){\n"
                         "  review(itemId:$itemID,DA:$level,textContent:$textContent,images:$images){\n"
                         "    id\n"
                         "  }\n"
                         "}";
        NSDictionary * variables=@{
                @"itemID": auction.id ?: @"",
                @"level": levelString,
                @"textContent": text,
                @"images": imageURLs.copy ?: @[]
        };
        NSDictionary * params=@{
                @"query": query,
                @"variables": variables
        };
        [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:params Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
            DebugLog(@"========comment on auction========\n%@", data);
            if (data && !data[@"errors"] && data[@"data"] && data[@"data"]!=[NSNull null]) {
                BOOL success=data[@"data"][@"review"]!=nil;
                block(success);
            } else {
                block(NO);
            }
        }];
    });
}


- (void)fetchMyIdolWishingCompleteHandler:(nonnull void (^)(NSArray<IdolDetail *> * _Nullable))block {
    NSString * query=@"query{\n"
                     "  me{\n"
                     "    bidWishingWells{\n"
                     "    id\n"
                     "    name\n"
                     "    quote\n"
                     "    images\n"
                     "    video\n"
                     "    publicWelfareString\n"
                     "    status\n"
                     "    myValidOp\n"
                     "    remainingTime\n"
                     "    fansChoices\n"
                     "    startingPrice\n"
                     "    highestBid\n"
                     "    dateFrom\n"
                     "    dateTo\n"
                     "    timeToStart\n"
                     "    bannerImage\n"
                     "    myValidOp\n"
                     "    }\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query": query
    }                                                              Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Fetching Current Idol Detail========\n%@", data);
        if (!data[@"errors"] && data[@"data"][@"me"]) {
            NSArray * itemDictArray=data[@"data"][@"me"][@"bidWishingWells"];
            NSMutableArray * idolDetails=[[NSMutableArray alloc] init];
            for (NSDictionary * dictionary in itemDictArray) {
                IdolDetail * detail=[[IdolDetail alloc] initWithDict:dictionary];
                [idolDetails addObject:detail];
            }
            block(idolDetails);
        } else {
            block(nil);
        }
    }];
}


@end
