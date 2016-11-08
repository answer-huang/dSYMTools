//
//  CustomModalWindowViewController.m
//  CustomModalWindow
//
//  Created by Nick Kuh on 16/01/2015.
//  Copyright (c) 2015 Mumbo Apps Ltd. All rights reserved.
//

#import "CustomModalWindowController.h"

@interface CustomModalWindowController ()
@property (weak) IBOutlet NSTextField *label1;

@end

@implementation CustomModalWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
}

- (IBAction)didTapCancelButton:(id)sender {
   [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (IBAction)didTapDoneButton:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

@end
