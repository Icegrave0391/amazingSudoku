//
//  DataBaseTool.h
//  FundTest
//
//  Created by 张储祺 on 2018/8/24.
//  Copyright © 2018年 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
@class User ;
@class Organization ;

@interface DataBaseTool : NSObject
//
@property(nonatomic, strong)User * operatedUser ;

+(instancetype)sharedDBTool ;
//记录数据
-(BOOL)recordUser:(User *)user ;
-(BOOL)recordOrganization:(Organization *)org ;

//获取数据
-(User *)getUserFromUserName:(NSString *)userName ;
-(Organization *)getOrganizationFromTeamName:(NSString *)teamName ;
//更新数据
-(BOOL)updateOrganizationInfo:(Organization *)org ;
-(BOOL)updateUserInfo:(User *)user ;
@end
