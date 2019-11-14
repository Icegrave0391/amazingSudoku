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

@property(nonatomic, assign)UnitStatus unitStatus; //数独单元状态
@property(nonatomic, assign)UnitStatus lastStatus; //save last status (unInitial)

@property(nonatomic, assign)BOOL isSelected;       //是否被选中
@property(nonatomic, assign)BOOL couldModified;    //能否被修改
//status for undo & modify
@property(nonatomic, assign)BOOL colSatisfied;     //是否列满足
@property(nonatomic, assign)BOOL rowSatisfied;     //是否行满足
@property(nonatomic, assign)BOOL matSatisfied;     //是否矩阵满足
//UI
@property(nonatomic, strong)UIImageView * selectMaskView;   //边框视图
//@property(nonatomic, strong)UILabel * numLabel;
//model
@property(nonatomic, strong)NSNumber * unitNumber;         //持有的数字
//from 0 to 8
@property(nonatomic, assign)NSInteger row;                 //所属行
@property(nonatomic, assign)NSInteger column;              //所属列
- (instancetype)init;                                      //初始化
- (void)setInitialImageWithNumber:(NSNumber *)number;      //根据数字生成image
@end

NS_ASSUME_NONNULL_END
