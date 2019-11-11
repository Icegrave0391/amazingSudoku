//
//  UserManager.h
//  Parities
//
//  Created by LAgagggggg on 2018/9/25.
//  Copyright © 2018 Parities. All rights reserved.
//

#import "User.h"
#import "AuctionDetail.h"
#import "Address.h"
#import "IdolDetail.h"
#import "Order.h"

@class Auction;
@class IdolDetail;

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

@property (readonly, nonatomic, strong) User * currentUser;

+ (instancetype)sharedManager;
+ (User *)currentUser;

#pragma mark - login
- (void)showLoginViewControllerAtViewController:(UIViewController *)viewController loginCompleteHandler:(void (^)(BOOL success))block;
- (void)requestLoginVerifyCodeForPhoneNumber:(NSString *)phoneNumber completeHandler:(void (^)(NSInteger timeWait, NSInteger timeLive))block;
- (void)loginWithPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode completeHandler:(void (^)(BOOL success, User * user))block;
- (void)logout;

#pragma mark - user info
- (void)requestCurrentUserInformationCompleteHandler:(void (^)(User * user))block;
- (void)requestAddressArrayForCurrentUserCompleteHandler:(void (^)(NSArray<Address *> * _Nullable addresses))block;
- (void)verifiedUserWithName:(NSString * )name idCardNumber:(NSString *)idNum completeHandler:(void (^)(BOOL verified))block;

#pragma mark - mutation on userinfo
//头像未更改则AvatarImage置nil,注意userInfo应为对currentUser进行copy后再进行修改的User
- (void)agreeOnEULACompleteHandler:(void (^)(BOOL success))block;
- (void)updateUserInfo:(User *)userInfo avatarImage:(nullable UIImage *)image completeHandler:(void (^)(BOOL success,User * user))block;
- (void)updateUserAlipayID:(NSString *)alipayID completeHandler:(void (^)(BOOL success))block;
- (void)addAddress:(Address *)address completeHandler:(void (^)(BOOL success,Address * result))block;
- (void)deleteAddress:(Address *)address completeHandler:(void (^)(BOOL success))block;

#pragma mark - user action
- (void)createOrderWithAuction:(Auction *)auction address:(Address *)address completeHandler:(void (^)(Auction * _Nullable auction, Order * _Nullable order))block;
- (void)gotoAlipayWithOrder:(Order *)order completeHandeler:(void (^)(NSDictionary * resultDict))block;
- (void)bidOnAcution:(Auction *)auction offer:(double)offer isAnonymous:(BOOL)isAnonymous completeHandler:(void (^)(BOOL success))block;
- (void)bidWithoutBargainOnAcution:(Auction *)auction isAnonymous:(BOOL)isAnonymous completeHandler:(void (^)(BOOL success))block;
- (void)bidOnIdol:(IdolDetail *)idol offer:(double)offer completeHandler:(void (^)(BOOL success))block;

#pragma mark - seller center
//- (void)fetchSellerAuctionsOfStatus:(AuctionStatus)status completeHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block;
- (void)fetchSellerAuctionsThatNeedToPayDepositCompleteHandler:(nonnull void (^)(NSDictionary<Auction *, Order * > * _Nullable))block;
- (void)fetchSellerAuctionInCheckCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchSellerAuctionInSellingCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchSellerAuctionAwaitingTransportCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchSellerAuctionAwaitingShareCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchSellerAuctionEndedCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;

- (void)auctionStartShipment:(Auction *)auction expressID:(NSString *)expressID address:(Address *)address completeHandler:(void (^)(BOOL success))block;

#pragma mark - shoppingCart
- (void)fetchAuctionsThatInShoppingCartCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block;

#pragma mark - favouriteItems
- (void)likeAuction:(Auction *)auction completeHandler:(void(^)(BOOL success))block;
- (void)unLikeAuction:(Auction *)auction completeHandler:(void(^)(BOOL success))block;
- (void)fetchAuctionThatUserLikesCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block;

#pragma mark - buyer center
- (void)requestVerifyCodeForCurrentUserCompleteHandler:(void (^)(BOOL success))block;
- (void)deliveredConfirmOfAuction:(Auction *)auction verifyCode:(NSString *)verifyCode completeHandler:(void(^)(BOOL success))block;
//- (void)fetchBuyerAuctionsOfStatus:(AuctionStatus)status completeHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable))block;
- (void)fetchBuyerAuctionInWaitingCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchBuyerAuctionAwaitingCommentCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchBuyerAuctionAwaitingShareCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;
- (void)fetchBuyerAuctionEndedCompleteHandler:(nonnull void (^)(NSArray<AuctionDetail *> * _Nullable auctionDetails))block;

- (void)shareAuction:(Auction *)auction completeHandler:(void(^)(BOOL success))block;
- (void)commentOnAuction:(Auction *)auction level:(NSUInteger)level text:(NSString * )text images:(NSArray<UIImage *> *)images  completeHandler:(void(^)(BOOL success))block;

#pragma mark - my idolWishing
- (void)fetchMyIdolWishingCompleteHandler:(nonnull void (^)(NSArray<IdolDetail *> * _Nullable))block;
- (void)createOrderWithIdol:(IdolDetail *)idol phoneNumber:(NSString *)phoneNumber completeHandler:(void (^)(Order * _Nullable order))block;

@end
NS_ASSUME_NONNULL_END
