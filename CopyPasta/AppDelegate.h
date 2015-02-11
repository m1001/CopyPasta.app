//
//  AppDelegate.h
//  CopyPasta
//
//  Created by Matt Lindsey on 2/10/15.
//  Copyright (c) 2015 m1001. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property BOOL stripFormatting;
@property BOOL stripSpatial;
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

