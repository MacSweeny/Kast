//
//  KFFeedParser.h
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KFChannel.h"

@interface KFFeedParser : NSObject <NSXMLParserDelegate>

@property (readonly) KFChannel *channel;

- (id)initWithData:(NSData *)data;

- (BOOL)parse;

@end
