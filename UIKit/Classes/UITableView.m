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

#import <UIKit/UITableView.h>
#import <UIKit/UITableView+UIPrivate.h>
#import <UIKit/UITableViewCell+UIPrivate.h>
#import <UIKit/UIColor.h>
#import <UIKit/UITouch.h>
#import <UIKit/UITableViewSection.h>
#import <UIKit/UITableViewSectionLabel.h>
#import <UIKit/UIScreen+AppKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIKitView.h>
#import <UIKit/UIApplication+UIPrivate.h>
#import <UIKit/UIKey.h>
#import <UIKit/UIResponder+AppKit.h>
#import <UIKit/UITableView+AppKit.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSEvent.h>

NSString* const UITableViewIndexSearch = @"{search}";
const CGFloat _UITableViewDefaultRowHeight = 44;
static NSString* const kUIAllowsSelectionDuringEditingKey = @"UIAllowsSelectionDuringEditing";
static NSString* const kUIRowHeightKey = @"UIRowHeight";
static NSString* const kUISectionFooterHeightKey = @"UISectionFooterHeight";
static NSString* const kUISectionHeaderHeightKey = @"UISectionHeaderHeight";
static NSString* const kUISeparatorColorKey = @"UISeparatorColor";
static NSString* const kUISeparatorStyleKey = @"UISeparatorStyle";
static NSString* const kUIStyleKey = @"UIStyle";


@implementation UITableView {
    NSMutableDictionary* _cachedCells;
    NSMutableSet* _reusableCells;
    NSMutableArray* _sections;
    NSMutableArray* _selectedRows;
    
    struct {
        BOOL heightForRowAtIndexPath : 1;
        BOOL heightForHeaderInSection : 1;
        BOOL heightForFooterInSection : 1;
        BOOL viewForHeaderInSection : 1;
        BOOL viewForFooterInSection : 1;
        BOOL willSelectRowAtIndexPath : 1;
        BOOL didSelectRowAtIndexPath : 1;
		BOOL didDoubleClickRowAtIndexPath: 1;
        BOOL willDeselectRowAtIndexPath : 1;
        BOOL didDeselectRowAtIndexPath : 1;
		BOOL willBeginEditingRowAtIndexPath : 1;
		BOOL didEndEditingRowAtIndexPath : 1;
		BOOL titleForDeleteConfirmationButtonForRowAtIndexPath : 1;
        BOOL accessoryButtonTappedForRowWithIndexPath : 1;
    } _delegateHas;
    
    struct {
        BOOL numberOfSectionsInTableView : 1;
        BOOL titleForHeaderInSection : 1;
        BOOL titleForFooterInSection : 1;
		BOOL commitEditingStyle : 1;
		BOOL canEditRowAtIndexPath : 1;
    } _dataSourceHas;
}

@dynamic delegate;


#pragma mark Initializing a UITableView Object

- (id) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}


#pragma mark Configuring a Table View

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource tableView:self numberOfRowsInSection:section];
}

- (NSInteger) numberOfSections
{
    if (_dataSourceHas.numberOfSectionsInTableView) {
        return [self.dataSource numberOfSectionsInTableView:self];
    } else {
        return 1;
    }
}

- (void) setRowHeight:(CGFloat)newHeight
{
    _rowHeight = newHeight;
    [self setNeedsLayout];
}


#pragma mark Creating Table View Cells

- (void) registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)identifier
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) registerClass:(Class)cellClass forCellReuseIdentifier:(NSString*)identifier
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UITableViewCell*) dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    for (UITableViewCell* cell in _reusableCells) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            [_reusableCells removeObject:cell];
            [cell prepareForReuse];
            [cell setNeedsLayout];
            return cell;
        }
    }
    
    return nil;
}


#pragma mark Accessing Header and Footer Views

- (void) registerNib:(UINib*)nib forHeaderFooterViewReuseIdentifier:(NSString*)identifier
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString*)identifier
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];    
}

- (id) dequeueReusableHeaderFooterViewWithIdentifier:(NSString*)identifier
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) setTableHeaderView:(UIView*)newHeader
{
    if (newHeader != _tableHeaderView) {
        [_tableHeaderView removeFromSuperview];
        _tableHeaderView = newHeader;
        [self _setContentSize];
        [self addSubview:_tableHeaderView];
    }
}

