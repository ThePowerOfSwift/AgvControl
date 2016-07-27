//
//  MapView.m
//  AgvControl
//
//  Created by 郭龙 on 16/7/19.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import "MapView.h"
#define IMAGEWIDTH 30
#define IMAGEHEIGHT 30

@interface MapView ()
{
    UIImageView *imageView;
}
@end

@implementation MapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"dPad-Left"];
        [self addSubview:imageView];
    }
    return self;
}


- (UIView *)viewWithImage:(CGPoint) position AndText:(NSString *)text
{
    int centX = position.x - IMAGEWIDTH / 2;
    int centY = position.y - IMAGEHEIGHT / 2;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(centX , centY , IMAGEWIDTH, IMAGEHEIGHT)];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:view.bounds];
    imageView2.image = [UIImage imageNamed:@"me"];
    [view addSubview:imageView2];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(centX, centY + IMAGEHEIGHT / 2, IMAGEWIDTH, 20)];
    label.text = text;
    [view addSubview:label];
    
    return view;
}

@end
