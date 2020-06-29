//
//  RCTCustomKeyboardViewController.m
//
//  Created by Leo Natan (Wix) on 12/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import "RCTCustomKeyboardViewController.h"

#if __has_include(<KeyboardTrackingView/ObservingInputAccessoryView.h>)
    #import <KeyboardTrackingView/ObservingInputAccessoryView.h>
    #define ObservingInputAccessoryView_IsAvailable true
#endif

@interface RCTCustomKeyboardViewController ()
@property (nonatomic, assign, getter=isUsingSafeArea) BOOL useSafeArea;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraintToSafeArea;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraintToView;
@end

@implementation RCTCustomKeyboardViewController

- (instancetype)initWithUsingSafeArea:(BOOL)useSafeArea
{
	self = [super init];
	
	if(self)
	{
		self.inputView = [[UIInputView alloc] initWithFrame:CGRectZero inputViewStyle:UIInputViewStyleKeyboard];

        self.heightConstraint = [self.inputView.heightAnchor constraintEqualToConstant:0];
        self.useSafeArea = useSafeArea;
        
#ifdef ObservingInputAccessoryView_IsAvailable
        ObservingInputAccessoryView *activeObservingInputAccessoryView = [ObservingInputAccessoryViewManager sharedInstance].activeObservingInputAccessoryView;
        if (activeObservingInputAccessoryView != nil)
        {
            CGFloat keyboardHeight = activeObservingInputAccessoryView.keyboardHeight;
            if (keyboardHeight > 0)
            {
                self.heightConstraint.constant = keyboardHeight;
                [self setAllowsSelfSizing:YES];
            }
        }
#endif
		//!!!
		self.view.translatesAutoresizingMaskIntoConstraints = NO;
	}
	
	return self;
}

- (void) setAllowsSelfSizing:(BOOL)allowsSelfSizing
{
    if(self.inputView.allowsSelfSizing != allowsSelfSizing)
    {
        self.inputView.allowsSelfSizing = allowsSelfSizing;
        self.heightConstraint.active = allowsSelfSizing;
    }
}

-(void)setRootView:(RCTRootView*)rootView
{
    if(_rootView != nil)
    {
        [_rootView removeFromSuperview];
    }
    
    _rootView = rootView;
    _rootView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputView addSubview:_rootView];
    
    [self updateRootViewConstraints: self.isUsingSafeArea];
    [self.inputView setNeedsLayout];
}

- (void)setNeedSafeAreaUpdate:(BOOL)useSafeArea {
    [self updateBottomConstraint:useSafeArea];
    [self.inputView setNeedsLayout];
}

- (void)updateRootViewConstraints:(BOOL)useSafeArea {
    [_rootView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_rootView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [_rootView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self createBottomConstraintsOnce];
    
    [self updateBottomConstraint:useSafeArea];
}

- (void)createBottomConstraintsOnce {
    if (self.bottomConstraintToSafeArea && self.bottomConstraintToView) {
        return;
    }
    NSLayoutYAxisAnchor *safeAreaAnchor = [self bottomLayoutAnchorUsingSafeArea:YES];
    NSLayoutYAxisAnchor *bottomViewAnchor = [self bottomLayoutAnchorUsingSafeArea:NO];
    
    self.bottomConstraintToSafeArea = [_rootView.bottomAnchor constraintEqualToAnchor:safeAreaAnchor];
    self.bottomConstraintToView = [_rootView.bottomAnchor constraintEqualToAnchor:bottomViewAnchor];
}

- (void)updateBottomConstraint:(BOOL)useSafeArea {
    if (useSafeArea) {
        [self activateSafeAreaConstraint];
    } else {
        [self activateBottomViewConstraint];
    }
}

- (void)activateSafeAreaConstraint {
    [self.bottomConstraintToView setActive:NO];
    [self.bottomConstraintToSafeArea setActive:YES];
}

- (void)activateBottomViewConstraint {
    [self.bottomConstraintToSafeArea setActive:NO];
    [self.bottomConstraintToView setActive:YES];
}

- (NSLayoutYAxisAnchor *)bottomLayoutAnchorUsingSafeArea:(BOOL)useSafeArea {
    NSLayoutYAxisAnchor *bottomAnchor = self.view.bottomAnchor;
    
    if (!useSafeArea) {
        return bottomAnchor;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11.0, *)) {
        bottomAnchor = self.view.safeAreaLayoutGuide.bottomAnchor;
    }
#endif
    return bottomAnchor;
}

@end