- (void) setTableFooterView:(UIView*)newFooter
{
    if (newFooter != _tableFooterView) {
        [_tableFooterView removeFromSuperview];
        _tableFooterView = newFooter;
        [self _setContentSize];
        [self addSubview:_tableFooterView];
    }
}

- (UITableViewHeaderFooterView*) headerViewForSection:(NSInteger)section
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UITableViewHeaderFooterView*) footerViewForSection:(NSInteger)section
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


#pragma mark Accessing Cells and Sections

- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [_cachedCells objectForKey:indexPath];
}

- (NSIndexPath*) indexPathForCell:(UITableViewCell*)cell
{
    for (NSIndexPath* index in [_cachedCells allKeys]) {
        if ([_cachedCells objectForKey:index] == cell) {
            return index;
        }
    }
    return nil;
}

- (NSIndexPath*) indexPathForRowAtPoint:(CGPoint)point
{
    NSArray* paths = [self indexPathsForRowsInRect:CGRectMake(point.x,point.y,1,1)];
    return ([paths count] > 0)? [paths objectAtIndex:0] : nil;
}

- (NSArray*) indexPathsForRowsInRect:(CGRect)rect
{
    // This needs to return the index paths even if the cells don't exist in any caches or are not on screen
    // Assuming the cells stretch all the way across the view
    [self _updateSectionsCacheIfNeeded];
    NSMutableArray* results = [[NSMutableArray alloc] init];
    const NSInteger numberOfSections = [_sections count];
    CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
    
    for (NSInteger section=0; section<numberOfSections; section++) {
        UITableViewSection* sectionRecord = [_sections objectAtIndex:section];
        const NSInteger numberOfRows = sectionRecord.numberOfRows;
        offset += sectionRecord.headerHeight;
        if (offset + sectionRecord.rowsHeight >= rect.origin.y) {
            for (NSInteger row=0; row<numberOfRows; row++) {
                const CGFloat height = [sectionRecord heightForRowAtIndex:row];
                CGRect simpleRowRect = CGRectMake(rect.origin.x, offset, rect.size.width, height);
                
                if (CGRectIntersectsRect(rect,simpleRowRect)) {
                    [results addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                } else if (simpleRowRect.origin.y > rect.origin.y+rect.size.height) {
                    break;	// don't need to find anything else.. we are past the end
                }
                offset += height;
            }
        } else {
            offset += sectionRecord.rowsHeight;
        }
        offset += sectionRecord.footerHeight;
    }
    return results;
}

- (NSArray*) visibleCells
{
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for (NSIndexPath* index in [self indexPathsForVisibleRows]) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:index];
        if (cell) {
            [cells addObject:cell];
        }
    }
    return cells;
}

- (NSArray*) indexPathsForVisibleRows
{
    [self layoutIfNeeded];
    
    NSMutableArray* indexes = [NSMutableArray arrayWithCapacity:[_cachedCells count]];
    const CGRect bounds = self.bounds;
    
    // Special note - it's unclear if UIKit returns these in sorted order. Because we're assuming that visibleCells returns them in order (top-bottom)
    // and visibleCells uses this method, I'm going to make the executive decision here and assume that UIKit probably does return them sorted - since
    // there's nothing warning that they aren't. :)
    
    for (NSIndexPath* indexPath in [[_cachedCells allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        if (CGRectIntersectsRect(bounds,[self rectForRowAtIndexPath:indexPath])) {
            [indexes addObject:indexPath];
        }
    }
    return indexes;
}


#pragma mark Scrolling the Table View

- (void) scrollToRowAtIndexPath:(NSIndexPath*)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    CGRect rect;
    if (indexPath.row == 0 && indexPath.section == 0) {
        rect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    } else {
        rect = [self rectForRowAtIndexPath:indexPath];
    }
    [self _scrollRectToVisible:rect atScrollPosition:scrollPosition animated:animated];
}

- (void) scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self _scrollRectToVisible:[self rectForRowAtIndexPath:[self indexPathForSelectedRow]] atScrollPosition:scrollPosition animated:animated];
}


#pragma mark Managing Selections

- (NSIndexPath*) indexPathForSelectedRow
{
    if (![_selectedRows count]) { return nil; }
    return [_selectedRows objectAtIndex:0];
}

