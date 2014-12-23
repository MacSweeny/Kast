//
//  KFFeedParser.m
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

#import "KFFeedParser.h"

#import "KFItem.h"

@interface KFXMLElement : NSObject

@property (copy, nonatomic) NSString *elementName;
@property (strong, nonatomic) NSMutableDictionary *scope;
@property (strong, nonatomic) NSDictionary *attributes;
@property (strong, nonatomic) NSMutableString *text;

- (id)initWithElementName:(NSString *)elementName;

@end

@implementation KFXMLElement

- (id)initWithElementName:(NSString *)elementName {
    if (self = [super init]) {
        self.elementName = elementName;
    }
    return self;
}

- (BOOL)hasChildren {
    return _scope != nil && [_scope count] > 0;
}

- (NSMutableDictionary *)scope {
    if (!_scope) {
        _scope = [NSMutableDictionary new];
    }
    return _scope;
}

- (NSMutableString *)text {
    if (!_text) {
        _text = [NSMutableString new];
    }
    return _text;
}

@end

@interface KFFeedParser()

@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSMutableArray *elementStack;
@property (readonly) KFXMLElement *headElement;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSDictionary *root;

@end

@implementation KFFeedParser

- (id)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (BOOL)parse {
    self.elementStack = [NSMutableArray new];
    
    if (self.url) {
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
    } else {
        self.parser = [[NSXMLParser alloc] initWithData:self.data];
    }
    
//    [self.parser setShouldResolveExternalEntities:NO];
    [self.parser setDelegate:self];
    BOOL success = [self.parser parse];
    if (!success) {
        NSLog(@"%@", self.parser.parserError);
    }
    return success;
}

#pragma mark - NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error: %@", parseError);
    [parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"did start elementName: %@", elementName);
    if (elementName) {
        KFXMLElement *element = [[KFXMLElement alloc] initWithElementName:elementName];
        if ([attributeDict count] > 0) {
            element.attributes = [attributeDict copy];
        }
        [self pushXMLElement:element];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"foundCharacters");
    if (self.headElement) {
        [self.headElement.text appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSLog(@"foundCDATA");
    if (self.headElement) {
        NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        [self.headElement.text appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"did start elementName: %@", elementName);

    KFXMLElement *element = [self popXMLElement];
    if (element) {
        if (self.headElement) {
            if ([element hasChildren]) {
                [self.headElement.scope setObject:element.scope forKey:elementName];
            } else {
                if ([element.text length] > 0) {
                    [self.headElement.scope setObject:element.text forKey:element.elementName];
                } else if ([element.attributes count] > 0) {
                    [self.headElement.scope setObject:element.attributes forKey:element.elementName];
                }
            }
        } else {
            self.root = element.scope;
        }
        
        [self evaluateXMLElement:element];
    }
}

- (void)evaluateXMLElement:(KFXMLElement *)element {
    if ([element.elementName isEqualToString:@"item"]) {
        KFItem *item = [[KFItem alloc] initWithDictionary:element.scope];
        [self.items addObject:item];
    } else if ([element.elementName isEqualToString:@"channel"]) {
        _channel = [[KFChannel alloc] initWithDictionary:element.scope items:self.items];
    }
}

#pragma mark - Stack Methods

- (KFXMLElement *)headElement {
    return [self.elementStack lastObject];
}

- (void)pushXMLElement:(KFXMLElement *)element {
    [self.elementStack addObject:element];
}

- (KFXMLElement *)popXMLElement {
    KFXMLElement *element = [self.elementStack lastObject];
    if (element) {
        [self.elementStack removeLastObject];
    }
    return element;
}

#pragma mark - Getters

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

@end
