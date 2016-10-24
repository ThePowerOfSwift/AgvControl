//
//  MapView.m
//  AgvControl
//
//  Created by 郭龙 on 16/7/19.
//  Copyright © 2016年 690193240@qq.com. All rights reserved.
//

#import "MapView.h"
#import <FMDB.h>
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
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.image = [UIImage imageNamed:@"map.png"];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self initStaionPos];
        
    }
    return self;
}

- (void) initStaionPos
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"agv.db" ofType:nil];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"agv.db" ofType:@"sqlite"];//cannot get the db
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    if (![database open]){
        NSLog(@"database open failed");
        return;
    }
    
    FMResultSet *s = [database executeQuery:@"SELECT * FROM mapPoint"];
    NSLog(@"set num: %d", s.columnCount);
    while ([s next]) {
        //retrieve values for each record
        //NSString *totalCount = [s stringForColumn:@"cargoname"];
        
        NSInteger staNum = [s intForColumn:@"cardPoint"];
        if (staNum <= 50) {
            NSInteger x = [s intForColumn:@"x"];
            NSInteger y = [s intForColumn:@"y"];
            CGPoint staPt = CGPointMake(x, y);
            CGPoint newPt = [self changeCoordToIos:staPt];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
            btn.tag = staNum;
            [btn setTitle:[NSString stringWithFormat:@"%ld", staNum] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor blueColor];
            [self addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(newPt.x );
                make.top.equalTo(self.mas_top).offset(newPt.y );
                make.size.mas_equalTo(CGSizeMake(24, 24));
            }];
            
        }
    }
}

- (void)stationCall :(NSInteger )stationNum {
    UIButton *bt = (UIButton *)[self viewWithTag:stationNum];
    bt.backgroundColor = [UIColor redColor];
    
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(blink:) userInfo:@{@"sta":[NSNumber numberWithInteger:stationNum]} repeats:NO];
    [time fire];
}

-(void)blink:(NSTimer *)timer {
    
    NSDictionary *usr = [timer userInfo];
    NSNumber *staNum = [usr objectForKey:@"sta"];
    NSLog(@"time blink of staNum : %ld",staNum.integerValue);
    
}


- (CGPoint) changeCoordToIos:(CGPoint) inPoint {//to 689, 391
    NSInteger oriWid = 894;
    NSInteger oriHei = 511;
    NSInteger mapWidth = self.bounds.size.width;
    NSInteger mapHeight = self.bounds.size.height;
    
    CGPoint newCg = CGPointMake(inPoint.x * mapWidth / oriWid, inPoint.y * mapHeight / oriHei);
    return newCg;
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