- (NSArray*) indexPathsForSelectedRows
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    [self selectRowAtIndexPath:indexPath exclusively:YES animated:animated scrollPosition:scrollPosition];
}

- (void) deselectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
    NSUInteger index = [_selectedRows indexOfObject:indexPath];
    if (indexPath && index != NSNotFound) {
        [self cellForRowAtIndexPath:indexPath].selected = NO;
        [_selectedRows removeObjectAtIndex:index];
    }
}


#pragma mark Inserting, Deleting, and Moving Rows and Sections

- (void) beginUpdates
{
	[UIView beginAnimations:NSStringFromSelector(_cmd) context:NULL];
}

- (void) endUpdates
{
	[self _updateSectionsCache];
	[self _setContentSize];
	[self _layoutTableView];
	[UIView commitAnimations];
}

- (void) insertRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadData];
}

- (void) deleteRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadData];
}

- (void) moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}

- (void) insertSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadData];
}

- (void) deleteSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadData];
}

- (void) moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Managing the Editing of Table Cells

- (void) setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animate
{
    _editing = editing;
}


#pragma mark Reloading the Table View

- (void) reloadData
{
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells removeAllObjects];
    [_cachedCells removeAllObjects];
    [_selectedRows removeAllObjects];
    [self _updateSectionsCache];
    [self _setContentSize];

    [self setNeedsLayout];
}

- (void) reloadRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadData];
}

- (void) reloadSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadData];
}

- (void) reloadSectionIndexTitles
{
#warning stub
    [self doesNotRecognizeSelector:_cmd];
}


#pragma mark Accessing Drawing Areas of the Table View

- (CGRect) rectForSection:(NSInteger)section
{
    [self _updateSectionsCacheIfNeeded];
    return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] sectionHeight]];
}

- (CGRect) rectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self _updateSectionsCacheIfNeeded];
    
    if (!indexPath || indexPath.section >= [_sections count]) {
        return CGRectZero;
    }
    UITableViewSection* sectionRecord = [_sections objectAtIndex:indexPath.section];
    if (indexPath.row >= sectionRecord.numberOfRows) {
        return CGRectZero;
    }
    return [self _rectForRowAtIndex:indexPath.row inSection:indexPath.section];
}

- (CGRect) rectForFooterInSection:(NSInteger)section
{
    [self _updateSectionsCacheIfNeeded];
    UITableViewSection* sectionRecord = [_sections objectAtIndex:section];
    CGFloat offset = [self _offsetForSection:section];
    offset += sectionRecord.headerHeight;
    offset += sectionRecord.rowsHeight;
    return [self _CGRectFromVerticalOffset:offset height:sectionRecord.footerHeight];
}

- (CGRect) rectForHeaderInSection:(NSInteger)section
{
    [self _updateSectionsCacheIfNeeded];
    return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] headerHeight]];
}


#pragma mark Managing the Delegate and the Data Source

- (void) setDataSource:(id<UITableViewDataSource>)newSource
{
    _dataSource = newSource;
    _dataSourceHas.numberOfSectionsInTableView = [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];
    _dataSourceHas.titleForHeaderInSection = [_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)];
    _dataSourceHas.titleForFooterInSection = [_dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)];
    [self reloadData];
}

- (void) setDelegate:(id<UITableViewDelegate>)newDelegate
{
    [super setDelegate:newDelegate];
    _delegateHas.heightForRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
    _delegateHas.heightForHeaderInSection = [newDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
    _delegateHas.heightForFooterInSection = [newDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
    _delegateHas.viewForHeaderInSection = [newDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
    _delegateHas.viewForFooterInSection = [newDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
    _delegateHas.willSelectRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
    _delegateHas.didSelectRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
    _delegateHas.didDoubleClickRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:didDoubleClickRowAtIndexPath:)];
    _delegateHas.willDeselectRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)];
    _delegateHas.didDeselectRowAtIndexPath = [newDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)];
    _delegateHas.accessoryButtonTappedForRowWithIndexPath = [newDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];
}


