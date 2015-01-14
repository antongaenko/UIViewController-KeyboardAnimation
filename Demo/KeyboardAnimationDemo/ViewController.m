//
//  ViewController.m
//  KeyboardAnimationDemo
//
//  Created by Anton Gaenko on 13.01.15.
//  Copyright (c) 2015 Anton Gaenko. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+KeyboardAnimation.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *inputPlaceholder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomSpace;

@end

static const CGFloat kButtonSpaceShowed = 90.0f;
static const CGFloat kButtonSpaceHided = 24.0f;
#define kBackgroundColorShowed [UIColor colorWithRed:0.27f green:0.85f blue:0.46f alpha:1.0f];
#define kBackgroundColorHided [UIColor colorWithRed:0.18f green:0.67f blue:0.84f alpha:1.0f];

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.backgroundColor = kBackgroundColorHided;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self subscribeToKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self an_unsubscribeKeyboard];
}

- (void)subscribeToKeyboard {
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            self.imageView.backgroundColor = kBackgroundColorShowed;
            self.tabBarBottomSpace.constant = CGRectGetHeight(keyboardRect);
            self.buttonBottomSpace.constant = kButtonSpaceShowed;
        } else {
            self.imageView.backgroundColor = kBackgroundColorHided;
            self.tabBarBottomSpace.constant = 0.0f;
            self.buttonBottomSpace.constant = kButtonSpaceHided;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    self.inputPlaceholder.hidden = text.length || range.location > 0;
    
    return YES;
}

@end
