//
//  NSString+VJUUID.h
//  ZSSRichTextEditor
//
//  Created by 侯卫嘉 on 2019/6/21.
//  Copyright © 2019 Zed Said Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (VJUUID)

+ (NSString *)uuid;
- (id)jsonObject;

@end

NS_ASSUME_NONNULL_END
