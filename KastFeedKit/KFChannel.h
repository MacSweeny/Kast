//
//  KFChannel.h
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KFImage.h"

@interface KFChannel : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *link;
@property (strong, nonatomic) KFImage *image;
@property (strong, nonatomic) NSArray *items;

- (id)initWithDictionary:(NSDictionary *)dict items:(NSArray *)items;

@end
