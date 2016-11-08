//
//  ArchiveInfo.h
//  DSYMTools
//
//  Created by answer on 7/27/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@end