#pragma mark NSCoding protocol

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        if ([coder containsValueForKey:kUIStyleKey]) {
            _style = [coder decodeIntegerForKey:kUIStyleKey];
        } else {
            _style = UITableViewStylePlain;
        }
        [self _commonInitForUITableView];
        if ([coder containsValueForKey:kUIAllowsSelectionDuringEditingKey]) {
            self.allowsSelectionDuringEditing = [coder decodeBoolForKey:kUIAllowsSelectionDuringEditingKey];
        }
        if ([coder containsValueForKey:kUIRowHeightKey]) {
            self.rowHeight = [coder decodeDoubleForKey:kUIRowHeightKey];
        }
        if ([coder containsValueForKey:kUISectionFooterHeightKey]) {
            self.sectionFooterHeight = [coder decodeDoubleForKey:kUISectionFooterHeightKey];
        }
        if ([coder containsValueForKey:kUISectionHeaderHeightKey]) {
            self.sectionHeaderHeight = [coder decodeDoubleForKey:kUISectionHeaderHeightKey];
        }
        if ([coder containsValueForKey:kUISeparatorColorKey]) {
            self.separatorColor = [coder decodeObjectForKey:kUISeparatorColorKey];
        }
        if ([coder containsValueForKey:kUISeparatorStyleKey]) {
            self.separatorStyle = [coder decodeIntegerForKey:kUISeparatorStyleKey];
        } else {
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    return self;
}


