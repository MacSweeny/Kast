//
//  KFChannel.m
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import "KFChannel.h"

@implementation KFChannel

- (id)initWithDictionary:(NSDictionary *)dict items:(NSArray *)items {
    if (self = [super init]) {
        self.title = [dict objectForKey:@"title"];
        self.link = [dict objectForKey:@"link"];
        NSDictionary *imageDict = [dict objectForKey:@"image"];
        if (imageDict) {
            self.image = [[KFImage alloc] initWithDictionary:imageDict];
        }
        self.items = items;
    }
    return self;
}

@end
