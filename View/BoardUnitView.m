//
//  BoardUnitView.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/8.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "BoardUnitView.h"

@implementation BoardUnitView

- (instancetype)init{
    self = [super init];
    if(self){
        //
    }
    return self;
}

#pragma mark - setter
- (void)setUnitStatus:(UnitStatus)unitStatus{
    _unitStatus = unitStatus;
    if(unitStatus == UnitStatusInitial){                 //initial grids
        
    }
    else if(unitStatus == UnitStatusWrong){              //gird wrong
        
    }
    else if(unitStatus == UnitStatusSatisfied){          //grid satisfied
        
    }
    else{                                                //grid normal
        
    }
}
@end
