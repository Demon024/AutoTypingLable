//
//  TypingLable.h
//  WHBY
//
//  Created by liu on 2018/8/28.
//  Copyright © 2018年 CtrlMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypingLable : UILabel


@property (assign, nonatomic) CGFloat typingSpeed; //打字速度
@property (assign, nonatomic) CGFloat cursorBlinkSpeed; //光标闪烁速度
@property (assign, nonatomic) CGFloat startTypingDelay;   //开始打字的时间间隔
@property (assign, nonatomic) CGFloat delayToStartDeleting;  //准备删除的时间间隔
@property (assign, nonatomic) CGFloat deletingSpeed;  //删除速度
@property (assign, nonatomic) CGFloat loop;

- (instancetype)initWithTextArray:(NSArray *)array;

- (void)setTextArray:(NSArray *)array;

@end
