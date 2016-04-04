//
//  TextChatComponent.m
//  TextChatComponent
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "TextChatComponent.h"
#import "TextChat.h"
#import "TextChatTableViewCell.h"
#import "TextChatView.h"

#define DEFAULT_MAX_LENGTH 1000
#define DEFAULT_TTextChatE_SPAN 120

@interface TextChatComponent ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) IBOutlet TextChatView *textChatView;

@end

@implementation TextChatComponent {
  int maxLength;
  NSString *mySenderId;
  NSString *myAlias;
  
  NSMutableDictionary *senders;
}

- (instancetype)init {
  self = [super init];
  if (self)  {
    _messages = [[NSMutableArray alloc] init];
    maxLength = DEFAULT_MAX_LENGTH;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    UINib *viewNIB = [UINib nibWithNibName:@"TextChatViewController" bundle:bundle];
    [viewNIB instantiateWithOwner:self options:nil];
    
    UINib *cellNIB = [UINib nibWithNibName:@"TextChatSentTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"SentChatMessage"];
    
    cellNIB = [UINib nibWithNibName:@"TextChatSentShortTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"SentChatMessageShort"];
    
    cellNIB = [UINib nibWithNibName:@"TextChatReceivedTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"RecvChatMessage"];
    
    cellNIB = [UINib nibWithNibName:@"TextChatReceivedShortTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    cellNIB = [UINib nibWithNibName:@"TextChatComponentDivTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"Divider"];
    
    [_textChatView anchorToBottom];
    
    // Add padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    _textChatView.textField.leftView = paddingView;
    _textChatView.textField.leftViewMode = UITextFieldViewModeAlways;
  }
  return self;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_messages count] > 0 ? [_messages count] + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  TextChat *msg;
  
  TCMessageTypes type = TCMessageTypesDivider;
  
  // check if final divider
  if (indexPath.row < [_messages count]) {
    msg = [_messages objectAtIndex:indexPath.row];
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
  [_textChatView.textField resignFirstResponder];
  return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // final divider
  if (indexPath.row >= [_messages count]) {
    return 1;
  }
  
  TextChat *msg = [_messages objectAtIndex:indexPath.row];
  
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [_textChatView disableAnchorToBottom];
  [UIView animateWithDuration:0.5 animations:^{
    _textChatView.messageBanner.alpha = 0.0f;
  }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([_textChatView isAtBottom]) {
    [_textChatView anchorToBottomAnimated:YES];
  }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  int textLength = (int)([textField.text length] + [string length] - range.length);
  
  if (textLength > maxLength) {
    return NO;
  } else {
    return YES;
  }
}

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
  
  if (![senders objectForKey: message.senderId]){
    [senders setObject: message.senderAlias forKey: message.senderId];
    [self setTitleToTopBar: senders];
  }
  
  [self pushBackMessage:message];
  
  if (_textChatView.isAnchoredToBottom) {
    [_textChatView anchorToBottomAnimated:YES];
  } else {
    [UIView animateWithDuration:0.5 animations:^{
      _textChatView.messageBanner.alpha = 1.0f;
    }];
  }
  return YES;
}

- (void)setMaxLength:(int) length {
  maxLength = length;
}

- (void)setSenderId:(NSString *)senderId alias:(NSString *)alias {
  mySenderId = senderId;
  myAlias = [alias length] > 0 ? alias : @"";
  if (![senders objectForKey: mySenderId]){
    [senders setObject:myAlias forKey:mySenderId];
  }
}

#pragma mark Implementation

- (void)pushBackMessage:(TextChat *)message {
  if ([_messages count] > 0) {
    TextChat *prev = [_messages objectAtIndex:[_messages count] -1];
    
    if ([message.dateTime timeIntervalSinceDate:prev.dateTime] < DEFAULT_TTextChatE_SPAN &&
        [prev.senderId isEqualToString:message.senderId]) {
      if (message.type == TCMessageTypesReceived) {
        message.type = TCMessageTypesReceivedShort;
      } else {
        message.type = TCMessageTypesSentShort;
      }
    } else {
      TextChat *div = [[TextChat alloc] init];
      div.type = TCMessageTypesDivider;
      [_messages addObject:div];
    }
  }
  
  [_messages addObject:message];
  
  [_textChatView.tableView reloadData];
}

- (IBAction)onSendButton:(id)sender {
  if ([_textChatView.textField.text length] > 0) {
    TextChat *msg = [[TextChat alloc] init];
    msg.senderAlias = myAlias;
    msg.senderId = mySenderId;
    msg.text = _textChatView.textField.text;
    msg.type = TCMessageTypesSent;
    msg.dateTime = [[NSDate alloc] init];
    
    if([self.delegate onMessageReadyToSend:msg]) {
      
      [self pushBackMessage:msg];
      
      [_textChatView anchorToBottomAnimated:YES];
      [UIView animateWithDuration:0.5 animations:^{
        _textChatView.messageBanner.alpha = 0.0f;
      }];
      
      _textChatView.textField.text = nil;
    } else {
      // Show error message
      _textChatView.errorMessage.alpha = 0.0f;
      [UIView animateWithDuration:0.5 animations:^{
        _textChatView.errorMessage.alpha = 1.0f;
      }];
      
      [UIView animateWithDuration:0.5
                            delay:4
                          options:UIViewAnimationOptionTransitionNone
                       animations:^{
                         _textChatView.errorMessage.alpha = 0.0f;
                       } completion:nil];
      
    }
  }
}

- (IBAction)onNewMessageButton:(id)sender {
  [_textChatView anchorToBottomAnimated:YES];
  [UIView animateWithDuration:0.5 animations:^{
    _textChatView.messageBanner.alpha = 0.0f;
  }];
}

-(void) setTitleToTopBar: (NSMutableDictionary *)title {
  if (title == nil) {
    _textChatView.textChatTopViewTitle.text = @"";
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
  _textChatView.textChatTopViewTitle.text = real_title;
}

@end