#pragma mark UIView

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
    if (nil != (self = [super initWithFrame:frame])) {
        _style = theStyle;
        [self _commonInitForUITableView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    if (!CGRectEqualToRect(oldFrame,frame)) {
        [super setFrame:frame];
        
        if (oldFrame.size.width != frame.size.width) {
            [self _updateSectionsCache];
        }
        
        [self _setContentSize];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self _layoutTableView];
}


#pragma mark UIResponder

- (BOOL) acceptsFirstMouse
{
    return [self canBecomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder {
	return self.window != nil;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self becomeFirstResponder];
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSIndexPath* touchedRow = [self indexPathForRowAtPoint:location];
    
    if (touchedRow) {
        BOOL commandKeyDown = ([NSEvent modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask;
        BOOL exclusively = !commandKeyDown;
        if (([NSEvent modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask && [_selectedRows count]) {
            NSIndexPath* firstIndexPath = [self indexPathForSelectedRow];
            NSComparisonResult result = [firstIndexPath compare:touchedRow];
            if (result != NSOrderedSame && firstIndexPath.section == touchedRow.section) {
                [self deselectAllRowsAnimated:NO];
                BOOL descending = result == NSOrderedDescending;
                NSIndexPath* startIndexPath = descending ? touchedRow : firstIndexPath;
                NSIndexPath* endIndexPath = descending ? firstIndexPath : touchedRow;
                for (NSUInteger i = startIndexPath.row; i <= endIndexPath.row; i++) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:startIndexPath.section];
                    [self _selectRowAtIndexPath:indexPath exclusively:NO sendDelegateMessages:NO animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                exclusively = NO;
            }
        }
        if (commandKeyDown && [_selectedRows containsObject:touchedRow]) {
            [self deselectRowAtIndexPath:touchedRow animated:NO];
        } else {
            NSIndexPath* rowToSelect = [self _selectRowAtIndexPath:touchedRow exclusively:exclusively sendDelegateMessages:YES animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            if([touch tapCount] == 2 && _delegateHas.didDoubleClickRowAtIndexPath) {
                [self.delegate tableView:self didDoubleClickRowAtIndexPath:rowToSelect];
            }
        }
    }
}

- (void) rightClick:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGPoint location = [touch locationInView:self];
    NSIndexPath* touchedRow = [self indexPathForRowAtPoint:location];
    if (touchedRow && [self _canEditRowAtIndexPath:touchedRow]) {
        [self _beginEditingRowAtIndexPath:touchedRow];
    }
}

- (void) moveUp:(id)sender
{
    NSIndexPath* newIndexPath = [self _firstValidIndexPathBeforeIndexPath:[self indexPathForSelectedRow]];
    if (newIndexPath) {
        [self _selectRowAtIndexPath:newIndexPath exclusively:YES sendDelegateMessages:YES animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [self flashScrollIndicators];
}

- (void) moveDown:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSelectedRow];
    NSIndexPath* newIndexPath = nil;
    if (indexPath) {
        newIndexPath = [self _firstValidIndexPathAfterIndexPath:indexPath];
    } else {
        newIndexPath = [self _firstVisibileIndexPath];
    }
    if (newIndexPath) {
        [self _selectRowAtIndexPath:newIndexPath exclusively:YES sendDelegateMessages:YES animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [self flashScrollIndicators];
}

- (void) pageUp:(id)sender
{
    [self scrollRectToVisible:CGRectMake(0.0f, MAX(self.contentOffset.y - self.bounds.size.height, 0), self.bounds.size.width, self.bounds.size.height) animated:YES];
}

- (void) pageDown:(id)sender
{
    [self scrollRectToVisible:CGRectMake(0.0f, MIN(self.contentOffset.y + self.bounds.size.height, self.contentSize.height), self.bounds.size.width, self.bounds.size.height) animated:YES];
}


#pragma mark Private Functions

- (void) _accessoryButtonTappedForTableViewCell:(UITableViewCell*)cell
{
    if (_delegateHas.accessoryButtonTappedForRowWithIndexPath) {
        [self.delegate tableView:self accessoryButtonTappedForRowWithIndexPath:[self indexPathForCell:cell]];
    }
}

- (void) _beginEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self _canEditRowAtIndexPath:indexPath]) {
        self.editing = YES;
        
        if (_delegateHas.willBeginEditingRowAtIndexPath) {
            [self.delegate tableView:self willBeginEditingRowAtIndexPath:indexPath];
        }
        [self performSelector:@selector(_showEditMenuForRowAtIndexPath:) withObject:indexPath afterDelay:0];
    }
}

- (BOOL) _canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return _dataSourceHas.commitEditingStyle && (!_dataSourceHas.canEditRowAtIndexPath || [_dataSource tableView:self canEditRowAtIndexPath:indexPath]);
}

- (CGRect) _CGRectFromVerticalOffset:(CGFloat)offset height:(CGFloat)height
{
	if (self.style == UITableViewStylePlain) {
        return CGRectMake(0, offset, self.bounds.size.width, height);
	} else {
        return CGRectMake(9, offset, self.bounds.size.width - 29, height);
	}
}

- (void) _commonInitForUITableView
{
    _cachedCells = [[NSMutableDictionary alloc] init];
    _sections = [[NSMutableArray alloc] init];
    _reusableCells = [[NSMutableSet alloc] init];
    _selectedRows = [[NSMutableArray alloc] init];
    
    self.separatorColor = [UIColor colorWithRed:.88f green:.88f blue:.88f alpha:1];
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.showsHorizontalScrollIndicator = NO;
    self.allowsSelection = YES;
    self.allowsSelectionDuringEditing = NO;
    self.sectionHeaderHeight = self.sectionFooterHeight = 22;
    self.alwaysBounceVertical = YES;
    
    if (_style == UITableViewStylePlain && !self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewCell*) _ensureCellExistsAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [_cachedCells objectForKey:indexPath];
    if (!cell) {
        cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
        [_cachedCells setObject:cell forKey:indexPath];
        cell.selected = [_selectedRows containsObject:indexPath];
        cell.frame = [self rectForRowAtIndexPath:indexPath];
        
        [cell _setTableViewStyle:UITableViewStylePlain != self.style];
        
        NSUInteger numberOfRows = [[_sections objectAtIndex:indexPath.section] numberOfRows];
        if (indexPath.row == 0 && numberOfRows == 1) {
            cell.sectionLocation = UITableViewCellSectionLocationUnique;
            [cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
        }
        else if (indexPath.row == 0) {
            cell.sectionLocation = UITableViewCellSectionLocationTop;
            [cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
        }
        else if (indexPath.row != numberOfRows - 1) {
            cell.sectionLocation = UITableViewCellSectionLocationMiddle;
            [cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
        }
        else {
            cell.sectionLocation = UITableViewCellSectionLocationBottom;
            [cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
        }
        
        [self addSubview:cell];
        [cell setNeedsDisplay];
    }
    
    return cell;
}

- (void) _endEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.editing) {
        self.editing = NO;
        
        if (_delegateHas.didEndEditingRowAtIndexPath) {
            [self.delegate tableView:self didEndEditingRowAtIndexPath:indexPath];
        }
    }
}

- (NSIndexPath*) _firstVisibileIndexPath
{
    NSArray* indexPaths = [self indexPathsForVisibleRows];
    if ([indexPaths count]) {
        return [indexPaths objectAtIndex:0];
    }
    return nil;
}

- (NSIndexPath*) _firstValidIndexPathBeforeIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row] - 1;
    while (section >= 0) {
        if (row >= 0) {
            return [NSIndexPath indexPathForRow:row inSection:section];
        } else if (!section) {
            break;
        }
        section--;
        row = [self numberOfRowsInSection:section] - 1;
    }
    return nil;
}

- (NSIndexPath*) _firstValidIndexPathAfterIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row] + 1;
    NSInteger numberOfSections = [self numberOfSections];
    while (section < numberOfSections) {
        if (row < [self numberOfRowsInSection:section]) {
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
        section++;
        row = 0;
    }
    return nil;
}

- (void) _layoutTableView
{
    NSMutableDictionary* usedCells = [[NSMutableDictionary alloc] init];
    const CGSize boundsSize = self.bounds.size;
    const CGFloat contentOffset = self.contentOffset.y;
    const CGRect visibleBounds = CGRectMake(0,contentOffset,boundsSize.width,boundsSize.height);
    CGFloat tableHeight = 0;
    
    if (_tableHeaderView) {
        CGRect tableHeaderFrame = _tableHeaderView.frame;
        tableHeaderFrame.origin = CGPointZero;
        tableHeaderFrame.size.width = boundsSize.width;
        _tableHeaderView.frame = tableHeaderFrame;
        _tableHeaderView.hidden = !CGRectIntersectsRect(tableHeaderFrame, visibleBounds);
        tableHeight += tableHeaderFrame.size.height;
    }

    const NSInteger numberOfSections = [_sections count];
    
    for (NSInteger section=0; section<numberOfSections; section++) {
        @autoreleasepool {
            CGRect sectionRect = [self rectForSection:section];
            tableHeight += sectionRect.size.height;
            UITableViewSection* sectionRecord = [_sections objectAtIndex:section];
            const CGRect headerRect = [self rectForHeaderInSection:section];
            const CGRect footerRect = [self rectForFooterInSection:section];
            
            if (sectionRecord.headerView) {
                sectionRecord.headerView.frame = headerRect;
            }
            
            if (sectionRecord.footerView) {
                sectionRecord.footerView.frame = footerRect;
            }
            
            if (CGRectIntersectsRect(sectionRect, visibleBounds)) {
                const NSInteger numberOfRows = sectionRecord.numberOfRows;
                
                for (NSInteger row = 0; row < numberOfRows; row++) {
                    CGRect rowRect = [self _rectForRowAtIndex:row inSection:section];
                    if (CGRectIntersectsRect(rowRect, visibleBounds) && rowRect.size.height > 0) {
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        UITableViewCell* cell = [self _ensureCellExistsAtIndexPath:indexPath];
                        cell.frame = rowRect;
                        [usedCells setObject:cell forKey:indexPath];
                    }
                }
            }
        }
    }
    
    for (NSIndexPath* indexPath in [_cachedCells allKeys]) {
        if (![usedCells objectForKey:indexPath]) {
            UITableViewCell* cell = [_cachedCells objectForKey:indexPath];
            if (cell.reuseIdentifier) {
                [_reusableCells addObject:cell];
            } else {
                [cell removeFromSuperview];
            }
            [_cachedCells removeObjectForKey:indexPath];
        }
    }

    NSArray* allCachedCells = [_cachedCells allValues];
    for (UITableViewCell* cell in _reusableCells) {
        if (CGRectIntersectsRect(cell.frame,visibleBounds) && ![allCachedCells containsObject: cell]) {
            [cell removeFromSuperview];
        }
    }
    
    if (_tableFooterView) {
        CGRect tableFooterFrame = _tableFooterView.frame;
        tableFooterFrame.origin = CGPointMake(0,tableHeight);
        tableFooterFrame.size.width = boundsSize.width;
        _tableFooterView.frame = tableFooterFrame;
        _tableFooterView.hidden = !CGRectIntersectsRect(tableFooterFrame, visibleBounds);
    }
}

- (CGFloat) _offsetForSection:(NSInteger)index
{
    CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
    for (NSInteger s = 0; s < index; s++) {
        offset += [[_sections objectAtIndex:s] sectionHeight];
    }
    return offset;
}

- (CGRect) _rectForRowAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    UITableViewSection* sectionRecord = [_sections objectAtIndex:section];
    CGFloat offset = [self _offsetForSection:section] + [sectionRecord headerHeight] + [sectionRecord offsetForRowAtIndex:index];
    CGFloat height = [sectionRecord heightForRowAtIndex:index];
    return [self _CGRectFromVerticalOffset:offset height:height];
}

- (void) _scrollRectToVisible:(CGRect)aRect atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    if (!CGRectIsNull(aRect) && aRect.size.height > 0) {
        switch (scrollPosition) {
            case UITableViewScrollPositionTop: {
                aRect.size.height = self.bounds.size.height;
                break;
            }
            case UITableViewScrollPositionMiddle: {
                aRect.origin.y -= (self.bounds.size.height / 2.f) - aRect.size.height;
                aRect.size.height = self.bounds.size.height;
                break;
            }
            case UITableViewScrollPositionBottom: {
                aRect.origin.y -= self.bounds.size.height - aRect.size.height;
                aRect.size.height = self.bounds.size.height;
                break;
            }
            case UITableViewScrollPositionNone: {
                break;
            }
        }
        [self scrollRectToVisible:aRect animated:animated];
    }
}

- (NSIndexPath*) _selectRowAtIndexPath:(NSIndexPath*)indexPath exclusively:(BOOL)exclusively sendDelegateMessages:(BOOL)sendDelegateMessages animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    if (!self.allowsMultipleSelection) {
        exclusively = YES;
    }
    if (exclusively) {
        for (__strong NSIndexPath* rowToDeselect in [NSArray arrayWithArray:_selectedRows]) {
            if (sendDelegateMessages && _delegateHas.willDeselectRowAtIndexPath) {
                rowToDeselect = [self.delegate tableView:self willDeselectRowAtIndexPath:rowToDeselect];
            }
            [self deselectRowAtIndexPath:rowToDeselect animated:animated];
            if (sendDelegateMessages && _delegateHas.didDeselectRowAtIndexPath) {
                [self.delegate tableView:self didDeselectRowAtIndexPath:rowToDeselect];
            }
        }
    }
    
    NSIndexPath* rowToSelect = indexPath;
    [self _ensureCellExistsAtIndexPath:indexPath];
	if (sendDelegateMessages && _delegateHas.willSelectRowAtIndexPath) {
        rowToSelect = [self.delegate tableView:self willSelectRowAtIndexPath:rowToSelect];
    }
    [self selectRowAtIndexPath:rowToSelect exclusively:NO animated:animated scrollPosition:scrollPosition];
    if (sendDelegateMessages && _delegateHas.didSelectRowAtIndexPath) {
        [self.delegate tableView:self didSelectRowAtIndexPath:rowToSelect];
    }
    return rowToSelect;
}

