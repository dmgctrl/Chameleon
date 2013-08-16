/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIPasteboard.h>
#import <UIKit/UIImage+AppKit.h>
#import <UIKit/UIColor+AppKit.h>
#import <AppKit/AppKit.h>

static id FirstObjectOrNil(NSArray* items)
{
    return ([items count] > 0)? [items objectAtIndex:0] : nil;
}

static BOOL IsUIPasteboardPropertyListType(id object)
{
    return [object isKindOfClass:[NSString class]] ||
    [object isKindOfClass:[NSArray class]] ||
    [object isKindOfClass:[NSDictionary class]] ||
    [object isKindOfClass:[NSDate class]] ||
    [object isKindOfClass:[NSNumber class]] ||
    [object isKindOfClass:[NSURL class]];
}

static NSPasteboardItem* PasteBoardItemWithDictionary(NSDictionary* item)
{
    NSPasteboardItem* pasteboardItem = [[NSPasteboardItem alloc] init];

    for (NSString* type in [item allKeys]) {
        id object = [item objectForKey:type];

        if ([object isKindOfClass:[NSData class]]) {
            if (UTTypeEqual((__bridge CFStringRef)type, kUTTypeGIF)) {
                NSFileWrapper* fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:object];
                [fileWrapper setPreferredFilename:@"image.gif"];
                NSTextAttachment* attachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
                NSAttributedString* str = [NSAttributedString attributedStringWithAttachment:attachment];
                [pasteboardItem setData:[str RTFDFromRange:NSMakeRange(0, [str length]) documentAttributes:nil] forType:(NSString *)kUTTypeFlatRTFD];
            }
            [pasteboardItem setData:object forType:type];
        } else if ([object isKindOfClass:[NSURL class]]) {
            [pasteboardItem setString:[object absoluteString] forType:type];
        } else {
            [pasteboardItem setPropertyList:object forType:type];
        }
    }
    return pasteboardItem;
}

@implementation UIPasteboard {
    NSPasteboard* pasteboard;
}

- (id) initWithPasteboard:(NSPasteboard*)aPasteboard
{
    if ((self=[super init])) {
        pasteboard = aPasteboard;
    }
    return self;
}


#pragma mark Getting and Removing Pasteboards

+ (UIPasteboard*) generalPasteboard
{
    static UIPasteboard* aPasteboard = nil;
    if (!aPasteboard) {
        aPasteboard = [[UIPasteboard alloc] initWithPasteboard:[NSPasteboard generalPasteboard]];
    }
    return aPasteboard;
}

+ (UIPasteboard*) pasteboardWithName:(NSString*)pasteboardName create:(BOOL)create
{
#warning implement +pasteboardWithUniqueName
    UIKIT_STUB_W_RETURN(@"+pasteboardWithName:create:");
}

+ (UIPasteboard*) pasteboardWithUniqueName
{
#warning implement +pasteboardWithUniqueName
    UIKIT_STUB_W_RETURN(@"+pasteboardWithUniqueName");
}

+ (void) removePasteboardWithName:(NSString*)pasteboardName
{
#warning implement +removePasteboardWithName:
    UIKIT_STUB(@"+removePasteboardWithName:");
}


#pragma mark Determining Types of Single Pasteboard Items

- (NSArray*) pasteboardTypes
{
#warning implement -pasteboardTypes
    UIKIT_STUB_W_RETURN(@"-pasteboardTypes");
}

- (BOOL) containsPasteboardTypes:(NSArray*)pasteboardTypes
{
#warning implement -containsPasteboardTypes:
    UIKIT_STUB_W_RETURN(@"-containsPasteboardTypes:");
}


#pragma mark Getting and Setting Single Pasteboard Items

- (NSData*) dataForPasteboardType:(NSString*)pasteboardType
{
#warning implement -dataForPasteboardType:
    UIKIT_STUB_W_RETURN(@"-dataForPasteboardType:");
}

- (id) valueForPasteboardType:(NSString*)pasteboardType
{
#warning implement -valueForPasteboardType:
    UIKIT_STUB_W_RETURN(@"-valueForPasteboardType:");
}

- (void) setData:(NSData*)data forPasteboardType:(NSString*)pasteboardType
{
    if (data && pasteboardType) {
        [pasteboard clearContents];
        [pasteboard writeObjects:@[PasteBoardItemWithDictionary(@{ pasteboardType: data })]];
    }
}

- (void) setValue:(id)value forPasteboardType:(NSString*)pasteboardType
{
    if (pasteboardType && IsUIPasteboardPropertyListType(value)) {
        [pasteboard clearContents];
        [pasteboard writeObjects:@[PasteBoardItemWithDictionary(@{ pasteboardType: value })]];
    }
}


#pragma mark Determining the Types of Multiple Pasteboard Items

