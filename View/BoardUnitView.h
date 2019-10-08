//
//  BoardUnitView.h
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, UnitStatus) {
    UnitStatusInitial = 0,
    UnitStatusNormal,
    UnitStatusWrong,
    UnitStatusSatisfied
};
@interface BoardUnitView : UIImageView

@property(nonatomic, assign)UnitStatus unitStatus;
@property(nonatomic, assign)BOOL couldModified;
//UI
@property(nonatomic, strong)UIImageView * backView;
@property(nonatomic, strong)UILabel * numLabel;
//model
@property(nonatomic, strong)NSNumber * unitNumber;
- (instancetype)initWithSudokuNumber:(NSNumber *)number;
@end

NS_ASSUME_NONNULL_END
