//
//  AppDelegate.m
//  CopyPasta
//
//  Created by Matt Lindsey on 2/10/15.
//  Copyright (c) 2015 m1001. All rights reserved.
//

#import "AppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

BOOL stripFormatting, stripSpatial = false;

CGEventRef copyPasta(CGEventTapProxy proxy, CGEventType type,  CGEventRef event, void *refcon) {
    
    CGKeyCode keycode;
    bool commandkey;
    
    CGEventFlags eventMask = CGEventGetFlags(event);
    keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    commandkey = (eventMask & kCGEventFlagMaskCommand) != 0;
    
    NSPasteboard *clipboard = [NSPasteboard generalPasteboard];
    NSString *data = [clipboard stringForType:NSPasteboardTypeString];
    NSData *cleaned = [data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *new_clean = [[NSString alloc] initWithData:cleaned encoding:NSASCIIStringEncoding];
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [new_clean componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    NSString *spatial_clean = [filteredArray componentsJoinedByString:@" "];
    
    if ((keycode == (CGKeyCode)9) && commandkey) {
        if (stripFormatting) {
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] setString:new_clean  forType:NSStringPboardType];
        }
        
        if (stripSpatial) {
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] setString:spatial_clean  forType:NSStringPboardType];
        }
        
    }
    return event;
}


@interface AppDelegate ()
@end

@implementation AppDelegate

- (IBAction)stripFormatToggle:(id)sender {
    stripFormatting = !stripFormatting;
    if (stripFormatting ) {
        [sender setState:NSOnState];
    }
    else {
        [sender setState:NSOffState];
    }
}

- (IBAction)stripSpatialToggle:(id)sender {
    stripSpatial = !stripSpatial;
    if (stripSpatial ) {
        [sender setState:NSOnState];
    }
    else {
        [sender setState:NSOffState];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    
    if(!accessibilityEnabled) {
        // Exit
        return [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    }
    
    NSMenu* menuItem = [[NSMenu alloc] initWithTitle: @"CopyPasta"];
    
    NSMenuItem* menuItemQT = [[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"] autorelease];
    
    NSMenuItem* menuItemSF = [[NSMenuItem alloc]
                               initWithTitle:@"Strip Formatting" action: @selector(stripFormatToggle:)
                              keyEquivalent:@"f"];
    
    NSMenuItem* menuItemSS = [[NSMenuItem alloc]
                              initWithTitle:@"Strip Spatial" action:@selector(stripSpatialToggle:) keyEquivalent:@"s"];
    
    [menuItem insertItem:menuItemSF atIndex: 0];
    [menuItem insertItem:menuItemSS atIndex: 1];
    [menuItem insertItem:[NSMenuItem separatorItem] atIndex: 2];
    [menuItem insertItem:menuItemQT atIndex: 3];
    
    _statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES];
    [_statusItem setTitle: @"CP"];
    [_statusItem setEnabled:YES];
    [_statusItem setMenu: menuItem];
    
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, kCGEventMaskForAllEvents, &copyPasta, NULL);
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRunLoopRun();
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [_statusItem setEnabled:NO];
}

@end
