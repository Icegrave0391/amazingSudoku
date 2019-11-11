//
//  BannerManager.h
//  Parities
//
//  Created by LAgagggggg on 2018/9/26.
//  Copyright © 2018 Parities. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Banner.h"

NS_ASSUME_NONNULL_BEGIN

@interface BannerManager : NSObject

@property (strong, nonatomic, readonly) NSArray<Banner *> * bannersArr;

+ (instancetype)sharedManager;

- (void)getBannersCompleteHandler:(nonnull void (^)(NSArray<Banner *> * _Nullable))block;

@end

NS_ASSUME_NONNULL_END
