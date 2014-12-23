//
//  KFEnclosure.h
//  Kast
//
//  Created by Andy Sweeny on 12/19/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFEnclosure : NSObject

@property (strong, nonatomic) NSNumber *length;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *urlString;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
