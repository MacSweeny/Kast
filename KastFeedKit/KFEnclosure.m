//
//  KFEnclosure.m
//  Kast
//
//  Created by Andy Sweeny on 12/19/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import "KFEnclosure.h"

@implementation KFEnclosure

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.length = [dict objectForKey:@"length"];
        self.type = [dict objectForKey:@"type"];
        self.urlString = [dict objectForKey:@"url"];
    }
    return self;
}


@end
