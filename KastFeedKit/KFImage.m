//
//  KFImage.m
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import "KFImage.h"

@implementation KFImage

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.url = [dict objectForKey:@"url"];
        self.title = [dict objectForKey:@"title"];
        self.link = [dict objectForKey:@"link"];
    }
    return self;
}

@end
