//
//  MainWindowViewController.m
//  CustomModalWindow
//
//  Created by answer on 7/26/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import "MainWindowViewController.h"
#import "AboutWindowController.h"
#import "ArchiveInfo.h"
#import "UUIDInfo.h"
#import "ArchiveFilesScrollView.h"


@interface MainWindowViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSDraggingDestination>


@property (strong) AboutWindowController *aboutWindowController;

/**
 *  显示 archive 文件的 tableView
 */
@property (weak) IBOutlet NSTableView *archiveFilesTableView;

/**
 *  存放 radio 的 box
 */
@property (weak) IBOutlet NSBox *radioBox;

/**
 *  archive 文件信息数组
 */
@property (copy) NSMutableArray<ArchiveInfo *> *archiveFilesInfo;

/**
 *  选中的 archive 文件信息
 */
@property (strong) ArchiveInfo *selectedArchiveInfo;

/**
 * 选中的 UUID 信息
 */
@property (strong) UUIDInfo *selectedUUIDInfo;

/**
 *  显示选中的 CPU 类型对应可执行文件的 UUID
 */
@property (weak) IBOutlet NSTextField *selectedUUIDLabel;

/**
 *  显示默认的 Slide Address
 */
@property (weak) IBOutlet NSTextField *defaultSlideAddressLabel;

/**
 *  显示错误内存地址
 */
@property (weak) IBOutlet NSTextField *errorMemoryAddressLabel;

/**
 *  错误信息
 */
@property (unsafe_unretained) IBOutlet NSTextView *errorMessageView;



@property (weak) IBOutlet ArchiveFilesScrollView *archiveFilesScrollView;

@end

@implementation MainWindowViewController


- (void)windowDidLoad{
    [super windowDidLoad];
    
    [self.window registerForDraggedTypes:@[NSColorPboardType, NSFilenamesPboardType]];
    
    self.archiveFilesTableView.doubleAction = @selector(doubleActionMethod);

    NSArray *archiveFilePaths = [self allDSYMFilePath];
    [self handleArchiveFileWithPath:archiveFilePaths];
}

/**
 *  处理给定archive文件路径，获取 archiveinfo 对象
 *
 *  @param filePaths archvie 文件路径
 */
- (void)handleArchiveFileWithPath:(NSArray *)filePaths {
    _archiveFilesInfo = [NSMutableArray arrayWithCapacity:1];
    for(NSString *filePath in filePaths){
        ArchiveInfo *archiveInfo = [[ArchiveInfo alloc] init];

        NSString *fileName = filePath.lastPathComponent;
        //支持 xcarchive 文件和 dSYM 文件。
        if ([fileName hasSuffix:@".xcarchive"]){
            archiveInfo.archiveFilePath = filePath;
            archiveInfo.archiveFileName = fileName;
            archiveInfo.archiveFileType = ArchiveFileTypeXCARCHIVE;
            [self formatArchiveInfo:archiveInfo];
        }else if([fileName hasSuffix:@".app.dSYM"]){
            archiveInfo.dSYMFilePath = filePath;
            archiveInfo.dSYMFileName = fileName;
            archiveInfo.archiveFileType = ArchiveFileTypeDSYM;
            [self formatDSYM:archiveInfo];
        }else{
            continue;
        }

        [_archiveFilesInfo addObject:archiveInfo];
    }

    [self.archiveFilesTableView reloadData];
}

/**
 *  从 archive 文件中获取 dsym 文件信息
 *
 *  @param archiveInfo archive info 对象
 */
- (void)formatArchiveInfo:(ArchiveInfo *)archiveInfo{
    NSString *dSYMsDirectoryPath = [NSString stringWithFormat:@"%@/dSYMs", archiveInfo.archiveFilePath];
    NSArray *keys = @[@"NSURLPathKey",@"NSURLFileResourceTypeKey",@"NSURLIsDirectoryKey",@"NSURLIsPackageKey"];
    NSArray *dSYMSubFiles= [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:dSYMsDirectoryPath] includingPropertiesForKeys:keys options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants) error:nil];
    for(NSURL *fileURLs in dSYMSubFiles){
        if ([[fileURLs.relativePath lastPathComponent] hasSuffix:@"app.dSYM"]){
            archiveInfo.dSYMFilePath = fileURLs.relativePath;
            archiveInfo.dSYMFileName = fileURLs.relativePath.lastPathComponent;
        }
    }
    [self formatDSYM:archiveInfo];

}

