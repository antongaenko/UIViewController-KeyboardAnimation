//
//  UIViewController+KeyboardAnimation.m
//
//  Created by Anton Gaenko on 16.12.14.
//  Copyright (c) 2014 Anton Gaenko. All rights reserved.
//

#import "UIViewController+KeyboardAnimation.h"
#import <objc/runtime.h>

static void *ANAnimationsBlockAssociationKey = &ANAnimationsBlockAssociationKey;
static void *ANBeforeAnimationsBlockAssociationKey = &ANBeforeAnimationsBlockAssociationKey;
static void *ANAnimationsCompletionBlockAssociationKey = &ANAnimationsCompletionBlockAssociationKey;

@implementation UIViewController (KeyboardAnimation)

#pragma mark public

- (void)an_subscribeKeyboardWithAnimations:(ANAnimationsWithKeyboadrBlock)animations
                                completion:(ANCompletionKeyboardAnimation)completion {
    [self an_subscribeKeyboardWithBeforeAnimations:nil animations:animations completion:completion];
}

- (void)an_subscribeKeyboardWithBeforeAnimations:(ANBeforeAnimationsWithKeyboadrBlock)beforeAnimations
                                      animations:(ANAnimationsWithKeyboadrBlock)animations
                                      completion:(ANCompletionKeyboardAnimation)completion {
    // we shouldn't check for nil because it does nothing with nil
    objc_setAssociatedObject(self, ANBeforeAnimationsBlockAssociationKey, beforeAnimations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, ANAnimationsBlockAssociationKey, animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, ANAnimationsCompletionBlockAssociationKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // subscribe to keyboard animations
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(an_handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(an_handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)an_unsubscribeKeyboard {
    // remove assotiated blocks
    objc_setAssociatedObject(self, ANAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, ANAnimationsCompletionBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // unsubscribe from keyboard animations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark private

// ----------------------------------------------------------------
- (void)an_handleWillShowKeyboardNotification:(NSNotification *)notification
{
    [self an_keyboardWillShowHide:notification isShowing:YES];
}

// ----------------------------------------------------------------
- (void)an_handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self an_keyboardWillShowHide:notification isShowing:NO];
}

- (void)an_keyboardWillShowHide:(NSNotification *)notification isShowing:(BOOL)isShowing
{
    // getting keyboard animation attributes
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // getting passed blocks
    ANAnimationsWithKeyboadrBlock animationsBlock = objc_getAssociatedObject(self, ANAnimationsBlockAssociationKey);
    ANBeforeAnimationsWithKeyboadrBlock beforeAnimationsBlock = objc_getAssociatedObject(self, ANBeforeAnimationsBlockAssociationKey);
    ANCompletionKeyboardAnimation completionBlock = objc_getAssociatedObject(self, ANAnimationsCompletionBlockAssociationKey);
    
    if (beforeAnimationsBlock) beforeAnimationsBlock(keyboardRect, duration, isShowing);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         if (animationsBlock) animationsBlock(keyboardRect, duration, isShowing);
                     }
                     completion:completionBlock];
}

@end
