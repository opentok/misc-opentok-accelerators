//
//  TextChatComponentChatView.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatView.h"
#import "TextChatTableViewCell.h"
#import "TextChatComponent.h"

#define DEFAULT_TTextChatE_SPAN 120

@interface TextChatView() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextChatInputViewHeightConstrain;

@end

@implementation TextChatView {
  BOOL anchorToBottom;
  BOOL minimized;
}

+ (instancetype)textChatView {
    return (TextChatView *)[[[NSBundle mainBundle] loadNibNamed:@"TextChatView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.textField.delegate = self;
    self.textChatComponent = [[TextChatComponent alloc] init];
    
    [self anchorToBottom];
    
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
    [self.textChatComponent connectWithHandler:^(NSError *error) {
        
        
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [_textField resignFirstResponder];
  [super touchesBegan:touches withEvent:event];
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


- (void)layoutSubviews {
  [super layoutSubviews];
  if (anchorToBottom) {
    [self anchorToBottomAnimated:YES];
  }
}

- (IBAction)minimizeView:(UIButton *)sender {
  UIImage* maximize_image = [UIImage imageNamed:@"maximize"];
  UIImage* minimize_image = [UIImage imageNamed:@"minimize"];
  CGRect r = [self.layer frame];
  CGFloat rect;
  if ([[UIApplication sharedApplication] isStatusBarHidden]) {
    rect = 0;
  } else {
    rect = [[UIApplication sharedApplication] statusBarFrame].size.height;
  }
  if (minimized) {
    [sender setImage:minimize_image forState:UIControlStateNormal];
    r.origin.y = rect;
    r.size.height = self.superview.bounds.size.height - rect;
    minimized = NO;
    _TextChatInputViewHeightConstrain.constant = 50;
  } else {
    [sender setImage:maximize_image forState:UIControlStateNormal];
    r.origin.y = (self.superview.bounds.size.height - _textChatTopView.layer.bounds.size.height);
    r.size.height = _textChatTopView.layer.bounds.size.height;
    minimized = YES;
    _TextChatInputViewHeightConstrain.constant = 0;
    
  }

  self.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height);
}

- (IBAction)closeButton:(UIButton *)sender {
  // to reset the minimize button that can be on a different state when close button is hit
  [self.minimizeButton setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
  minimized = NO;
  [self removeFromSuperview];
}

#pragma mark UITableViewDataSource

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
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"hh:mm a";
        NSString *msg_sender = [msg.senderAlias length] > 0 ? msg.senderAlias : @"A";
        cell.UserLetterLabel.text = [msg_sender substringToIndex:1];
        cell.time.text = [NSString stringWithFormat:@"%@, %@", msg_sender, [timeFormatter stringFromDate:msg.dateTime]];
    }
    
    if (cell.message) {
        cell.message.text = msg.text;
        cell.message.layer.cornerRadius = 6.0f;
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.textField resignFirstResponder];
    return NO;
}

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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onSendButton:textField];
    return NO;
}

#pragma mark Public API

- (BOOL)addMessage:(TextChat *)message {
    
    message.type = TCMessageTypesReceived;
    if (!message.dateTime) {
        message.dateTime = [[NSDate alloc] init];
    }
    
    if (![self.textChatComponent.senders objectForKey: message.senderId]){
        [self.textChatComponent.senders setObject: message.senderAlias forKey: message.senderId];
        [self setTitleToTopBar: self.textChatComponent.senders];
    }
    
    [self pushBackMessage:message];
    
    if (self.isAtBottom) {
        [self anchorToBottomAnimated:YES];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.messageBanner.alpha = 1.0f;
        }];
    }
    return YES;
}

- (void)setSenderId:(NSString *)senderId alias:(NSString *)alias {
    self.textChatComponent.senderId = senderId;
    self.textChatComponent.alias = [alias length] > 0 ? alias : @"";
    if (!self.textChatComponent.senders[self.textChatComponent.senderId]) {
        self.textChatComponent.senders[self.textChatComponent.senderId] = self.textChatComponent.alias;
    }
}

#pragma mark Implementation

- (void)pushBackMessage:(TextChat *)message {
    if ([self.textChatComponent.messages count] > 0) {
        TextChat *prev = [self.textChatComponent.messages objectAtIndex:[self.textChatComponent.messages count] - 1];
        if ([message.dateTime timeIntervalSinceDate:prev.dateTime] < DEFAULT_TTextChatE_SPAN && prev.senderId == message.senderId) {
            if (message.type == TCMessageTypesReceived) {
                message.type = TCMessageTypesReceivedShort;
            } else {
                message.type = TCMessageTypesSentShort;
            }
        } else {
            TextChat *div = [[TextChat alloc] init];
            div.type = TCMessageTypesDivider;
            [self.textChatComponent.messages addObject:div];
        }
    }
    
    [self.textChatComponent.messages addObject:message];
    
    [self.tableView reloadData];
}

- (IBAction)onSendButton:(id)sender {
    if ([self.textField.text length] > 0) {
        TextChat *msg = [[TextChat alloc] init];
        msg.senderAlias = self.textChatComponent.alias;
        msg.senderId = self.textChatComponent.senderId;
        msg.text = self.textField.text;
        msg.type = TCMessageTypesSent;
        msg.dateTime = [[NSDate alloc] init];

        if(![self.textChatComponent sendMessage:msg]) {
            
            [self pushBackMessage:msg];
            
            [self anchorToBottomAnimated:YES];
            [UIView animateWithDuration:0.5 animations:^{
                self.messageBanner.alpha = 0.0f;
            }];
            
            self.textField.text = nil;
        } else {
            // Show error message
            self.errorMessage.alpha = 0.0f;
            [UIView animateWithDuration:0.5 animations:^{
                self.errorMessage.alpha = 1.0f;
            }];
            
            [UIView animateWithDuration:0.5
                                  delay:4
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.errorMessage.alpha = 0.0f;
                             } completion:nil];
            
        }
    }
}

- (IBAction)onNewMessageButton:(id)sender {
    [self anchorToBottomAnimated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.messageBanner.alpha = 0.0f;
    }];
}

-(void) setTitleToTopBar: (NSMutableDictionary *)title {
    if (title == nil) {
        self.textChatTopViewTitle.text = @"";
        return;
    }
    NSMutableString *real_title = [NSMutableString string];
    for(NSString *key in title) {
        if ([real_title length] > 0) {
            [real_title appendFormat:@"%@, ", title[key]];
        } else {
            real_title = title[key];
        }
    }
    self.textChatTopViewTitle.text = real_title;
}
@end
