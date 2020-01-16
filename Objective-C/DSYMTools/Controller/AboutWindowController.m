//
//  AboutWindowController.m
//  DSYMTools
//
//  Created by answer on 7/26/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import "AboutWindowController.h"
#import "NSAttributedString+Hyperlink.h"

@interface AboutWindowController ()
@property (weak) IBOutlet NSTextField *blog;

@property (weak) IBOutlet NSTextField *weibo;
@property (weak) IBOutlet NSTextField *gitHub;
@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.weibo setAllowsEditingTextAttributes:YES];
    [self.weibo setSelectable:YES];
    
    [self.blog setAllowsEditingTextAttributes:YES];
    [self.blog setSelectable:YES];
    
    [self.gitHub setAllowsEditingTextAttributes:YES];
    [self.gitHub setSelectable:YES];

    
    NSURL* url1 = [NSURL URLWithString:@"http://weibo.com/u/1623064627"];
    NSMutableAttributedString* string1 = [[NSMutableAttributedString alloc] init];
    [string1 appendAttributedString: [NSAttributedString hyperlinkFromString:@"answer-huang" withURL:url1]];
    [self.weibo setAttributedStringValue: string1];
    
    NSURL* url2 = [NSURL URLWithString:@"http://answerhuang.duapp.com"];
    NSMutableAttributedString* string2 = [[NSMutableAttributedString alloc] init];
    [string2 appendAttributedString: [NSAttributedString hyperlinkFromString:@"answerhuang.duapp.com" withURL:url2]];
    [self.blog setAttributedStringValue: string2];
    
    NSURL* url3 = [NSURL URLWithString:@"https://github.com/answer-huang/dSYMTools"];
    NSMutableAttributedString* string3 = [[NSMutableAttributedString alloc] init];
    [string3 appendAttributedString: [NSAttributedString hyperlinkFromString:@"dSYMTools" withURL:url3]];
    [self.gitHub setAttributedStringValue: string3];
}
- (IBAction)close:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

@end