- (void) _setContentSize
{
    [self _updateSectionsCacheIfNeeded];
    CGFloat height = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
    for (UITableViewSection* section in _sections) {
        height += [section sectionHeight];
    }
    if (_tableFooterView) {
        height += _tableFooterView.frame.size.height;
    }
    self.contentSize = CGSizeMake(0, height - 1);
}

- (void) _showEditMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self _canEditRowAtIndexPath:indexPath]) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        NSString* menuItemTitle = nil;
        if (_delegateHas.titleForDeleteConfirmationButtonForRowAtIndexPath) {
            menuItemTitle = [self.delegate tableView:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
        }
        if ([menuItemTitle length] == 0) {
            menuItemTitle = @"Delete";
        }
        cell.highlighted = YES;
        NSMenuItem* theItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle action:NULL keyEquivalent:@""];
        NSMenu* menu = [[NSMenu alloc] initWithTitle:@""];
        [menu setAutoenablesItems:NO];
        [menu setAllowsContextMenuPlugIns:NO];
        [menu addItem:theItem];
        NSPoint mouseLocation = [NSEvent mouseLocation];
        CGPoint screenPoint = [self.window.screen convertPoint:NSPointToCGPoint(mouseLocation) fromScreen:nil];
        const BOOL didSelectItem = [menu popUpMenuPositioningItem:nil atLocation:NSPointFromCGPoint(screenPoint) inView:[self.window.screen UIKitView]];
        [[UIApplication sharedApplication] _cancelTouches];
        if (didSelectItem) {
            [_dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        }
        cell.highlighted = NO;
    }
    [self _endEditingRowAtIndexPath:indexPath];
}

