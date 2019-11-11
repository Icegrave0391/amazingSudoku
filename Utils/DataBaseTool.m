//
//  DataBaseTool.m
//  FundTest
//
//  Created by 张储祺 on 2018/8/24.
//  Copyright © 2018年 1. All rights reserved.
//

#import "DataBaseTool.h"
#import "User.h"
#import "Organization.h"


@interface DataBaseTool()
@property(nonatomic, strong)FMDatabaseQueue * queue ;
@end

static DataBaseTool * tool ;

@implementation DataBaseTool
#pragma mark 单例
+(instancetype)sharedDBTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[DataBaseTool alloc] init] ;
    });
    return tool ;
}

#pragma mark - get queue
//用户队列
-(FMDatabaseQueue *)getQueueWithUserName:(NSString *)userName{
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString * path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",userName]] ;
    NSLog(@"user db path--- %@",path) ;
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path] ;
    return queue ;
}
//team 队列
-(FMDatabaseQueue *)getOrganizationQueue{
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString * path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"organization.sqlite"]] ;
    NSLog(@"team db path--- %@",path) ;
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path] ;
    return queue ;
}
//queue属性 当前user
-(FMDatabaseQueue *)queue{
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString * path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.operatedUser.userName]] ;
    NSLog(@"user db path ---- %@", path) ;
    _queue = [FMDatabaseQueue databaseQueueWithPath:path] ;
    return _queue ;
}

#pragma mark - record date
-(BOOL)recordUser:(User *)user{
    __block BOOL res1, res2;
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        res1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'userInfo' ('userName' TEXT, 'password' TEXT, 'avator' BLOB, 'fund' INTEGER);"] &&
        [db executeUpdate:@"INSERT INTO userInfo(userName, password, avator, fund)VALUES(?,?,?,?)",user.userName, user.password,UIImageJPEGRepresentation(user.avator, 1), [NSNumber numberWithUnsignedInteger:user.fund]] ;
        res2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'organizationArr'('teamName' TEXT);"] ;
    }];
    return res1&&res2 ;
}
-(BOOL)recordOrganization:(Organization *)org{
    __block BOOL res1, res2 ;
    FMDatabaseQueue * queue = [self getOrganizationQueue] ;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:org.memberArr options:NSJSONWritingPrettyPrinted error:nil] ;
        
        res1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'organization'('teamName' TEXT, 'teamFund' INTEGER, 'memberArr' BLOB);"] &&
        [db executeUpdate:@"INSERT INTO organization(teamName,teamFund,memberArr)VALUES(?,?,?)",org.teamName,[NSNumber numberWithUnsignedInteger:org.teamFund],jsonData] ;
    }];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        res2 = [db executeUpdate:@"INSERT INTO 'organizationArr'(teamName)VALUES(?)",org.teamName] ;
    }];
    return res1&&res2 ;
}

#pragma mark - get data
-(User *)getUserFromUserName:(NSString *)userName{
    User * user = [[User alloc] init] ;
    __block FMResultSet * userInfoSet ;
    __block FMResultSet * organizationArrSet ;
    FMDatabaseQueue * queue = [self getQueueWithUserName:userName] ;
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        userInfoSet = [db executeQuery:@"SELECT * FROM 'userInfo'"] ;
        organizationArrSet = [db executeQuery:@"SELECT * FROM 'organizationArr'"] ;
    }];
    if(!userInfoSet){
        return nil ;
    }
    while ([userInfoSet next]) {
        user.userName = [userInfoSet stringForColumn:@"userName"] ;
        user.avator = [UIImage imageWithData:[userInfoSet dataForColumn:@"avator"]] ;
        user.fund = [userInfoSet intForColumn:@"fund"] ;
    }
    while ([organizationArrSet next]) {
        [user.organizationArr addObject:[organizationArrSet stringForColumn:@"teamName"]] ;
    }
    return user ;
}
-(Organization *)getOrganizationFromTeamName:(NSString *)teamName{
    Organization * org = [[Organization alloc] init] ;
    __block FMResultSet * set ;
    FMDatabaseQueue * queue = [self getOrganizationQueue] ;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM organization WHERE teamName = '%@';",teamName]] ;
    }];
    while ([set next]) {
        org.teamName = teamName ;
        org.teamFund = [set intForColumn:@"teamFund"] ;
        NSArray * jsonArr = [NSJSONSerialization JSONObjectWithData:[set dataForColumn:@"memberArr"] options:NSJSONReadingAllowFragments error:nil] ;
        org.memberArr = [NSMutableArray arrayWithArray:jsonArr] ;
    }
    return org ;
}

#pragma mark - update data

@end
