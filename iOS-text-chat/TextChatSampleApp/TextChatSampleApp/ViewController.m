//
//  ViewController.m
//  TextChatSampleApp
//
//  Created by Esteban Cordero on 2/23/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>
#import "TextChatView.h"

@interface ViewController ()<OTSessionDelegate>
@property (strong, nonatomic) TextChatView *textChatView;
@end

// ===============================================================================================//
// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"100";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX4xMDB-flR1ZSBOb3YgMTkgMTE6MDk6NTggUFNUIDIwMTN-MC4zNzQxNzIxNX4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9OTU3ZmU3MDhjNDFhNmJjYmE3NjhmYmE3YzU1NjUyMGZlNTJmYTJhMTpzZXNzaW9uX2lkPTJfTVg0eE1EQi1mbFIxWlNCT2IzWWdNVGtnTVRFNk1EazZOVGdnVUZOVUlESXdNVE4tTUM0ek56UXhOekl4Tlg0JmNyZWF0ZV90aW1lPTE0NTkzNjAyMjcmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ1OTM2MDIyNy44MjY3MjQyNjk1OTU2JmV4cGlyZV90aW1lPTE0NjE5NTIyMjc=";
// ===============================================================================================//
static NSString* const kTextChatType = @"TextChat";

@implementation ViewController{
  OTSession* _session;
}



- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  _session = [[OTSession alloc] initWithApiKey:kApiKey
                                     sessionId:kSessionId
                                      delegate:self];

  OTError *error = nil;
  [_session connectWithToken:kToken error:&error];
  if (error) {
    [self showAlert:[error localizedDescription]];
  }

}

- (void)showAlert:(NSString *)string {
  // show alertview on main UI
  dispatch_async(dispatch_get_main_queue(), ^{
    [self createAlert:@"ERROR" with_message:string with_yes_button:nil with_no_button:@"OK"];
  });
}

-(void) createAlert: (NSString *)title
       with_message: (NSString *)message_alert
    with_yes_button: (NSString *) yes_action
     with_no_button: (NSString *)no_action {
  UIAlertController * alert=   [UIAlertController
                                alertControllerWithTitle: title
                                message: message_alert
                                preferredStyle:UIAlertControllerStyleAlert];
  if (yes_action != nil) {
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle: yes_action
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                  //Handel your yes please button action here

                                }];
    [alert addAction:yesButton];
  }
  if (no_action != nil) {
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle: no_action
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                 //Handel no, thanks button

                               }];
    [alert addAction:noButton];
  }
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{

    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20 + kbSize.height;
    self.textChatView.frame = r;
  }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{

    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20;
    self.textChatView.frame = r;

  }];
}

- (BOOL)onMessageReadyToSend:(TextChat *)message {
  OTError *error = nil;
  [_session signalWithType:kTextChatType string:message.text connection:nil error:&error];
  if (error) {
    return NO;
  } else {
    return YES;
  }
}


#pragma mark OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session {

  // When we've connected to the session, we can create the chat component.
    self.textChatView = [TextChatView textChatView];
//  _textChat = [[TextChatComponent alloc] init];

  self.textChatView.delegate = self;
  [self.textChatView setSenderId:session.connection.connectionId alias:session.connection.data];

  CGRect r = self.view.bounds;
  r.origin.y += 20;
  r.size.height -= 20;
  [self.textChatView setFrame:r];
  [self.view addSubview:self.textChatView];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

  // fade in
  self.textChatView.alpha = 0;

  [UIView animateWithDuration:0.5 animations:^() {
    _connectingLabel.alpha = 0;
    self.textChatView.alpha = 1;
  }];
  [self.textChatView setTitleToTopBar: [[NSMutableDictionary alloc] initWithDictionary:@{session.connection.connectionId: ([session.connection.data length] > 0 ? session.connection.data : @"")}]];
}

- (void)sessionDidDisconnect:(OTSession*)session {
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
  NSLog(@"didFailWithError: (%@)", error);
  [self showAlert:[error localizedDescription]];
}

- (void)session:(OTSession*)session streamCreated:(OTStream*)stream {
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream {
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
  NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
  NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
}

- (void)session:(OTSession*)session receivedSignalType:(NSString*)type
 fromConnection:(OTConnection*)connection
     withString:(NSString*)string {
  if (![connection.connectionId isEqualToString:_session.connection.connectionId]) {
    TextChat *msg = [[TextChat alloc]init];
    msg.senderAlias = [connection.data length] > 0 ? connection.data : @"";
    msg.senderId = connection.connectionId;
    msg.text = string;
    [self.textChatView addMessage:msg];
    [self.textChatView setTitleToTopBar: [[NSMutableDictionary alloc] initWithDictionary:@{msg.senderId: msg.senderAlias}]];
  }
}

@end
