//
// Created by LAgagggggg on 2018-12-29.
// Copyright (c) 2018 Parities. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuctionsManager (IdolWishingWell)

@property (nonatomic, strong) IdolDetail * currentIdolDetail;

- (void)fetchCurrentIdolDetailCompleteHandler:(void (^)(IdolDetail * _Nullable detail))block;
- (void)fetchIdolFlashbackCompleteHandler:(void (^)(NSArray<IdolFlashback *> * _Nullable flashbacks))block;

@end