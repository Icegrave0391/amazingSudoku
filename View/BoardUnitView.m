//
//  BoardUnitView.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "BoardUnitView.h"

@implementation BoardUnitView

- (instancetype)initWithSudokuNumber:(NSNumber *)number{
    self = [super init];
    if(self){
        //
        self.unitNumber = number;
    }
    return self;
}

#pragma mark - setter
- (void)setUnitStatus:(UnitStatus)unitStatus{
    _unitStatus = unitStatus;
    if(unitStatus == UnitStatusInitial){                 //initial grids
        self.couldModified = NO;
    }
    else if(unitStatus == UnitStatusWrong){              //gird wrong
        self.couldModified = YES;
    }
    else if(unitStatus == UnitStatusSatisfied){          //grid satisfied
        self.couldModified = YES;
    }
    else{                                                //grid normal
        self.couldModified = YES;
    }
}

-(void)setUnitNumber:(NSNumber *)unitNumber{
    
}

@end
