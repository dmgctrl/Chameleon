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

#import <UIKit/UIScrollView.h>
#import <UIKit/UITableViewCell.h>
#import <UIKit/NSIndexPath+UITableView.h>

UIKIT_EXTERN NSString* const UITableViewIndexSearch;

@class UITableView;
@class UINib;
@class UITableViewHeaderFooterView;

@protocol UITableViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*) tableView:(UITableView*)tableView willDeselectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void) tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath;

- (CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat) tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section;
- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView*) tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section;

- (void) tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath;
- (void) tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*) tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath;

- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath;

@optional // AppKitIntegration
- (void) tableView:(UITableView*)tableView didDoubleClickRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@protocol UITableViewDataSource <NSObject>
@required
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
@optional
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView;
- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString*) tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section;

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
@end

#pragma mark Constants
typedef enum {
    UITableViewStylePlain,
    UITableViewStyleGrouped
} UITableViewStyle;

typedef enum {
    UITableViewScrollPositionNone,
    UITableViewScrollPositionTop,
    UITableViewScrollPositionMiddle,
    UITableViewScrollPositionBottom
} UITableViewScrollPosition;

typedef enum {
    UITableViewRowAnimationFade,
    UITableViewRowAnimationRight,
    UITableViewRowAnimationLeft,
    UITableViewRowAnimationTop,
    UITableViewRowAnimationBottom,
    UITableViewRowAnimationNone,
    UITableViewRowAnimationMiddle
} UITableViewRowAnimation;

@interface UITableView : UIScrollView <NSCoding>

#pragma mark Initializing a UITableView Object
- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

#pragma mark Configuring a Table View
@property (nonatomic, readonly) UITableViewStyle style;
- (NSInteger) numberOfRowsInSection:(NSInteger)section;
- (NSInteger) numberOfSections;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic, retain) UIColor *separatorColor;
@property (nonatomic, readwrite, retain) UIView *backgroundView;

#pragma mark Creating Table View Cells
- (void) registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)identifier;
- (void) registerClass:(Class)cellClass forCellReuseIdentifier:(NSString*)identifier;
- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath;
- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier;

#pragma mark Accessing Header and Footer Views
- (void) registerNib:(UINib*)nib forHeaderFooterViewReuseIdentifier:(NSString*)identifier;
- (void) registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString*)identifier;
- (id) dequeueReusableHeaderFooterViewWithIdentifier:(NSString*)identifier;
@property (nonatomic, retain) UIView *tableHeaderView;
@property (nonatomic, retain) UIView *tableFooterView;
@property (nonatomic) CGFloat sectionHeaderHeight;
@property (nonatomic) CGFloat sectionFooterHeight;
- (UITableViewHeaderFooterView*) headerViewForSection:(NSInteger)section;
- (UITableViewHeaderFooterView*) footerViewForSection:(NSInteger)section;

#pragma mark Accessing Cells and Sections
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*) indexPathForCell:(UITableViewCell*)cell;
- (NSIndexPath*) indexPathForRowAtPoint:(CGPoint)point;
- (NSArray*) indexPathsForRowsInRect:(CGRect)rect;
- (NSArray*) visibleCells;
- (NSArray*) indexPathsForVisibleRows;

#pragma mark Scrolling the Table View
- (void) scrollToRowAtIndexPath:(NSIndexPath*)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void) scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark Managing Selections
- (NSIndexPath*) indexPathForSelectedRow;
- (NSArray*) indexPathsForSelectedRows;
- (void) selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void) deselectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
@property (nonatomic) BOOL allowsSelection;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL allowsSelectionDuringEditing;
@property (nonatomic) BOOL allowsMultipleSelectionDuringEditing;

#pragma mark Inserting, Deleting, and Moving Rows and Sections
- (void) beginUpdates;
- (void) endUpdates;
- (void) insertRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void) moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath;
- (void) insertSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void) moveSection:(NSInteger)section toSection:(NSInteger)newSection;

#pragma mark Managing the Editing of Table Cells
@property (nonatomic, getter=isEditing) BOOL editing;
- (void) setEditing:(BOOL)editing animated:(BOOL)animate;

#pragma mark Reloading the Table View
- (void) reloadData;
- (void) reloadRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadSectionIndexTitles;

#pragma mark Accessing Drawing Areas of the Table View
- (CGRect) rectForSection:(NSInteger)section;
- (CGRect) rectForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGRect) rectForFooterInSection:(NSInteger)section;
- (CGRect) rectForHeaderInSection:(NSInteger)section;

#pragma mark Managing the Delegate and the Data Source
@property (nonatomic, assign) id<UITableViewDataSource> dataSource;
@property (nonatomic, assign) id<UITableViewDelegate> delegate;

#pragma mark Configuring the Table Index
@property (nonatomic) NSInteger sectionIndexMinimumDisplayRowCount;
@property (nonatomic, retain) UIColor* sectionIndexColor;
@property (nonatomic, retain) UIColor* sectionIndexTrackingBackgroundColor;

@end
