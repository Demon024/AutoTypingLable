//
//  ViewController.m
//  AutoTypingLable
//
//  Created by lhc on 2018/12/7.
//  Copyright © 2018 HansonLiu. All rights reserved.
//

#import "ViewController.h"
#import "TypingLable.h"

@interface ViewController ()

@property (nonatomic,strong)TypingLable * typingView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.typingView = [[TypingLable alloc] initWithTextArray:@[@"浙江温州 浙江温州 江南皮革厂倒闭了",@"老板黄鹤吃喝嫖赌，欠下了3.5个亿。",@"原价都是三百多、二百多、一百多的钱包",@"通二十块，通通二十块！"]];
    self.typingView.frame = CGRectMake(100, 200, 300, 100);
    self.typingView.textColor = [UIColor blackColor];
    self.typingView.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    
    
    self.typingView.typingSpeed = 0.1;
    self.typingView.cursorBlinkSpeed = 1;
    self.typingView.startTypingDelay = 1;
    self.typingView.delayToStartDeleting = 1;
    self.typingView.deletingSpeed = 0.1;
    self.typingView.loop = YES;
    [self.view addSubview:self.typingView];
}


@end
