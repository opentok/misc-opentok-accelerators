//
//  ViewController.m
//  TextChatComponetSample
//
//  Created by Esteban Cordero on 1/31/16.
//  Copyright © 2016 AgilityFeat. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>

@interface ViewController ()<OTSessionDelegate>

@end

// ===============================================================================================//
// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45477012";
// Replace with your generated session ID
static NSString* const kSessionId = @"2_MX40NTQ3NzAxMn5-MTQ1NDU0NDA4MzAyM345SjlWTi9BaE9SWnNyODhyUXdPbm1qNHV-UH4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTQ3NzAxMiZzaWc9NGMxNjMwZTg4OGE3Yjg5Nzg5NzA0ZTlhMGE5ZTE2ZDQ4NTdkZTVjMDpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTJfTVg0ME5UUTNOekF4TW41LU1UUTFORFUwTkRBNE16QXlNMzQ1U2psV1RpOUJhRTlTV25OeU9EaHlVWGRQYm0xcU5IVi1VSDQmY3JlYXRlX3RpbWU9MTQ1NDU0NDA5NiZub25jZT0wLjg5MDM2NzM1ODg5NjE1NjQmZXhwaXJlX3RpbWU9MTQ1NzEzNjA3OCZjb25uZWN0aW9uX2RhdGE9";
// ===============================================================================================//
static NSString* const kTextChatType = @"TextChat";


@implementation ViewController {
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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{
    
    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20 + kbSize.height;
    _textChat.view.frame = r;
  }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView animateWithDuration:duration animations:^{
    
    CGRect r = self.view.bounds;
    r.origin.y += 20;
    r.size.height -= 20;
    _textChat.view.frame = r;
    
  }];
}

- (BOOL)onMessageReadyToSend:(TextChatComponentMessage *)message {
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
  _textChat = [[TextChatComponent alloc] init];

  _textChat.delegate = self;
  
  [_textChat setMaxLength:1050];
  [_textChat setSenderId:session.connection.connectionId alias:session.connection.data];
  
  CGRect r = self.view.bounds;
  r.origin.y += 20;
  r.size.height -= 20;
  [_textChat.view setFrame:r];
  [self.view addSubview:_textChat.view];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  // fade in
  _textChat.view.alpha = 0;
  
  [UIView animateWithDuration:0.5 animations:^() {
    _connectingLabel.alpha = 0;
    _textChat.view.alpha = 1;
  }];
  
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
    TextChatComponentMessage *msg = [[TextChatComponentMessage alloc]init];
    msg.senderAlias = connection.data;
    msg.senderId = connection.connectionId;
    msg.text = string;
    [self.textChat addMessage:msg];
  }
}


@end
