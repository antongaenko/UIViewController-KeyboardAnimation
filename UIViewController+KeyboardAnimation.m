//
// UIViewController+KeyboardAnimation.m
//
// Copyright (c) 2015 Anton Gaenko
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIViewController+KeyboardAnimation.h"
#import <objc/runtime.h>

static void *ANFrameChangesAnimationsBlockAssociationKey = &ANFrameChangesAnimationsBlockAssociationKey;
static void *ANAnimationsBlockAssociationKey = &ANAnimationsBlockAssociationKey;
static void *ANBeforeAnimationsBlockAssociationKey = &ANBeforeAnimationsBlockAssociationKey;
static void *ANAnimationsCompletionBlockAssociationKey = &ANAnimationsCompletionBlockAssociationKey;

@implementation UIViewController (KeyboardAnimation)

#pragma mark public

- (void)an_subscribeKeyboardFrameChangesWithAnimations:(ANFrameChangesAnimationsWithKeyboardBlock)animations {
    objc_setAssociatedObject(self, ANFrameChangesAnimationsBlockAssociationKey, animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // subscribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(an_handleWillChageFrameKeyboardNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)an_subscribeKeyboardShowHideWithAnimations:(ANAnimationsWithKeyboardBlock)animations {
    [self an_subscribeKeyboardShowHideWithAnimations:animations completion:nil];
}

- (void)an_subscribeKeyboardShowHideWithAnimations:(ANAnimationsWithKeyboardBlock)animations
                                        completion:(ANCompletionKeyboardAnimations)completion {
    [self an_subscribeKeyboardWithAnimations:animations completion:completion];
}

- (void)an_subscribeKeyboardWithAnimations:(ANAnimationsWithKeyboardBlock)animations
                                completion:(ANCompletionKeyboardAnimations)completion {
    [self an_subscribeKeyboardWithBeforeAnimations:nil animations:animations completion:completion];
}

- (void)an_subscribeKeyboardShowHideWithBeforeAnimations:(ANBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                              animations:(ANAnimationsWithKeyboardBlock)animations
                                              completion:(ANCompletionKeyboardAnimations)completion {
    [self an_subscribeKeyboardShowHideWithBeforeAnimations:beforeAnimations
                                                animations:animations
                                                completion:completion];
}

- (void)an_subscribeKeyboardWithBeforeAnimations:(ANBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(ANAnimationsWithKeyboardBlock)animations
                                      completion:(ANCompletionKeyboardAnimations)completion {
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

#pragma mark unsubscribe

- (void)an_unsubscribeKeyboard {
    // remove assotiated blocks
    objc_setAssociatedObject(self, ANBeforeAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, ANAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, ANAnimationsCompletionBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // unsubscribe from keyboard animations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)an_unsubscribeKeyboardShowHide {
    [self an_unsubscribeKeyboard];
}

- (void)an_unsubscribeKeyboardFrameChanges {
    objc_setAssociatedObject(self, ANFrameChangesAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark private

// ----------------------------------------------------------------
- (void)an_handleWillChageFrameKeyboardNotification:(NSNotification *)notification {
    // getting keyboard animation attributes
    CGRect keyboardRect = [self getKeyboardRectFromNotification:notification];
    UIViewAnimationCurve curve = [self getAnimationCurveFromNotification:notification];
    NSTimeInterval duration = [self getDurationFromNotification:notification];
    
    // getting passed block
    ANFrameChangesAnimationsWithKeyboardBlock animationsBlock = objc_getAssociatedObject(self, ANFrameChangesAnimationsBlockAssociationKey);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         if (animationsBlock) animationsBlock(keyboardRect, duration);
                     }
                     completion:nil];
}

// ----------------------------------------------------------------
- (void)an_handleWillShowKeyboardNotification:(NSNotification *)notification {
    [self an_keyboardWillShowHide:notification isShowing:YES];
}

// ----------------------------------------------------------------
- (void)an_handleWillHideKeyboardNotification:(NSNotification *)notification {
    [self an_keyboardWillShowHide:notification isShowing:NO];
}

- (void)an_keyboardWillShowHide:(NSNotification *)notification isShowing:(BOOL)isShowing {
    // getting keyboard animation attributes
    CGRect keyboardRect = [self getKeyboardRectFromNotification:notification];
    UIViewAnimationCurve curve = [self getAnimationCurveFromNotification:notification];
    NSTimeInterval duration = [self getDurationFromNotification:notification];
    
    // getting passed blocks
    ANAnimationsWithKeyboardBlock animationsBlock = objc_getAssociatedObject(self, ANAnimationsBlockAssociationKey);
    ANBeforeAnimationsWithKeyboardBlock beforeAnimationsBlock = objc_getAssociatedObject(self, ANBeforeAnimationsBlockAssociationKey);
    ANCompletionKeyboardAnimations completionBlock = objc_getAssociatedObject(self, ANAnimationsCompletionBlockAssociationKey);
    
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

- (CGRect)getKeyboardRectFromNotification:(NSNotification *)notification {
    return [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (UIViewAnimationCurve)getAnimationCurveFromNotification:(NSNotification *)notification {
    return [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
}

- (NSTimeInterval)getDurationFromNotification:(NSNotification *)notification {
    return [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

@end
