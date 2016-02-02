//
//  IMComponent.m
//  IMComponent
//
//  Created by Esteban Cordero on 1/28/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "IMComponent.h"
#import "IMComponentTableViewCell.h"
#import "IMComponentChatView.h"

#define DEFAULT_MAX_LENGTH 1000
#define DEFAULT_TIME_SPAN 120

@interface IMComponent ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) IBOutlet IMComponentChatView *textChatView;
@property (weak, nonatomic) IBOutlet UINavigationBar *topNavBar;

@end

typedef enum : NSUInteger {
  OTK_SENT_MESSAGE,
  OTK_SENT_MESSAGE_SHORT,
  OTK_RECEIVED_MESSAGE,
  OTK_RECEIVED_MESSAGE_SHORT,
  OTK_DIVIDER
} OTK_MESSAGE_TYPES;

@interface IMComponentMessage ()

@property (nonatomic) OTK_MESSAGE_TYPES type;

@end

@implementation IMComponentMessage
@end


@implementation IMComponent {
  int maxLength;
  NSString *mySenderId;
  NSString *myAlias;
}

- (instancetype)init {
  self = [super init];
  if (self)  {
    _messages = [[NSMutableArray alloc] init];
    maxLength = DEFAULT_MAX_LENGTH;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    UINib *viewNIB = [UINib nibWithNibName:@"IMComponent" bundle:bundle];
    [viewNIB instantiateWithOwner:self options:nil];
    
    UINib *cellNIB = [UINib nibWithNibName:@"IMComponentSentTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"SentChatMessage"];
    
    cellNIB = [UINib nibWithNibName:@"IMComponentSentShortTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"SentChatMessageShort"];
    
    cellNIB = [UINib nibWithNibName:@"IMComponentRecvTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"RecvChatMessage"];
    
    cellNIB = [UINib nibWithNibName:@"IMComponentRecvShortTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"RecvChatMessageShort"];
    
    cellNIB = [UINib nibWithNibName:@"IMComponentDivTableViewCell" bundle:bundle];
    [_textChatView.tableView registerNib:cellNIB forCellReuseIdentifier:@"Divider"];
    
    [_textChatView anchorToBottom];
    
    // Add padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    _textChatView.textField.leftView = paddingView;
    _textChatView.textField.leftViewMode = UITextFieldViewModeAlways;
    
    [self updateCounter:maxLength];
    
  }
  return self;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_messages count] > 0 ? [_messages count] + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  IMComponentMessage *msg;
  
  OTK_MESSAGE_TYPES type = OTK_DIVIDER;
  
  // check if final divider
  if (indexPath.row < [_messages count]) {
    msg = [_messages objectAtIndex:indexPath.row];
    type = msg.type;
  }
  
  NSString *cellId;
  IMComponentTableViewCell *cell;
  
  switch (type) {
    case OTK_SENT_MESSAGE:
      cellId = @"SentChatMessage";
      break;
    case OTK_SENT_MESSAGE_SHORT:
      cellId = @"SentChatMessageShort";
      break;
    case OTK_RECEIVED_MESSAGE:
      cellId = @"RecvChatMessage";
      break;
    case OTK_RECEIVED_MESSAGE_SHORT:
      cellId = @"RecvChatMessageShort";
      break;
    case OTK_DIVIDER:
      cellId = @"Divider";
      break;
    default:
      break;
  }
  
  cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                         forIndexPath:indexPath];
  
  if (cell.username) {
    cell.username.text = msg.senderAlias;
  } else {
    cell.username.text = @"You";
  }
  
  if (cell.time) {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:mma";
    NSDate *start = [NSDate date];
    NSTimeInterval timeInterval = ([start timeIntervalSinceDate:msg.dateTime] / 60);
  
    if (timeInterval <= 1) {
      cell.time.text = @"just now";
    } else if (timeInterval > 1.0f && timeInterval < 2.0f) {
      cell.time.text = @"1 min ago";
    } else {
      cell.time.text = [timeFormatter stringFromDate:msg.dateTime];
    }
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
  
  IMComponentMessage *msg = [_messages objectAtIndex:indexPath.row];
  
  if (msg.type == OTK_DIVIDER) {
    return 1;
  }
  
  float extras = 140.0f;
  float normal_space = 123.0f;
  if (msg.type == OTK_RECEIVED_MESSAGE_SHORT || msg.type == OTK_SENT_MESSAGE_SHORT) {
    extras = 20.0f;
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
    [self updateCounter:maxLength - textLength];
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self onSendButton:textField];
  return NO;
}

#pragma mark Public API

- (BOOL)addMessage:(IMComponentMessage *)message {
  
  message.type = OTK_RECEIVED_MESSAGE;
  if (!message.dateTime) {
    message.dateTime = [[NSDate alloc] init];
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
  [self updateCounter:maxLength - (int)[_textChatView.textField.text length]];
}

- (void)setSenderId:(NSString *)senderId alias:(NSString *)alias {
  mySenderId = senderId;
  myAlias = alias;
}

#pragma mark Implementation

- (void)pushBackMessage:(IMComponentMessage *)message {
  if ([_messages count] > 0) {
    IMComponentMessage *prev = [_messages objectAtIndex:[_messages count] -1];
    
    if ([message.dateTime timeIntervalSinceDate:prev.dateTime] < DEFAULT_TIME_SPAN &&
        [prev.senderId isEqualToString:message.senderId]) {
      if (message.type == OTK_RECEIVED_MESSAGE) {
        message.type = OTK_RECEIVED_MESSAGE_SHORT;
      } else {
        message.type = OTK_SENT_MESSAGE_SHORT;
      }
    } else {
      IMComponentMessage *div = [[IMComponentMessage alloc] init];
      div.type = OTK_DIVIDER;
      [_messages addObject:div];
    }
  }
  
  [_messages addObject:message];
  
  [_textChatView.tableView reloadData];
}

- (IBAction)onSendButton:(id)sender {
  if ([_textChatView.textField.text length] > 0) {
    IMComponentMessage *msg = [[IMComponentMessage alloc] init];
    msg.senderAlias = myAlias;
    msg.senderId = mySenderId;
    msg.text = _textChatView.textField.text;
    msg.type = OTK_SENT_MESSAGE;
    msg.dateTime = [[NSDate alloc] init];
    
    if([self.delegate onMessageReadyToSend:msg]) {
      
      [self pushBackMessage:msg];
      
      [_textChatView anchorToBottomAnimated:YES];
      [UIView animateWithDuration:0.5 animations:^{
        _textChatView.messageBanner.alpha = 0.0f;
      }];
      
      _textChatView.textField.text = nil;
      [self updateCounter:maxLength];
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

- (void)updateCounter:(int)count {
  _textChatView.countLabel.text = [NSString stringWithFormat:@"%d Characters left", count];
  
  if (count <= 10) {
    [_textChatView.countLabel setTextColor:[UIColor redColor]];
  } else {
    [_textChatView.countLabel setTextColor:[UIColor colorWithWhite:1 alpha:1]];
  }
}
//- (IBAction)toggleWindow:(UIBarButtonItem *)sender {
//  UIImage* maximize = [UIImage imageNamed:@"maximize.png"];
//  UIImage* minimize = [UIImage imageNamed:@"minimize.png"];

//  if ([sender.image.description  isEqual: @"minimize.png"]){
//    sender.image = maximize
//  } else {
//    sender.image = minimize
//  }
//}



@end
