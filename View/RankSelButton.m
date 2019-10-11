//
//  RankSelButton.m
//  amazingSudoku
//
//  Created by 张储祺 on 2019/10/11.
//  Copyright © 2019 icegrave0391. All rights reserved.
//

#import "RankSelButton.h"
#import <Masonry.h>
@implementation RankSelButton

- (instancetype)initWithTag:(NSInteger)tag{
    self = [super init];
    if(self){
        self.tag = tag;
        [self setUpUIWithTag:tag];
    }
    return self;
}

- (void)setUpUIWithTag:(NSInteger)tag{
    [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn-%ld",tag]] forState:UIControlStateNormal];
    self.labelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"label-%ld",tag]]];
    self.onView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"label-on-%ld",tag]]];
    [self addSubview:self.labelView];
    [self addSubview:self.onView];
    [self.labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(self.labelView.image.size.width);
        make.height.mas_equalTo(self.labelView.image.size.height);
    }];
    [self.onView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).with.offset(-1);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(-1);
        make.width.mas_equalTo(self.onView.image.size.width);
        make.height.mas_equalTo(self.onView.image.size.height);
    }];
    if(tag==1){
        self.isSelected = YES;
    }else{
        self.isSelected = NO;
    }
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if(isSelected){
        self.imageView.layer.transform = CATransform3DIdentity;
        self.onView.hidden = NO;
    }else{
        self.imageView.layer.transform = CATransform3DMakeScale(0, 0, 0);
        self.onView.hidden = YES;
    }
}
@end