/**
 * 根据 dSYM 文件获取 UUIDS。
 * @param archiveInfo
 */
- (void)formatDSYM:(ArchiveInfo *)archiveInfo{
    //匹配 () 里面内容
    NSString *pattern = @"(?<=\\()[^}]*(?=\\))";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *commandString = [NSString stringWithFormat:@"dwarfdump --uuid \"%@\"",archiveInfo.dSYMFilePath];
    NSString *uuidsString = [self runCommand:commandString];
    NSArray *uuids = [uuidsString componentsSeparatedByString:@"\n"];

    NSMutableArray *uuidInfos = [NSMutableArray arrayWithCapacity:1];
    for(NSString *uuidString in uuids){
        NSArray* match = [reg matchesInString:uuidString options:NSMatchingReportCompletion range:NSMakeRange(0, [uuidString length])];
        if (match.count == 0) {
            continue;
        }
        for (NSTextCheckingResult *result in match) {
            NSRange range = [result range];
            UUIDInfo *uuidInfo = [[UUIDInfo alloc] init];
            uuidInfo.arch = [uuidString substringWithRange:range];
            uuidInfo.uuid = [uuidString substringWithRange:NSMakeRange(6, range.location-6-2)];
            uuidInfo.executableFilePath = [uuidString substringWithRange:NSMakeRange(range.location+range.length+2, [uuidString length]-(range.location+range.length+2))];
            [uuidInfos addObject:uuidInfo];
        }
        archiveInfo.uuidInfos = uuidInfos;
    }
}

/**
 * 获取所有 dSYM 文件目录.
 */
- (NSMutableArray *)allDSYMFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *archivesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/Xcode/Archives/"];
    NSURL *bundleURL = [NSURL fileURLWithPath:archivesPath];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
    {
        if (error) {
            NSLog(@"[Error] %@ (%@)", error, url);
            return NO;
        }

        return YES;
    }];

    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];

        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }

        //TODO:过滤部分没必要遍历的目录

        if ([filename hasSuffix:@".xcarchive"] && [isDirectory boolValue]){
            [mutableFileURLs addObject:fileURL.relativePath];
            [enumerator skipDescendants];
        }
    }
    return mutableFileURLs;
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = @[@"-c",
            [NSString stringWithFormat:@"%@", commandToRun]];
//    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}


/**
 * 导出 ipa 文件
   xcodebuild -exportArchive -exportFormat ipa -archivePath "/path/to/archiveFile" -exportPath "/path/to/ipaFile"
 */
- (IBAction)exportIPA:(id)sender {
    if(!_selectedArchiveInfo){
        NSLog(@"还未选中 archive 文件");
        return;
    }

    if(_selectedArchiveInfo.archiveFileType == ArchiveFileTypeDSYM){
        NSLog(@"archive 文件才可导出 ipa 文件");
        return;
    }


    NSString *ipaFileName = [_selectedArchiveInfo.archiveFileName stringByReplacingOccurrencesOfString:@"xcarchive" withString:@"ipa"];
    
    NSSavePanel *saveDlg = [[NSSavePanel alloc]init];
    saveDlg.title = ipaFileName;
    saveDlg.message = @"Save My File";
    saveDlg.allowedFileTypes = @[@"ipa"];
    saveDlg.nameFieldStringValue = ipaFileName;
    [saveDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton){
            NSURL  *url =[saveDlg URL];
            NSLog(@"filePath url%@",url);
            NSString *exportCmd = [NSString stringWithFormat:@"/usr/bin/xcodebuild -exportArchive -exportFormat ipa -archivePath \"%@\" -exportPath \"%@\"", _selectedArchiveInfo.archiveFilePath, url.relativePath];
            [self runCommand:exportCmd];
        }
    }];
}


- (IBAction)aboutMe:(id)sender {
    self.aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    [self.window beginSheet:self.aboutWindowController.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                NSLog(@"Done button tapped in Custom Sheet");
                break;
            case NSModalResponseCancel:
                NSLog(@"Cancel button tapped in Custom Sheet");
                break;
                
            default:
                break;
        }
        self.aboutWindowController = nil;
    }];
}

