//
//  KastFeedKitTests.m
//  KastFeedKitTests
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "KFFeedParser.h"

@interface KastFeedKitTests : XCTestCase

@end

@implementation KastFeedKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSBundle *testBundle = [NSBundle bundleWithIdentifier:@"com.misoapps.KastFeedKitTests"];
    NSString *path = [testBundle pathForResource:@"rss" ofType:@"xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    KFFeedParser *parser = [[KFFeedParser alloc] initWithData:data];
    [parser parse];
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
