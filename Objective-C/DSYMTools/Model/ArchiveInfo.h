//
//  ArchiveInfo.h
//  DSYMTools
//
//  Created by answer on 7/27/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 文件类型
 */
typedef NS_ENUM(NSInteger, ArchiveFileType){
    // archive 文件
    ArchiveFileTypeXCARCHIVE = 1,
    //dsym 文件
    ArchiveFileTypeDSYM = 2
};

@class UUIDInfo;

@interface ArchiveInfo : NSObject

/**
 *  dSYM 路径
 */
@property (copy) NSString *dSYMFilePath;

/**
 * dSYM 文件名
 */
@property (copy) NSString *dSYMFileName;

/**
 * archive 文件名
 */
@property (copy) NSString *archiveFileName;

/**
 * archive 文件路径
 */
@property (copy) NSString *archiveFilePath;

/**
 * uuids
 */
@property (copy) NSArray<UUIDInfo *> *uuidInfos;

/**
 * 文件类型
 */
@property (assign) ArchiveFileType archiveFileType;

@end
