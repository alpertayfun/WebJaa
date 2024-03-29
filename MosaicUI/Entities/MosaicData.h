//
//  MosaicModule.h
//  MosaicUI
//
//  Created by Ezequiel Becerra on 10/21/12.
//  Copyright (c) 2012 betzerra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MosaicData : NSObject{
    NSString *imageFilename;
    NSString *title;
    NSString *information;
    NSInteger size;
    NSString *web;
}

-(id)initWithDictionary:(NSDictionary *)aDict;

@property (strong) NSString *imageFilename;
@property (strong) NSString *title;
@property (strong) NSString *information;
@property (readwrite) NSInteger size;
@property (strong) NSString *web;
@end
