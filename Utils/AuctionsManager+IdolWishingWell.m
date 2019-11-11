//
// Created by LAgagggggg on 2018-12-29.
// Copyright (c) 2018 Parities. All rights reserved.
//

#import "AuctionsManager+IdolWishingWell.h"


@implementation AuctionsManager (IdolWishingWell)

- (void)setCurrentIdolDetail:(IdolDetail *)currentIdolDetail {
    objc_setAssociatedObject(self, "currentIdolDetail", currentIdolDetail, OBJC_ASSOCIATION_RETAIN);
}

- (IdolDetail *)currentIdolDetail {
    return objc_getAssociatedObject(self, "currentIdolDetail");
}

- (void)fetchCurrentIdolDetailCompleteHandler:(void (^)(IdolDetail * _Nullable detail))block {
    if (self.currentIdolDetail) {
      block(self.currentIdolDetail);
    }
    NSString * query=@"query{\n"
                     "  idolWishingWell{\n"
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
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query":query
    } Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Fetching Current Idol Detail========\n%@",data);
        if (!data[@"errors"] && data[@"data"][@"idolWishingWell"] && data[@"data"][@"idolWishingWell"]!=[NSNull null]) {
            NSDictionary * dict=data[@"data"][@"idolWishingWell"];
            IdolDetail * detail=[[IdolDetail alloc] initWithDict:dict];
            block(detail);
        } else {
            block(nil);
        }
    }];
}

- (void)fetchIdolFlashbackCompleteHandler:(void (^)(NSArray<IdolFlashback *> * _Nullable flashbacks))block {
    NSString * query=@"query{\n"
                     "  pastIdolWishingWells{\n"
                     "    name\n"
                     "    imageUrl\n"
                     "    flashbackPdfUrl\n"
                     "  }\n"
                     "}";
    [[PARNetAPIManager sharedManager] requestDictionaryWithGraphQlParams:@{
            @"query":query
    } Block:^(NSHTTPURLResponse * header, NSDictionary * data, NSError * nullable) {
        DebugLog(@"========Fetching Flashback========\n%@",data);
        if (!data[@"errors"] && data[@"data"][@"pastIdolWishingWells"]) {
            NSArray * itemsDictArr=data[@"data"][@"pastIdolWishingWells"];
            NSMutableArray<IdolFlashback * > * flashbackArray=[[NSMutableArray alloc] init];
            for (NSDictionary * itemDict in itemsDictArr) {
                IdolFlashback * flashback=[[IdolFlashback alloc] initWithDict:itemDict];
                [flashbackArray addObject:flashback];
            }
            block(flashbackArray.copy);
        } else {
            block(nil);
        }
    }];
}

@end
