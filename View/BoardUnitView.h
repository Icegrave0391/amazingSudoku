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
//    UnitStatusSelected
};
@interface BoardUnitView : UIImageView

@property(nonatomic, assign)UnitStatus unitStatus;
@property(nonatomic, assign)UnitStatus lastStatus; //save last status (unInitial)

@property(nonatomic, assign)BOOL isSelected;
@property(nonatomic, assign)BOOL couldModified;
//UI
@property(nonatomic, strong)UIImageView * selectMaskView;
//@property(nonatomic, strong)UILabel * numLabel;
//model
@property(nonatomic, strong)NSNumber * unitNumber;
//from 0 to 8
@property(nonatomic, assign)NSInteger row;
@property(nonatomic, assign)NSInteger column;
- (instancetype)init;
- (void)setInitialImageWithNumber:(NSNumber *)number;
@end

NS_ASSUME_NONNULL_END
