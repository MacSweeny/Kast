//
//  KFItem.m
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import "KFItem.h"

@implementation KFItem

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.guid = [dict objectForKey:@"guid"];
        self.title = [dict objectForKey:@"title"];
        self.pubDate = [dict objectForKey:@"pubDate"];
        self.link = [dict objectForKey:@"link"];
        self.itemDescription = [dict objectForKey:@"description"];
        NSDictionary *enclosureDict = [dict objectForKey:@"enclosure"];
        if ([enclosureDict count] > 0) {
            self.enclosure = [[KFEnclosure alloc] initWithDictionary:enclosureDict];
        }
    }
    return self;
}

@end
