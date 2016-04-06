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

static const CGFloat TextChatInputViewHeight = 50.0;

@interface TextChatView() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TextChatComponentDelegate>
@property (strong, nonatomic) TextChatComponent *textChatComponent;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// top view
@property (weak, nonatomic) IBOutlet UIView *textChatTopView;
@property (weak, nonatomic) IBOutlet UILabel *textChatTopViewTitle;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

// input view
@property (weak, nonatomic) IBOutlet UIView *textChatInputView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// other UIs
@property (weak, nonatomic) IBOutlet UIButton *errorMessage;
@property (weak, nonatomic) IBOutlet UIButton *messageBanner;

@property (nonatomic) BOOL minimized;

// constraints
@property (strong, nonatomic) NSLayoutConstraint *topViewLayoutConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomViewLayoutConstraint;
@end

@implementation TextChatView {
  BOOL anchorToBottom;
}

+ (instancetype)textChatView {
    return (TextChatView *)[[[NSBundle bundleForClass:[self class]] loadNibNamed:@"TextChatView" owner:nil options:nil] lastObject];
}

- (instancetype)init {
    return [TextChatView textChatView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    TextChatView *textChatView = [TextChatView textChatView];
    [textChatView setFrame:frame];
    return textChatView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.textField.delegate = self;
    self.textChatComponent = [[TextChatComponent alloc] init];
    self.textChatComponent.delegate = self;
    
    // work on instantiation and port it to sample app, done
    NSBundle *mainBundle = [NSBundle mainBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentTableViewCell"
                                               bundle:mainBundle]
         forCellReuseIdentifier:@"SentChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatSentShortTableViewCell"
                                               bundle:mainBundle]
         forCellReuseIdentifier:@"SentChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedTableViewCell"
                                               bundle:mainBundle]
         forCellReuseIdentifier:@"RecvChatMessage"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatReceivedShortTableViewCell"
                                               bundle:mainBundle]
         forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextChatComponentDivTableViewCell"
                                               bundle:mainBundle]
         forCellReuseIdentifier:@"Divider"];
}

- (void)didMoveToSuperview {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textChatComponent connect];
    [self addAttachedLayoutConstraintsToSuperview];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (anchorToBottom) {
        [self anchorToBottomAnimated:YES];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
    
        self.bottomViewLayoutConstraint.constant = -kbSize.height;
    } completion:^(BOOL finished) {
        
        [self makeTableViewScrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.bottomViewLayoutConstraint.constant = 0;
    }];
}

-(void)anchorToBottom {
  [self anchorToBottomAnimated:false];
}

-(void)anchorToBottomAnimated:(BOOL)animated {
  anchorToBottom = YES;
  if (![self isAtBottom]) {
    [_tableView setContentOffset:CGPointMake(0, MAX(0, _tableView.contentSize.height - self.layer.bounds.size.height)) animated:animated];
  }
}

-(BOOL)isAtBottom {
  if (_tableView.contentOffset.y >=  _tableView.contentSize.height - _tableView.bounds.size.height) {
    anchorToBottom = NO;
  } else {
    anchorToBottom = YES;
  }
  return anchorToBottom;
}

- (void)refreshTitleBar {
    if (self.textChatComponent.senders == nil) {
        self.textChatTopViewTitle.text = @"";
        return;
    }
    
    NSMutableString *title = [NSMutableString string];
    for(NSString *sender in self.textChatComponent.senders) {
        if ([sender length] > 0) {
            [title appendFormat:@"%@, ", sender];
        }
    }
    self.textChatTopViewTitle.text = title;
}

