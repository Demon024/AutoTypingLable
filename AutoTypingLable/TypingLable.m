//
//  TypingLable.m
//  WHBY
//
//  Created by liu on 2018/8/28.
//  Copyright © 2018年 CtrlMedia. All rights reserved.
//

#import "TypingLable.h"

@interface TypingLable()
@property (strong, nonatomic) UILabel *cursorLabel;

@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSArray *textArray;
@property (assign, nonatomic) NSInteger currentCharacterPosition;
@property (assign, nonatomic) NSInteger currentArrayPosition;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic, getter=isDeleting) BOOL deleting;
@property (assign, nonatomic, getter=isAnimatingCursor) BOOL animatingCursor;

@end

@implementation TypingLable

#pragma mark - 初始化
//初始化循环文字
- (instancetype)initWithTextArray:(NSArray *)array {
    self = [super initWithFrame:CGRectMake(0, 0, 300, 100)];
    if (self) {
        [self setTextArray:array];
        [self setDefaultValues];
        
        if (!self.animatingCursor)
        {
            [self addSubview:self.cursorLabel];
            [self blinkCursor:self.cursorLabel];
            self.animatingCursor = YES;
        }
        
        [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.startTypingDelay];
        
    }
    return self;
}


- (void)setDefaultValues {
    if (self.typingSpeed <= 0) {
        self.typingSpeed = 0.5;
    }
    
    if (self.cursorBlinkSpeed <= 0) {
        self.cursorBlinkSpeed = 1;
    }
    
    if (self.startTypingDelay <= 0) {
        self.startTypingDelay = 0.5;
    }
    
    if (self.delayToStartDeleting <= 0) {
        self.delayToStartDeleting = 1;
    }
    
    if (self.deletingSpeed <= 0) {
        self.deletingSpeed = 0.1;
    }
}

- (void)resetTypingAnimation {
    self.text = @"";
    self.currentArrayPosition = 0;
    self.currentCharacterPosition = 0;
    self.currentString = [NSMutableString stringWithCapacity:50];
}
#pragma mark - 核心代码
//开始动画
- (void)startLabelAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.isDeleting?self.deletingSpeed:self.typingSpeed target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    
    //加到runloop中防止scrollow时 timer暂停
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)updateLabel
{
    self.text = [self updateCurrentString];
    [self updateCursorPosition];
    [self handleCursorAlpha];
}

//返回当前已“打印”字符串
- (NSString *)updateCurrentString
{
    NSString *string = self.textArray[self.currentArrayPosition];
    //输入中
    if (!self.isDeleting) {
        if (self.textArray.count > self.currentArrayPosition)  //
        {
            NSRange range = NSMakeRange(self.currentCharacterPosition, 1);
            if (range.location != NSNotFound && range.location + range.length <= string.length) 
            {//打字
                NSString *nextCharacter = [string substringWithRange:range];
                [self.currentString appendString:nextCharacter];
                self.currentCharacterPosition++;
            }
            else
            {//删除
                self.deleting = YES;
                [self stopLabelAnimation];
                [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.delayToStartDeleting];
            }
        }
    } else {
      // 删除中
        if (self.currentCharacterPosition > 0) {
            self.currentCharacterPosition--;
        }
        
        if ([self.currentString length] > 0)
        {
            self.currentString = [[string substringToIndex:self.currentCharacterPosition] mutableCopy];
        }
        else
        {
            //删除完毕下一条
            self.deleting = NO;
            [self stopLabelAnimation];
            [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.delayToStartDeleting];
            
            self.currentArrayPosition++; //下一条
            if (self.textArray.count <= self.currentArrayPosition)
            {
                //循环完毕 再重复
                self.currentArrayPosition = 0;
                if (!self.loop)
                {
                    [self.timer invalidate];
                    [self.cursorLabel.layer removeAllAnimations];
                }
            }
        }
    }
    
    return self.currentString;
}

#pragma mark - 光标相关

- (void)updateCursorPosition
{
    CGRect rect = [self getBoundingRectForLabel];
    CGFloat originX = [self.currentString isEqualToString:@""]?0:rect.size.width;
    
    self.cursorLabel.frame = CGRectMake(originX, self.frame.size.height/2 - rect.size.height/2 - rect.size.height/10, 50, rect.size.height);
}

- (CGRect)getBoundingRectForLabel {
    CGSize constrain = CGSizeMake(self.bounds.size.width, FLT_MAX);
    CGRect rect = [self.text boundingRectWithSize:constrain  options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: self.font} context:nil];
    return rect;
}


- (void)handleCursorAlpha
{
    if (self.deleting && [self.currentString isEqualToString:self.textArray[self.currentArrayPosition]]) {
        return;
    }
    
    [self.cursorLabel.layer removeAllAnimations];
    self.cursorLabel.alpha = 1;
    [self blinkCursor:self.cursorLabel];
}

//输入光标闪烁
- (void)blinkCursor:(UIView *)view {
    if ([view isKindOfClass:[UIView class]]) {
        [UIView animateWithDuration:self.cursorBlinkSpeed delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
            view.alpha = 0.0;
        } completion:NULL];
    }
}

//结束动画
- (void)stopLabelAnimation
{
    [self.timer invalidate];
}

#pragma mark - Lazy Init

- (NSMutableString *)currentString
{
    if (!_currentString)
    {
        _currentString = [NSMutableString stringWithCapacity:50];
    }
    return _currentString;
}

- (UILabel *)cursorLabel {
    if (!_cursorLabel) {
        _cursorLabel = [[UILabel alloc] init];
        _cursorLabel.text = @"|";
        _cursorLabel.font = self.font;
        _cursorLabel.textColor = self.textColor;
        [_cursorLabel sizeToFit];
        [self updateCursorPosition];
    }
    return _cursorLabel;
}


- (void)setTextArray:(NSArray *)array {
    if (!array.count) {
        return;
    }
    for (id string in array) {
        if (![string isKindOfClass:[NSString class]]) {
            return;
        }
    }
    _textArray = array;
    [self resetTypingAnimation];
}




@end
