//
//  KFImage.h
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFImage : NSObject

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *link;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
