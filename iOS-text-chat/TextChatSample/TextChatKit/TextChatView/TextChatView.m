//
//  TextChatComponentChatView.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChat.h"
#import "TextChatView.h"
#import "TextChatTableViewCell.h"
#import "TextChatComponent.h"

#import "AcceleratorPackSession.h"

#import "GCDHelper.h"
#import "UIViewController+Helper.h"

#import "TextChatView_UserInterface.h"
#import "TextChatView_AutoLayout.h"

#import "TextChatUICustomizator_Properties.h"

static CGFloat StatusBarHeight = 20.0;
static const CGFloat TextChatInputViewHeight = 50.0;

@interface TextChatView() <UITableViewDataSource, UITextFieldDelegate, TextChatComponentDelegate>

@property (nonatomic) BOOL isShown;
@property (strong, nonatomic) TextChatComponent *textChatComponent;
@property (strong, nonatomic) UIView *attachedBottomView;
@end

@implementation TextChatView

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {
    
    [AcceleratorPackSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
}

- (BOOL)isShown {
    return self.superview ? YES : NO;
}

- (instancetype)init {
    return [TextChatView textChatView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    TextChatView *textChatView = [TextChatView textChatView];
    [textChatView setFrame:frame];
    return textChatView;
}

- (void)setAlias:(NSString *)alias; {
    [self.textChatComponent setAlias:alias];
}

-(void) setMaximumTextMessageLength: (NSUInteger) length {
    [self.textChatComponent setMaximumTextMessageLength:length];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 30.0;
    self.textField.delegate = self;
    self.textChatComponent = [[TextChatComponent alloc] init];
    self.textChatComponent.delegate = self;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.textChatComponent.maximumTextMessageLength];
    
    // work on instantiation and port it to sample app, done
    NSBundle *textChatViewBundle = [NSBundle bundleForClass:[TextChatView class]];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"SentChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedShortTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatComponentDivTableViewCell"
                                               bundle:textChatViewBundle]
         forCellReuseIdentifier:@"Divider"];
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    if (self.superview == nil) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatetTextChatUserInterface)
                                                 name:TextChatUIUpdatedNotificationName
                                               object:nil];
    
    [self addObserver:self
           forKeyPath:@"textChatComponent.receiverAlias"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:nil];
    
    [self addAttachedLayoutConstraintsToSuperview];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"textChatComponent.receiverAlias"];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
    
        CGFloat extreHeight = self.attachedBottomView ? CGRectGetHeight(self.attachedBottomView.bounds) : 0;
        self.bottomViewLayoutConstraint.constant = -kbSize.height + extreHeight;
    } completion:^(BOOL finished) {
        
        [self scrollTableViewToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.bottomViewLayoutConstraint.constant = 0;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"textChatComponent.receiverAlias"]) {
        [self refreshTitleBar];
    }
}

#pragma mark - Public methods
+ (instancetype)textChatView {
    return (TextChatView *)[[[NSBundle bundleForClass:[self class]] loadNibNamed:@"TextChatView"
                                                                           owner:nil
                                                                         options:nil] lastObject];
}

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView {
    
    TextChatView *textChatView = [TextChatView textChatView];
    textChatView.attachedBottomView = bottomView;
    return textChatView;
}

- (void)connect {
    [self.textChatComponent connect];
}

- (void)disconnect {
    [self.textChatComponent disconnect];
}

- (void)minimize {
    [self.textField resignFirstResponder];
    [GCDHelper executeDelayedWithBlock:^(){
        self.topViewLayoutConstraint.constant = CGRectGetHeight(self.tableView.bounds) + TextChatInputViewHeight + StatusBarHeight;
    }];
}

- (void)maximize {
    self.topViewLayoutConstraint.constant = StatusBarHeight;
}

- (void)show {
    
    if ([self isShown]) return;
    
    UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
    if (topViewController) {
        [topViewController.view addSubview:self];
    }
}

- (void)dismiss {
    if ([self isShown]) {
        [self.minimizeButton setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self removeFromSuperview];
    }
}

#pragma mark - Private methods
- (void)refreshTitleBar {
    self.textChatTopViewTitle.text = self.textChatComponent.receiverAlias;
}

- (void)insertNewTextMessageToTableView {
    NSInteger count = self.textChatComponent.messages.count;
    if (count == 0) return;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)scrollTableViewToBottom {
    
    NSInteger count = self.textChatComponent.messages.count;
    if (count == 0) return;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)updatetTextChatUserInterface {
    [self.tableView reloadData];
}

