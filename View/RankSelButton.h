//
//  RankSelButton.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/11.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RankSelButton : UIButton
@property(nonatomic, strong)UIImageView * labelView;
@property(nonatomic, strong)UIImageView * onView;
@property(nonatomic, assign)BOOL isSelected;

- (instancetype)initWithTag:(NSInteger)tag;
@end

NS_ASSUME_NONNULL_END
