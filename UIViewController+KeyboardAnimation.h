//
//  UIViewController+KeyboardAnimation.h
//
//  Created by Anton Gaenko on 16.12.14.
//  Copyright (c) 2014 Anton Gaenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardAnimation)

// if isShowing is NO, then we process keyboard dismissing
typedef void(^ANAnimationsWithKeyboadrBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^ANBeforeAnimationsWithKeyboadrBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^ANCompletionKeyboardAnimation)(BOOL finished);

// animation block will be called inside [UIView animateWithDuration:::::]
- (void)an_subscribeKeyboardWithAnimations:(ANAnimationsWithKeyboadrBlock)animations
                                completion:(ANCompletionKeyboardAnimation)completion;

// animation block will be called inside [UIView animateWithDuration:::::]
- (void)an_subscribeKeyboardWithBeforeAnimations:(ANBeforeAnimationsWithKeyboadrBlock)beforeAnimations
                                      animations:(ANAnimationsWithKeyboadrBlock)animations
                                completion:(ANCompletionKeyboardAnimation)completion;

// cleanup
- (void)an_unsubscribeKeyboard;

@end
