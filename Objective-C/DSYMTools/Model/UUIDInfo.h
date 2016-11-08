//
//  UUIDInfo.h
//  DSYMTools
//
//  Created by answer on 7/27/16.
//  Copyright © 2016 answer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUIDInfo : NSObject

/**
 *  arch 类型
 */
@property (nonatomic, copy) NSString *arch;

/**
 * 默认的 Slide Address
 */
@property (nonatomic, readonly) NSString *defaultSlideAddress;

/**
 *  uuid 值
 */
@property (nonatomic, copy) NSString *uuid;

/**
 *  可执行文件路径
 */
@property (nonatomic, copy) NSString *executableFilePath;

@end