#pragma mark - IBActions
- (IBAction)minimizeView:(UIButton *)sender {
    
    if (self.topViewLayoutConstraint.constant != StatusBarHeight) {
        UIImage* minimize_image = [UIImage imageNamed:@"minimize"];
        [sender setImage:minimize_image forState:UIControlStateNormal];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self maximize];
    } else {
        UIImage* maximize_image = [UIImage imageNamed:@"maximize"];
        [sender setImage:maximize_image forState:UIControlStateNormal];
        [self.sendButton setTitle:@"" forState:UIControlStateNormal];
        [self minimize];
    }
}

- (IBAction)closeButton:(UIButton *)sender {
    [self dismiss];
}

- (IBAction)onSendButton:(id)sender {
    [self.textChatComponent sendMessage:self.textField.text];
    [self updateLabel: 0];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.textChatComponent.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // check if final divider
    TextChat *textChat = [self.textChatComponent getTextChatFromIndexPath:indexPath];
    TCMessageTypes type;
    if (indexPath.row < [self.textChatComponent.messages count]) {
        type = textChat.type;
    }
    
    NSString *cellId;
    switch (type) {
        case TCMessageTypesSent:
            cellId = @"SentChatMessage";
            break;
        case TCMessageTypesSentShort:
            cellId = @"SentChatMessageShort";
            break;
        case TCMessageTypesReceived:
            cellId = @"RecvChatMessage";
            break;
        case TCMessageTypesReceivedShort:
            cellId = @"RecvChatMessageShort";
            break;
        default:
            break;
    }
    
    TextChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                           forIndexPath:indexPath];
    [cell updateCellFromTextChat:textChat];
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onSendButton:textField];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Allow a backspace always, in case we went over inputMaxChars
    const char *_char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    if (strcmp(_char, "\b") == -8) {
        [self updateLabel:[textField.text length] - 1];
        return YES;
    }

    // If it's not a backspace, allow it if we're still under 150 chars.
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    [self updateLabel: newLength];
    return (newLength >= self.textChatComponent.maximumTextMessageLength) ? NO : YES;
}


-(void)updateLabel: (NSUInteger )Charlength {
    self.countLabel.alpha = 0;
    self.countLabel.textColor = [UIColor blackColor];
    self.textField.textColor = [UIColor blackColor];

    NSUInteger charLeft = self.textChatComponent.maximumTextMessageLength - Charlength;
    if (charLeft <= 50) {
        self.countLabel.alpha = 1;
        self.countLabel.textColor = [UIColor redColor];
        self.textField.textColor = [UIColor redColor];
    }
    NSString* charCountStr = [NSString stringWithFormat:@"%lu", (unsigned long)charLeft];
    self.countLabel.text = charCountStr;
}

#pragma mark - TextChatComponentDelegate
- (void)didAddMessageWithError:(NSError *)error {
    if(!error) {
        
        [self refreshTitleBar];
        [self insertNewTextMessageToTableView];
        [self scrollTableViewToBottom];
        self.textField.text = nil;
    }
    else {

        self.errorMessage.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^{
            self.errorMessage.alpha = 1.0f;
        }];
        
        [UIView animateWithDuration:0.5
                              delay:4
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.errorMessage.alpha = 0.0f;
                         }
                         completion:nil];
    }
    
    if (self.delegate) {
        [self.delegate textChatViewDidSendMessage:self error:error];
    }
}

- (void)didReceiveMessage {
    [self refreshTitleBar];
    [self insertNewTextMessageToTableView];
    [self scrollTableViewToBottom];
    if (self.delegate) {
        [self.delegate textChatViewDidReceiveMessage:self];
    }
}

- (void)didConnectWithError:(NSError *)error {
    
    [self refreshTitleBar];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:error];
    }
}

- (void)didDisConnectWithError:(NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectWithError:)]) {
        [self.delegate didDisConnectWithError:error];
    }
}

#pragma mark - Auto Layout helper
- (void)addAttachedLayoutConstraintsToSuperview {
    
    if (!self.superview) {
        NSLog(@"Could not addAttachedLayoutConstantsToSuperview, superview is nil");
        return;
    }

    StatusBarHeight = [UIApplication sharedApplication].isStatusBarHidden ? 0.0 : 20.0;

    self.topViewLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:StatusBarHeight];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.superview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    if (self.attachedBottomView) {
        self.bottomViewLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.attachedBottomView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:0.0];
    }
    else {
        self.bottomViewLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.superview
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:0.0];
    }
    
    [NSLayoutConstraint activateConstraints:@[self.topViewLayoutConstraint, leading, trailing, self.bottomViewLayoutConstraint]];
}
@end