#pragma mark - NSTableViewDataSources
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_archiveFilesInfo count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    ArchiveInfo *archiveInfo= _archiveFilesInfo[row];
    if(archiveInfo.archiveFileType == ArchiveFileTypeXCARCHIVE){
        return archiveInfo.archiveFileName;
    }else if(archiveInfo.archiveFileType == ArchiveFileTypeDSYM){
        return archiveInfo.dSYMFileName;
    }
    return archiveInfo.archiveFileName;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{

    ArchiveInfo *archiveInfo= _archiveFilesInfo[row];
    NSString *identifier = tableColumn.identifier;
    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    NSArray *subviews = view.subviews;
    if (subviews.count > 0) {
        if ([identifier isEqualToString:@"name"]) {
            NSTextField *textField = subviews[0];
            if(archiveInfo.archiveFileType == ArchiveFileTypeXCARCHIVE){
                textField.stringValue = archiveInfo.archiveFileName;
            }else if(archiveInfo.archiveFileType == ArchiveFileTypeDSYM){
                textField.stringValue = archiveInfo.dSYMFileName;
            }
        }
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [notification.object selectedRow];
    _selectedArchiveInfo= _archiveFilesInfo[row];
    [self resetPreInformation];

    CGFloat radioButtonWidth = CGRectGetWidth(self.radioBox.contentView.frame);
    CGFloat radioButtonHeight = 18;
    [_selectedArchiveInfo.uuidInfos enumerateObjectsUsingBlock:^(UUIDInfo *uuidInfo, NSUInteger idx, BOOL *stop) {
        CGFloat space = (CGRectGetHeight(self.radioBox.contentView.frame) - _selectedArchiveInfo.uuidInfos.count * radioButtonHeight) / (_selectedArchiveInfo.uuidInfos.count + 1);
        CGFloat y = space * (idx + 1) + idx * radioButtonHeight;
        NSButton *radioButton = [[NSButton alloc] initWithFrame:NSMakeRect(10,y,radioButtonWidth,radioButtonHeight)];
        [radioButton setButtonType:NSRadioButton];
        [radioButton setTitle:uuidInfo.arch];
        radioButton.tag = idx + 1;
        [radioButton setAction:@selector(radioButtonAction:)];
        [self.radioBox.contentView addSubview:radioButton];
    }];
}

/**
 * 重置之前显示的信息
 */
- (void)resetPreInformation {
    [self.radioBox.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _selectedUUIDInfo = nil;
    self.selectedUUIDLabel.stringValue = @"";
    self.defaultSlideAddressLabel.stringValue = @"";
    self.errorMemoryAddressLabel.stringValue = @"";
    [self.errorMessageView setString:@""];
}

- (void)radioButtonAction:(id)sender{
    NSButton *radioButton = sender;
    NSInteger tag = radioButton.tag;
    _selectedUUIDInfo = _selectedArchiveInfo.uuidInfos[tag - 1];
    _selectedUUIDLabel.stringValue = _selectedUUIDInfo.uuid;
    _defaultSlideAddressLabel.stringValue = _selectedUUIDInfo.defaultSlideAddress;
}

- (void)doubleActionMethod{
    NSLog(@"double action");
}

- (IBAction)analyse:(id)sender {
    if(self.selectedArchiveInfo == nil){
        return;
    }

    if(self.selectedUUIDInfo == nil){
        return;
    }

    if([self.defaultSlideAddressLabel.stringValue isEqualToString:@""]){
        return;
    }

    if([self.errorMemoryAddressLabel.stringValue isEqualToString:@""]){
        return;
    }

    NSString *commandString = [NSString stringWithFormat:@"xcrun atos -arch %@ -o \"%@\" -l %@ %@", self.selectedUUIDInfo.arch, self.selectedUUIDInfo.executableFilePath, self.defaultSlideAddressLabel.stringValue, self.errorMemoryAddressLabel.stringValue];
    NSString *result = [self runCommand:commandString];
    [self.errorMessageView setString:result];
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{

    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;

    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{

}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSLog(@"%@",fileURL);
    }

    if([[pboard types] containsObject:NSFilenamesPboardType]){
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray *archiveFilePaths = [NSMutableArray arrayWithCapacity:1];
        for(NSString *filePath in files){
            if([filePath.pathExtension isEqualToString:@"xcarchive"]){
                NSLog(@"%@", filePath);
                [archiveFilePaths addObject:filePath];
            }

            if([filePath.pathExtension isEqualToString:@"dSYM"]){
                [archiveFilePaths addObject:filePath];
            }
        }
        
        if(archiveFilePaths.count == 0){
            NSLog(@"没有包含任何 xcarchive 文件");
            return NO;
        }
        
        [self resetPreInformation];

        [self handleArchiveFileWithPath:archiveFilePaths];

        
    }

    return YES;
}

@end
