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

#import <Foundation/Foundation.h>

@class UIImage;
@class UIColor;

@interface UIPasteboard : NSObject

#pragma mark Getting and Removing Pasteboards

+ (UIPasteboard*) generalPasteboard;
+ (UIPasteboard*) pasteboardWithName:(NSString*)pasteboardName create:(BOOL)create;
+ (UIPasteboard*) pasteboardWithUniqueName;
+ (void) removePasteboardWithName:(NSString*)pasteboardName;


#pragma mark Getting and Setting Pasteboard Attributes

@property (readonly, nonatomic) NSString* name;
@property (getter=isPersistent, nonatomic) BOOL persistent;
@property (readonly, nonatomic) NSInteger changeCount;


#pragma mark Determining Types of Single Pasteboard Items

- (NSArray*) pasteboardTypes;
- (BOOL) containsPasteboardTypes:(NSArray*)pasteboardTypes;


#pragma mark Getting and Setting Single Pasteboard Items

- (NSData*) dataForPasteboardType:(NSString*)pasteboardType;
- (id) valueForPasteboardType:(NSString*)pasteboardType;
- (void) setData:(NSData*)data forPasteboardType:(NSString*)pasteboardType;
- (void) setValue:(id)value forPasteboardType:(NSString*)pasteboardType;


#pragma mark Determining the Types of Multiple Pasteboard Items

@property (readonly, nonatomic) NSInteger numberOfItems;
- (NSArray*) pasteboardTypesForItemSet:(NSIndexSet*)itemSet;
- (NSIndexSet*) itemSetWithPasteboardTypes:(NSArray*)pasteboardTypes;
- (BOOL) containsPasteboardTypes:(NSArray*)pasteboardTypes inItemSet:(NSIndexSet*)itemSet;


#pragma mark Getting and Setting Multiple Pasteboard Items

@property (nonatomic, copy) NSArray* items;
- (NSArray*) dataForPasteboardType:(NSString*)pasteboardType inItemSet:(NSIndexSet*)itemSet;
- (NSArray*) valuesForPasteboardType:(NSString*)pasteboardType inItemSet:(NSIndexSet*)itemSet;
- (void) addItems:(NSArray*)items;


#pragma mark Getting and Setting Pasteboard Items of Standard Data Types

@property (nonatomic, copy) NSString* string;
@property (nonatomic, copy) NSArray* strings;
@property (nonatomic, copy) UIImage* image;
@property (nonatomic, copy) NSArray* images;
@property (nonatomic, copy) NSURL* URL;
@property (nonatomic, copy) NSArray* URLs;
@property (nonatomic, copy) UIColor* color;
@property (nonatomic, copy) NSArray* colors;


@end
