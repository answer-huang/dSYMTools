//
//  AppDelegate.m
//  DSYMTools
//
//  Created by answer on 7/25/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowViewController.h"

@interface AppDelegate ()


@property (strong) MainWindowViewController *mainWindowViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.mainWindowViewController = [[MainWindowViewController alloc] initWithWindowNibName:@"MainWindowViewController"];
    [self.mainWindowViewController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/**
 *  关闭最后一个 window 的时候关闭应用
 *
 *  @param sender
 *
 *  @return
 */
//- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
//    return YES;
//}

/**
 *  监听窗口关闭的通知，关闭程序。
 *
 *  @param notification 
 */
//- (void) receiveWindowWillCloseMsg:(NSNotification *)notification{
//    NSWindow *window = notification.object;
//    if(window == self.window){
//        [NSApp terminate:self];
//    }
//}

//- (IBAction)openFilePanel:(id)sender {
//    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
//    openDlg.canChooseFiles = YES;
//    openDlg.canChooseDirectories = YES;
//    openDlg.allowsMultipleSelection = YES;
//    openDlg.allowedFileTypes = @[@"txt"];
//    [openDlg beginWithCompletionHandler:^(NSInteger result) {
//        if (result == NSFileHandlingPanelOKButton) {
//            NSArray *fileURLs = [openDlg URLs];
//            for (NSURL *url in fileURLs) {
//                NSError *error;
//                NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//                if (!error) {
//                    self.textView.string = string;
//                }
//            }
//        }
//    }];
//    
//}
//
//- (IBAction)saveFileAction:(id)sender {
//    NSSavePanel *saveDlg = [[NSSavePanel alloc]init];
//    saveDlg.title = @"Save File";
//    saveDlg.message = @"Save My File";
//    saveDlg.allowedFileTypes = @[@"txt"];
//    saveDlg.nameFieldStringValue = @"my";
//    [saveDlg beginWithCompletionHandler: ^(NSInteger result){
//        if(result==NSFileHandlingPanelOKButton){
//            NSURL  *url =[saveDlg URL];
//            NSLog(@"filePath url%@",url);
//            NSString *text = self.textView.string;
//            NSError *error;
//            [text writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
//            if(error){
//                NSLog(@"save file error %@",error);
//            }
//        }
//    }];
//}


@end
