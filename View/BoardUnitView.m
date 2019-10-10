//
//  BoardUnitView.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "BoardUnitView.h"
#import <Masonry.h>
@implementation BoardUnitView

- (instancetype)init{
    self = [super init];
    if(self){
        //
        self.userInteractionEnabled = YES;
        self.unitNumber = [[NSNumber alloc] init];
        self.image = [UIImage imageNamed:@"0-normal"];
        [self setSelectedImage];
    }
    return self;
}

#pragma mark - setter
- (void)setUnitStatus:(UnitStatus)unitStatus{
    if(self.unitStatus){
        self.lastStatus = self.unitStatus;
    }
    _unitStatus = unitStatus;
    if(unitStatus == UnitStatusInitial){                 //initial grids
        self.couldModified = NO;
    }
    if(unitStatus == UnitStatusWrong){              //gird wrong
        self.couldModified = YES;
        NSInteger integer = [self.unitNumber integerValue];
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld-false", integer]];
    }
    if(unitStatus == UnitStatusSatisfied){          //grid satisfied
        self.couldModified = YES;
        NSInteger integer = [self.unitNumber integerValue];
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld-ok", integer]];
    }
    if(unitStatus == UnitStatusNormal){                  //grid normal
        self.couldModified = YES;
        NSInteger integer = [self.unitNumber integerValue];
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld-normal", integer]];
    }
//    if(unitStatus == UnitStatusSelected){
//        self.couldModified = YES;
//        NSInteger integer = [self.unitNumber integerValue];
//        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld-choose", integer]];
//    }
}

- (void)setInitialImageWithNumber:(NSNumber *)number{
    NSInteger integer = [number integerValue];
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld-initial", integer]];
}

-(void)setUnitNumber:(NSNumber *)unitNumber{
    _unitNumber = unitNumber;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if(isSelected){
        self.selectMaskView.hidden = NO;
    }
    else{
        self.selectMaskView.hidden = YES;
    }
}

- (void)setSelectedImage{
    self.selectMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-sel"]];
    [self addSubview:self.selectMaskView];
    [self.selectMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.center);
        make.width.equalTo(self.mas_width);
        make.height.equalTo(self.mas_height);
    }];
    self.selectMaskView.hidden = YES;
}
@end