- (NSArray*) pasteboardTypesForItemSet:(NSIndexSet*)itemSet
{
#warning implement -pasteboardTypesForItemSet:
    UIKIT_STUB_W_RETURN(@"-pasteboardTypesForItemSet:");
}

- (NSIndexSet*) itemSetWithPasteboardTypes:(NSArray*)pasteboardTypes
{
#warning implement -itemSetWithPasteboardTypes:
    UIKIT_STUB_W_RETURN(@"-itemSetWithPasteboardTypes:");
}

- (BOOL) containsPasteboardTypes:(NSArray*)pasteboardTypes inItemSet:(NSIndexSet*)itemSet
{
#warning implement -containsPasteboardTypes:inItemSet:
    UIKIT_STUB_W_RETURN(@"-containsPasteboardTypes:inItemSet:");
}


#pragma mark Getting and Setting Multiple Pasteboard Items

// there's a good chance this won't work correctly for all cases and indeed it's very untested in its current incarnation
- (NSArray*) items
{
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:0];
    for (NSPasteboardItem* item in [pasteboard pasteboardItems]) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
        for (NSString* type in [item types]) {
            id object = nil;
            if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
                object = [NSURL URLWithString:[item stringForType:type]];
            } else {
                object = [item propertyListForType:type] ?: [item dataForType:type];
            }
            if (object) {
                [dict setObject:object forKey:type];
            }
        }
        if ([dict count] > 0) {
            [items addObject:dict];
        }
    }
    return items;
}

- (void) setItems:(NSArray*)items
{
    [pasteboard clearContents];
    [self addItems:items];
}

- (NSArray*) dataForPasteboardType:(NSString*)pasteboardType inItemSet:(NSIndexSet*)itemSet
{
#warning implement -dataForPasteboardType:inItemSet:
    UIKIT_STUB_W_RETURN(@"-dataForPasteboardType:inItemSet:");
}

- (NSArray*) valuesForPasteboardType:(NSString*)pasteboardType inItemSet:(NSIndexSet*)itemSet
{
#warning implement -valuesForPasteboardType:inItemSet:
    UIKIT_STUB_W_RETURN(@"-valuesForPasteboardType:inItemSet:");
}

- (void) addItems:(NSArray*)items
{
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity:[items count]];
    for (NSDictionary* item in items) {
        [objects addObject:PasteBoardItemWithDictionary(item)];
    }
    [pasteboard writeObjects:objects];
}


#pragma mark Getting and Setting Pasteboard Items of Standard Data Types

- (NSString*) string
{
    return FirstObjectOrNil([self strings]);
}

- (void) setString:(NSString*)aString
{
    [self setStrings:@[aString]];
}

- (NSArray*) strings
{
    return [self _objectsWithClasses:@[[NSString class]]];
}

- (void) setStrings:(NSArray*)strings
{
    [self _writeObjects:strings];
}

- (UIImage*) image
{
    return FirstObjectOrNil([self images]);
}

- (void) setImage:(UIImage*)anImage
{
    [self setImages:@[anImage]];
}

- (NSArray*) images
{
    NSArray* rawImages = [self _objectsWithClasses:@[[NSImage class]]];
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:[rawImages count]];
    for (NSImage* image in rawImages) {
        [images addObject:[[UIImage alloc] initWithNSImage:image]];
    }
    return images;
}

- (void) setImages:(NSArray*)images
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[images count]];
    for (UIImage *image in images) {
        [items addObject:[image NSImage]];
    }
    [self _writeObjects:items];
}

- (NSURL*) URL
{
    return FirstObjectOrNil([self URLs]);
}

- (void)setURL:(NSURL*) aURL
{
    [self setURLs:@[aURL]];
}

- (NSArray*) URLs
{
    return [self _objectsWithClasses:@[[NSURL class]]];
}

- (void) setURLs:(NSArray*)items
{
    [self _writeObjects:items];
}

- (UIColor*) color
{
    return FirstObjectOrNil([self colors]);
}

- (void) setColor:(UIColor*)aColor
{
    [self setColors:@[aColor]];
}

- (NSArray*) colors
{
    NSArray* rawColors = [self _objectsWithClasses:@[[NSColor class]]];
    NSMutableArray* colors = [NSMutableArray arrayWithCapacity:[rawColors count]];
    for (NSColor* color in rawColors) {
        [colors addObject:[[UIColor alloc] initWithNSColor:color]];
    }
    return colors;
}

- (void) setColors:(NSArray*)colors
{
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:[colors count]];
    for (UIColor* color in colors) {
        [items addObject:[color NSColor]];
    }
    [self _writeObjects:items];
}


#pragma mark private methods

- (void) _writeObjects:(NSArray*)objects
{
    [pasteboard clearContents];
    [pasteboard writeObjects:objects];
}

- (id) _objectsWithClasses:(NSArray*)types
{
    return [pasteboard readObjectsForClasses:types options:@{}];
}



@end