- (void)makeTableViewScrollToBottom {
    
    NSInteger count = self.textChatComponent.messages.count;
    if (count == 0) return;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - IBActions
- (IBAction)minimizeView:(UIButton *)sender {

#warning the AutoLayout system is going to complain and it's okay so far
    if (self.minimized) {
        UIImage* minimize_image = [UIImage imageNamed:@"minimize"];
        [sender setImage:minimize_image forState:UIControlStateNormal];
        
        
        self.topViewLayoutConstraint.constant = 0;
    }
    else {
        UIImage* maximize_image = [UIImage imageNamed:@"maximize"];
        [sender setImage:maximize_image forState:UIControlStateNormal];
        
        self.topViewLayoutConstraint.constant = CGRectGetHeight(self.tableView.bounds) + TextChatInputViewHeight;
    }
    
    self.minimized = !self.minimized;
}

- (IBAction)closeButton:(UIButton *)sender {
  [self.minimizeButton setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
  self.minimized = NO;
  [self removeFromSuperview];
}

- (IBAction)onSendButton:(id)sender {
    if ([self.textField.text length] > 0) {
        [self.textChatComponent sendMessage:self.textField.text];
    }
}

- (IBAction)onNewMessageButton:(id)sender {
    [self anchorToBottomAnimated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.messageBanner.alpha = 0.0f;
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.textChatComponent.messages count] > 0 ? [self.textChatComponent.messages count] + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextChat *msg;
    
    TCMessageTypes type = TCMessageTypesDivider;
    
    // check if final divider
    if (indexPath.row < [self.textChatComponent.messages count]) {
        msg = [self.textChatComponent.messages objectAtIndex:indexPath.row];
        type = msg.type;
    }
    
    NSString *cellId;
    TextChatTableViewCell *cell;
    
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
        case TCMessageTypesDivider:
            cellId = @"Divider";
            break;
        default:
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                           forIndexPath:indexPath];
    
    if (cell.time) {
        NSDate *current_date = msg.dateTime == nil ? [[NSDate alloc] init] : msg.dateTime;
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"hh:mm a";
        NSString *msg_sender = [msg.senderAlias length] > 0 ? msg.senderAlias : @" ";
        cell.UserLetterLabel.text = [msg_sender substringToIndex:1];
        cell.time.text = [NSString stringWithFormat:@"%@, %@", msg_sender, [timeFormatter stringFromDate: current_date]];
    }
    
    if (cell.message) {
        cell.message.text = msg.text;
        cell.message.layer.cornerRadius = 6.0f;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // final divider
    if (indexPath.row >= [self.textChatComponent.messages count]) {
        return 1;
    }
    
    TextChat *msg = [self.textChatComponent.messages objectAtIndex:indexPath.row];
    
    if (msg.type == TCMessageTypesDivider) {
        return 1;
    }
    
    float extras = 140.0f;
    float normal_space = 133.0f;
    if (msg.type == TCMessageTypesSentShort || msg.type == TCMessageTypesReceivedShort) {
        extras = 30.0f;
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:msg.text attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0] }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){(tableView.bounds.size.width - normal_space), CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + extras;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.5 animations:^{
        self.messageBanner.alpha = 0.0f;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self isAtBottom]) {
        [self anchorToBottomAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onSendButton:textField];
    return NO;
}

#pragma mark - TextChatComponentDelegate
- (void)didConnectWithError:(NSError *)error {
    
    [self refreshTitleBar];
}

- (void)didAddMessageWithError:(NSError *)error {
    if(!error) {
        
        [self refreshTitleBar];
        [self.tableView reloadData];
        [self makeTableViewScrollToBottom];
        [self anchorToBottomAnimated:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.messageBanner.alpha = 0.0f;
        }];
        
        self.textField.text = nil;
    } else {
        
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
}

- (void)didReceiveMessage {
    [self.tableView reloadData];
    [self makeTableViewScrollToBottom];
}

#pragma mark - Auto Layout helper
- (void)addAttachedLayoutConstraintsToSuperview {
    
    if (!self.superview) {
        NSLog(@"Could not addAttachedLayoutConstantsToSuperview, superview is nil");
        return;
    }
    
    self.topViewLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTopMargin
                                                          multiplier:1.0
                                                            constant:0.0];
    
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
    self.bottomViewLayoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    [NSLayoutConstraint activateConstraints:@[self.topViewLayoutConstraint, leading, trailing, self.bottomViewLayoutConstraint]];
}
@end
