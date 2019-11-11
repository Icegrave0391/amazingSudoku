//
// Created by LAgagggggg on 2018/12/10.
// Copyright (c) 2018 Parities. All rights reserved.
//

#import "UserManager+LoginControl.h"
#import <Aspects.h>

@implementation UserManager (LoginControl)

- (void)setUpAskForLogin{
    //需要登录才会显示的控制器
    //push的ViewController
    NSSet<NSString *> * pushedViewControllerThatNeedLogin=[[NSSet alloc] initWithArray:@[
            @"SellCenterViewController",
            @"BuyerCenterViewController",
            @"MyIdolWishingWellViewController",
            @"CouponCenterViewController",
            @"ScoreCenterViewController",
            @"ServiceCenterViewController",
            @"FavouriteCenterViewController"
            ]];
    //present的ViewController
    NSSet<NSString *> * presentedViewControllerThatNeedLogin=[[NSSet alloc] initWithArray:@[

             ]];
    [UINavigationController aspect_hookSelector:@selector(pushViewController:animated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, UIViewController *viewController) {
        UIViewController * targetVC=(UIViewController *)info.arguments[0];//坑 必须要retain需要push的VC，不然登录完可能被释放
        BOOL needLogin=!self.currentUser && [pushedViewControllerThatNeedLogin containsObject:NSStringFromClass(targetVC.class)];//未登录登录且push的界面需要登录
        if (needLogin) {
            [self showLoginViewControllerAtViewController:(UIViewController * )info.instance loginCompleteHandler:^(BOOL success){
                if (success) {
                    NSInvocation *invocation = info.originalInvocation;
                    [invocation invoke];
                }
            }];
        } else{
            NSInvocation *invocation = info.originalInvocation;
            [invocation invoke];
        }
    } error:NULL];
    [UIViewController aspect_hookSelector:@selector(presentViewController:animated:completion:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, UIViewController *viewController) {
        UIViewController * targetVC=(UIViewController *)info.arguments[0];//坑 必须要retain需要present的VC，不然登录完可能被释放
        if ([info.instance isMemberOfClass:UINavigationController.class]) {
            NSInvocation *invocation = info.originalInvocation;
            [invocation invoke];
        }
        else{
            BOOL needLogin;
            if ([targetVC isMemberOfClass:UINavigationController.class]) {
                UINavigationController * navigationController=(UINavigationController *)targetVC;
                UIViewController * actualViewController=[navigationController.viewControllers objectAtIndex:0];
                needLogin=!self.currentUser && [presentedViewControllerThatNeedLogin containsObject:NSStringFromClass(actualViewController.class)];
            }else{
                needLogin=!self.currentUser && [presentedViewControllerThatNeedLogin containsObject:NSStringFromClass(viewController.class)];
            }
            if (needLogin) {
                [self showLoginViewControllerAtViewController:(UIViewController * )info.instance loginCompleteHandler:^(BOOL success){
                    if (success) {
                        NSInvocation *invocation = info.originalInvocation;
                        [invocation invoke];
                    }
                }];
            } else{
                NSInvocation *invocation = info.originalInvocation;
                [invocation invoke];
            }
        }
    } error:NULL];
    //特定操作前请求登录
    [self setUpAskForLoginForSpecificAction];
}

- (void)setUpAskForLoginForSpecificAction{
    //控制器数组与SEL数组，一一对应
    NSArray * viewControllerArray=@[
                           @"AuctionDetailViewController",
                           @"AuctionDetailViewController",
                           @"AuctionDetailViewController",
                           @"RootTabBarController",
                           @"RootTabBarController",
                           @"RootTabBarController",
                           @"IdolWishingWellDetailViewController",
                           @"SaleRoomViewController",
                           @"HomeViewController",
                           
                           ];
    NSArray * selectorArray=@[
                              @"offerButtonClicked:",
                              @"noBarginButtonClicked:",
                              @"didClickedLikeButton",
                              @"gotoShoppingCartViewController",
                              @"gotoNotificationViewController",
                              @"gotoSubmitViewController",
                              @"offerButtonClicked",
                              @"didClickedSaleRoomLikeButtonOfCell:",
                              @"didClickedLikeButtonOfCell:",
                              ];
    for (NSInteger i=0; i<viewControllerArray.count; i++) {
        Class class=NSClassFromString(viewControllerArray[i]);
        SEL selector=NSSelectorFromString(selectorArray[i]);
        [class aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
            BOOL needLogin=self.currentUser==nil;
            if (needLogin) {
                [self showLoginViewControllerAtViewController:(UIViewController * )info.instance loginCompleteHandler:^(BOOL success){
                    if (success) {
                        NSInvocation *invocation = info.originalInvocation;
                        [invocation invoke];
                    }
                }];
            } else{
                NSInvocation *invocation = info.originalInvocation;
                [invocation invoke];
            }
        } error:nil];
    }
}

@end
