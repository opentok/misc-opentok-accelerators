//
//  OTTextChatView.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTTextMessage.h"
#import "OTTextChatView.h"
#import "OTTextChatTableViewCell.h"
#import "OTTextMessageManager.h"

#import <OTAcceleratorPackUtil/OTAcceleratorPackUtil.h>
#import <OTKAnalytics/OTKLogger.h>

#import "GCDHelper.h"
#import "UIViewController+Helper.h"

#import "OTTextChatView_UserInterface.h"
#import "OTTextChatUICustomizator_Private.h"

static CGFloat StatusBarHeight = 20.0;

@interface OTTextChatView() <UITableViewDataSource, UITextFieldDelegate, TextMessageManagerDelegate>

@property (nonatomic) BOOL show;
@property (nonatomic) OTTextMessageManager *textChatComponent;
@property (nonatomic) OTTextChatUICustomizator *customizator;
@property (nonatomic) UIView *attachedBottomView;

@property (strong, nonatomic) TextChatViewEventBlock handler;
@end

@implementation OTTextChatView

+ (void)setOpenTokApiKey:(NSString *)apiKey
               sessionId:(NSString *)sessionId
                   token:(NSString *)token {
    
    [OTAcceleratorSession setOpenTokApiKey:apiKey sessionId:sessionId token:token];
}

- (BOOL)isShown {
    return self.superview ? YES : NO;
}

- (instancetype)init {
    return [OTTextChatView textChatView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    OTTextChatView *textChatView = [OTTextChatView textChatView];
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
    self.tableView.estimatedRowHeight = 130.0;
    self.textField.delegate = self;
    self.textChatComponent = [[OTTextMessageManager alloc] init];
    self.customizator = [[OTTextChatUICustomizator alloc] init];
    self.textChatComponent.delegate = self;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.textChatComponent.maximumTextMessageLength];
    
    // work on instantiation and port it to sample app, done
    NSBundle *textChatViewBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"OTTextChatKitBundle" withExtension:@"bundle"]];
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
    
    [self updateTopBarUserInterface];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
        
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            
            CGFloat extreHeight = self.attachedBottomView ? CGRectGetHeight(self.attachedBottomView.bounds) : 0;
            self.bottomViewLayoutConstraint.constant = -kbSize.height + extreHeight;
        } completion:^(BOOL finished) {
            
            [self scrollTableViewToBottom];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
        
        NSDictionary* info = [notification userInfo];
        double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            
            self.bottomViewLayoutConstraint.constant = 0;
        }];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:TextChatUIUpdatedNotificationName
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
    
        [self.tableView reloadData];
        [self updateTopBarUserInterface];
    }];

    
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
    
    [OTKLogger analyticsWithClientVersion:KLogClientVersion
                                   source:[[NSBundle mainBundle] bundleIdentifier]
                              componentId:kLogComponentIdentifier
                                     guid:[[NSUUID UUID] UUIDString]];
    
    NSBundle *textChatViewBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"OTTextChatKitBundle" withExtension:@"bundle"]];
    return (OTTextChatView *)[[textChatViewBundle loadNibNamed:@"OTTextChatView"
                                                      owner:nil
                                                    options:nil] lastObject];
}

+ (instancetype)textChatViewWithBottomView:(UIView *)bottomView {
    
    OTTextChatView *textChatView = [OTTextChatView textChatView];
    textChatView.attachedBottomView = bottomView;
    return textChatView;
}

- (void)connect {
    [self.textChatComponent connect];
}

- (void)connectWithHandler:(TextChatViewEventBlock)handler {
    self.handler = handler;
    [self.textChatComponent connect];
}

- (void)disconnect {
    [self.textChatComponent disconnect];
}

- (void)show {
    
    if (self.isShown) return;
    
    UIViewController *topViewController = [UIViewController topViewControllerWithRootViewController];
    if (topViewController) {
        [topViewController.view addSubview:self];
    }
}

- (void)dismiss {
    if (self.isShown) {
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
    
    // TODO: this is to prevent scrolling back to top when reloading
    CGPoint contentOffset = self.tableView.contentOffset;
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [self.tableView setContentOffset:contentOffset];
}

- (void)scrollTableViewToBottom {
    
    NSInteger count = self.textChatComponent.messages.count;
    if (count == 0) return;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)updateTopBarUserInterface {
    if(self.customizator.topBarBackgroundColor != nil) self.textChatTopView.backgroundColor = self.customizator.topBarBackgroundColor;
    if(self.customizator.topBarTitleTextColor != nil) self.textChatTopViewTitle.textColor = self.customizator.topBarTitleTextColor;
}

#pragma mark - IBActions
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
    OTTextMessage *textChat = [self.textChatComponent getTextChatFromIndexPath:indexPath];
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
    
    OTTextChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                                  forIndexPath:indexPath];
    [cell updateCellFromTextChat:textChat
                    customizator:self.customizator];
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
    [self.countLabel setHidden:YES];
    self.countLabel.textColor = [UIColor blackColor];
    self.textField.textColor = [UIColor blackColor];

    NSUInteger charLeft = self.textChatComponent.maximumTextMessageLength - Charlength;
    NSUInteger closeEnd = round(self.textChatComponent.maximumTextMessageLength * .1);
    if (closeEnd >= 100) closeEnd = 30;
    if (charLeft <= closeEnd) {
        [self.countLabel setHidden:NO];
        self.countLabel.textColor = [UIColor redColor];
        self.textField.textColor = [UIColor redColor];
    }
    NSString* charCountStr = [NSString stringWithFormat:@"%lu", (unsigned long)charLeft];
    self.countLabel.text = charCountStr;
}

#pragma mark - TextChatComponentDelegate
- (void)didAddTextChat:(OTTextMessage *)textChat error:(NSError *)error {
    if(!error) {
        
        [self refreshTitleBar];
        [self insertNewTextMessageToTableView];
        [self scrollTableViewToBottom];
        self.textField.text = nil;
    }
    else {

        [self.errorMessage setHidden:YES];
        [UIView animateWithDuration:0.5 animations:^{
            [self.errorMessage setHidden:NO];
        }];
        
        [UIView animateWithDuration:0.5
                              delay:4
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [self.errorMessage setHidden:YES];
                         }
                         completion:nil];
    }
    
    if (self.delegate) {
        [self.delegate textChatView:self didSendtextChat:textChat error:error];
    }
    if (self.handler) {
        self.handler(TextChatViewEventSignalDidSendMessage, textChat, error);
    }
}

- (void)didReceiveTextChat:(OTTextMessage *)textChat {
    [self refreshTitleBar];
    [self insertNewTextMessageToTableView];
    [self scrollTableViewToBottom];
    if (self.delegate) {
        [self.delegate textChatView:self didReceiveTextChat:textChat];
    }
    if (self.handler) {
        self.handler(TextChatViewEventSignalDidReceiveMessage, textChat, nil);
    }
}

- (void)didConnectWithError:(NSError *)error {
    
    [self refreshTitleBar];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithError:)]) {
        [self.delegate didConnectWithError:error];
    }
    if (self.handler) {
        self.handler(TextChatViewEventSignalDidConnect, nil, nil);
    }
}

- (void)didDisConnectWithError:(NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectWithError:)]) {
        [self.delegate didDisConnectWithError:error];
    }
    if (self.handler) {
        self.handler(TextChatViewEventSignalDidDisconnect, nil, nil);
    }
}

#pragma mark - Auto Layout helper
- (void)addAttachedLayoutConstraintsToSuperview {

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
