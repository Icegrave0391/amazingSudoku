//
//  BannerManager.m
//  Parities
//
//  Created by LAgagggggg on 2018/9/26.
//  Copyright © 2018 Parities. All rights reserved.
//

#import "BannerManager.h"
#import "AuctionsManager+IdolWishingWell.h"

@interface BannerManager ()

@property (strong, nonatomic, readwrite) NSArray<Banner *> * bannersArr;

@end

@implementation BannerManager

+ (instancetype)sharedManager {
    static BannerManager * shared_manager=nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared_manager=[[self alloc] init];
    });
    return shared_manager;
}

- (void)getBannersCompleteHandler:(nonnull void (^)(NSArray<Banner *> * _Nullable))block {
    //尝试在硬盘中获取
    NSString * path=[NSTemporaryDirectory() stringByAppendingString:@"bannerCache.archiver"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {//如果归档文件存在
        self.bannersArr=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        block(self.bannersArr);
    }
    //同时从网络拉取
    [[AuctionsManager sharedManager] fetchCurrentIdolDetailCompleteHandler:^(IdolDetail * detail) {
        UIImage * fakeImg1=[UIImage imageNamed:@"fakeBanner1"];
        UIImage * fakeImg2=[UIImage imageNamed:@"fakeBanner2"];
        Banner * banner1=[[Banner alloc] initWithImage:fakeImg1 title:@"banner1" type:PARBannerTypeSaleRoom];
        Banner * banner2=[[Banner alloc] initWithImage:fakeImg2 title:@"banner2" type:PARBannerTypeSaleRoom];
        if (detail) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:detail.bannerImage] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * image, NSData * data, NSError * error, BOOL finished) {
                Banner * banner=[[Banner alloc] initWithImage:image title:@"idolWishingWellBanner" type:PARBannerTypeIdolWishingWell];
                self.bannersArr=@[banner,banner1,banner2];
                [NSKeyedArchiver archiveRootObject:self.bannersArr toFile:path];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(self.bannersArr);
                });
            }];
        } else{
            self.bannersArr=@[banner1,banner2];
            [NSKeyedArchiver archiveRootObject:self.bannersArr toFile:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.bannersArr);
            });
        }
    }];
//    [[PARNetAPIManager sharedManager
//    ] fakeRequestBannerWithBlock:^(
//            NSArray<id> * _Nonnull result, NSError
//    * _Nonnull error) {
//        for (Banner * banner in result) {
//            [bannersArray addObject:banner];
//        }
//        self.bannersArr=bannersArray.copy;
//        [NSKeyedArchiver archiveRootObject:self.bannersArr toFile:path];
//        block(self.bannersArr);
//    }];
}

@end
