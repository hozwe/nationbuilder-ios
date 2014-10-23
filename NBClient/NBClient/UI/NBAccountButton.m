//
//  NBAccountButton.m
//  NBClient
//
//  Created by Peng Wang on 10/7/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import "NBAccountButton.h"

#import "QuartzCore/QuartzCore.h"

#import "FoundationAdditions.h"
#import "NBAccountsViewDefines.h"
#import "NBDefines.h"

static NSString *HiddenKeyPath = @"hidden";

static void *observationContext = &observationContext;

@interface NBAccountButton ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *avatarImageView;

@property (nonatomic) NBAccountButtonType actualButtonType;

// For avatar hiding.
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarImageWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarImageMarginRight;
@property (nonatomic) CGFloat originalAvatarImageWidth;
@property (nonatomic) CGFloat originalAvatarImageMarginRight;

// For name hiding.
@property (nonatomic) CGFloat originalNameLabelWidth;

- (void)setUpSubviews;
- (void)tearDownSubviews;
- (void)updateSubviews;

- (void)updateNameLabel;
- (void)updateButtonType;

@end

@implementation NBAccountButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}
- (void)dealloc
{
    [self tearDownSubviews];
}

- (void)setUp
{
    self.buttonType = NBAccountButtonTypeDefault;
    self.shouldUseCircleAvatarFrame = NO;
    self.dataSource = nil;
    [self setUpSubviews];
    [self updateSubviews];
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    [UIView animateWithDuration:self.highlightAnimationDuration.floatValue delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                     animations:^{ self.alpha = highlighted ? self.dimmedAlpha.floatValue : 1.0; }
                     completion:nil];
}

#pragma mark - UIView

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self updateSubviews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &observationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if ([keyPath isEqual:HiddenKeyPath]) {
        if (object == self.avatarImageView) {
            // Toggle avatar hiding.
            self.avatarImageWidth.constant = self.avatarImageView.isHidden ? 0.0f : self.originalAvatarImageWidth;
            self.avatarImageMarginRight.constant = self.avatarImageView.isHidden ? 0.0f : self.originalAvatarImageMarginRight;
            [self setNeedsUpdateConstraints];
        } else if (object == self.nameLabel) {
            CGRect frame = self.nameLabel.frame;
            if (self.nameLabel.isHidden) {
                self.originalNameLabelWidth = frame.size.width;
                frame.size.width = 0.0f;
            } else if (self.originalNameLabelWidth) {
                frame.size.width = self.originalNameLabelWidth;
            }
            self.nameLabel.frame = frame;
        }
    }
}

#pragma mark - Public

#pragma mark Accessors

- (void)setDataSource:(id<NBAccountViewDataSource>)dataSource
{
    _dataSource = dataSource;
    // Did.
    if (dataSource) {
        self.avatarImageView.image = [UIImage imageWithData:dataSource.avatarImageData];
    }
    [self updateButtonType];
    [self updateSubviews];
}

- (void)setButtonType:(NBAccountButtonType)buttonType
{
    // Guard.
    if (buttonType == _buttonType) { return; }
    // Set.
    _buttonType = buttonType;
    // Did.
    [self updateButtonType];
}

- (void)setShouldUseCircleAvatarFrame:(BOOL)shouldUseCircleAvatarFrame
{
    // Guard.
    if (shouldUseCircleAvatarFrame == _shouldUseCircleAvatarFrame) { return; }
    // Set.
    _shouldUseCircleAvatarFrame = shouldUseCircleAvatarFrame;
    // Did.
    self.avatarImageView.layer.cornerRadius = (shouldUseCircleAvatarFrame
                                               ? self.avatarImageView.frame.size.width / 2.0f
                                               : self.cornerRadius.floatValue);
}

- (void)setContextHasMultipleActiveAccounts:(BOOL)contextHasMultipleActiveAccounts
{
    // Guard.
    if (contextHasMultipleActiveAccounts == _contextHasMultipleActiveAccounts) { return; }
    // Set.
    _contextHasMultipleActiveAccounts = contextHasMultipleActiveAccounts;
    // Did.
    [self updateButtonType];
}

#pragma mark - Private

- (void)setUpSubviews
{
    self.avatarImageView.layer.borderWidth = 1.0f;
    // Set up avatar hiding.
    [self.avatarImageView addObserver:self forKeyPath:HiddenKeyPath options:0 context:&observationContext];
    self.originalAvatarImageWidth = self.avatarImageWidth.constant;
    self.originalAvatarImageMarginRight = self.avatarImageMarginRight.constant;
    // Set up name hiding.
    [self.nameLabel addObserver:self forKeyPath:HiddenKeyPath options:0 context:&observationContext];
}
- (void)tearDownSubviews
{
    [self.avatarImageView removeObserver:self forKeyPath:HiddenKeyPath context:&observationContext];
    [self.nameLabel removeObserver:self forKeyPath:HiddenKeyPath context:&observationContext];
}
- (void)updateSubviews
{
    [self updateNameLabel];
    // Tint colors.
    self.avatarImageView.layer.borderColor = self.tintColor.CGColor;
    self.nameLabel.textColor = self.tintColor;
}

- (void)updateNameLabel
{
    static UIFont *iconFont; // Not dynamic, so we can cache this.
    static NSString *addUserIcon = @"\ue6a9";
    static NSString *userIcon = @"\ue605";
    static NSString *usersIcon = @"\ue693";
    iconFont = iconFont ?: [UIFont fontWithName:NBIconFontFamilyName size:32.0f];
    if (self.actualButtonType == NBAccountButtonTypeIconOnly) {
        self.nameLabel.font = iconFont;
    }
    if (self.dataSource) {
        if (self.actualButtonType == NBAccountButtonTypeIconOnly) {
            self.nameLabel.text = self.contextHasMultipleActiveAccounts ? usersIcon : userIcon;
        } else {
            self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
            self.nameLabel.text = self.dataSource.name;
        }
    } else {
        if (self.actualButtonType == NBAccountButtonTypeIconOnly) {
            self.nameLabel.text = addUserIcon;
        } else {
            self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            self.nameLabel.text = @"label.sign-in".nb_localizedString;
        }
    }
}

- (void)updateButtonType
{
    NBAccountButtonType actualButtonType = self.buttonType;
    if (!self.dataSource) {
        if (self.buttonType == NBAccountButtonTypeAvatarOnly) {
            actualButtonType = NBAccountButtonTypeIconOnly;
        } else if (self.buttonType == NBAccountButtonTypeDefault) {
            actualButtonType = NBAccountButtonTypeNameOnly;
        }
    }
    self.actualButtonType = actualButtonType;
}

#pragma mark Accessors

- (void)setActualButtonType:(NBAccountButtonType)actualButtonType
{
    _actualButtonType = actualButtonType;
    // Did.
    self.nameLabel.hidden = NO;
    self.avatarImageView.hidden = NO;
    switch (actualButtonType) {
        case NBAccountButtonTypeIconOnly:
            self.avatarImageView.hidden = YES;
            break;
        case NBAccountButtonTypeAvatarOnly:
            self.nameLabel.hidden = YES;
            break;
        case NBAccountButtonTypeNameOnly:
            self.avatarImageView.hidden = YES;
            break;
        case NBAccountButtonTypeDefault: break;
    }
    [self updateSubviews];
}

@end