- (void) _updateSectionsCache
{
    // note that I'm presently caching and hanging on to views and titles for section headers which is something
    // the real UIKit appears to fetch more on-demand than this. so far this has not been a problem.
    for (UITableViewSection* sectionRecord in _sections) {
        [sectionRecord.headerView removeFromSuperview];
        [sectionRecord.footerView removeFromSuperview];
    }
    [_sections removeAllObjects];
    
    if (_dataSource) {
        const CGFloat defaultRowHeight = _rowHeight ?: _UITableViewDefaultRowHeight;
        const NSInteger numberOfSections = [self numberOfSections];
        for (NSInteger section=0; section<numberOfSections; section++) {
            const NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
            
            UITableViewSection* sectionRecord = [[UITableViewSection alloc] init];
            sectionRecord.numberOfRows = numberOfRowsInSection;
            sectionRecord.headerView = _delegateHas.viewForHeaderInSection? [self.delegate tableView:self viewForHeaderInSection:section] : nil;
            sectionRecord.footerView = _delegateHas.viewForFooterInSection? [self.delegate tableView:self viewForFooterInSection:section] : nil;
            sectionRecord.headerTitle = _dataSourceHas.titleForHeaderInSection? [self.dataSource tableView:self titleForHeaderInSection:section] : nil;
            sectionRecord.footerTitle = _dataSourceHas.titleForFooterInSection? [self.dataSource tableView:self titleForFooterInSection:section] : nil;
            if (!sectionRecord.headerView && sectionRecord.headerTitle) {
                sectionRecord.headerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.headerTitle];
            }
            if (!sectionRecord.footerView && sectionRecord.footerTitle) {
                sectionRecord.footerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.footerTitle];
            }
            if (sectionRecord.headerView) {
                [self addSubview:sectionRecord.headerView];
                sectionRecord.headerHeight = _delegateHas.heightForHeaderInSection? [self.delegate tableView:self heightForHeaderInSection:section] : _sectionHeaderHeight;
            } else {
                sectionRecord.headerHeight = 0;
            }
            if (sectionRecord.footerView) {
                [self addSubview:sectionRecord.footerView];
                sectionRecord.footerHeight = _delegateHas.heightForFooterInSection? [self.delegate tableView:self heightForFooterInSection:section] : _sectionFooterHeight;
            } else {
                sectionRecord.footerHeight = 0;
            }
            
			CGFloat* rowOffsets = malloc(sizeof(CGFloat)*  (numberOfRowsInSection + 1));
            CGFloat lastOffset = 0;
            for (NSInteger row = 0; row < numberOfRowsInSection; row++) {
                const CGFloat rowHeight = _delegateHas.heightForRowAtIndexPath? [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] : defaultRowHeight;
				rowOffsets[row] = lastOffset;
                lastOffset += rowHeight;
            }
            rowOffsets[numberOfRowsInSection] = lastOffset;
            sectionRecord.rowsHeight = lastOffset;
            sectionRecord.rowOffsets = rowOffsets;
            [_sections addObject:sectionRecord];
        }
    }
}

- (void) _updateSectionsCacheIfNeeded
{
    if ([_sections count] == 0) {
        [self _updateSectionsCache];
    }
}

@end


@implementation UITableView (AppKitIntegration)

- (void) selectRowAtIndexPath:(NSIndexPath*)indexPath exclusively:(BOOL)exclusively animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    [self layoutIfNeeded];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    
    if (!self.allowsMultipleSelection) {
        exclusively = YES;
    }
    if (exclusively) {
        [self deselectAllRowsAnimated:animated];
    }
    if (![_selectedRows containsObject:indexPath]) {
        [_selectedRows addObject:indexPath];
        [self cellForRowAtIndexPath:indexPath].selected = YES;
    }
}

- (void) deselectAllRowsAnimated:(BOOL)animated
{
    for (NSIndexPath* indexPath in [NSArray arrayWithArray:_selectedRows]) {
        [self deselectRowAtIndexPath:indexPath animated:animated];
    }
}

@end
