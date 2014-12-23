//
//  KFItem.h
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KFEnclosure.h"

@interface KFItem : NSObject

@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *pubDate;
@property (copy, nonatomic) NSString *link;
@property (copy, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) KFEnclosure *enclosure;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
