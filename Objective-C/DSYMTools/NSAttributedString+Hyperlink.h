//
//  NSAttributedString+Hyperlink.h
//  DSYMTools
//
//  Created by answer on 2016/11/8.
//  Copyright © 2016年 answer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Hyperlink)

+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;

@end
