#include <UIKit/UITableView.h>
SPEC_BEGIN(UITableViewSpec)
describe(@"UITableView", ^{
    context(@"defaults", ^{
        UITableView* tableView = [[UITableView alloc]init];
        context(@"property", ^{
            context(@"style", ^{
                it(@"should be plain", ^{
                    [[@([tableView style]) should] equal:@(UITableViewStylePlain)];
                });
            });
            context(@"rowHeight", ^{
                it(@"should be zero", ^{
                    [[@([tableView rowHeight]) should] equal:@(44)];
                });
            });
            context(@"rowHeight", ^{
                it(@"should be zero", ^{
                    [[@([tableView separatorStyle]) should] equal:@(UITableViewCellSeparatorStyleSingleLine)];
                });
            });
            context(@"separatorColor", ^{
                it(@"should be gray", ^{
                    [[[tableView separatorColor] should] equal:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
                });
            });
            context(@"backgroundView", ^{
                it(@"should be nil", ^{
                    [[[tableView backgroundView] should] beNil];
                });
            });
            context(@"tableHeaderView", ^{
                it(@"should be nil", ^{
                    [[[tableView tableHeaderView] should] beNil];
                });
            });
            context(@"tableFooterView", ^{
                it(@"should be nil", ^{
                    [[[tableView tableFooterView] should] beNil];
                });
            });
            context(@"sectionHeaderHeight", ^{
                it(@"should be 22", ^{
                    [[@([tableView sectionHeaderHeight]) should] equal:@(22)];
                });
            });
            context(@"sectionFooterHeight", ^{
                it(@"should be 22", ^{
                    [[@([tableView sectionFooterHeight]) should] equal:@(22)];
                });
            });
            context(@"allowsSelection", ^{
                it(@"should be yes", ^{
                    [[@([tableView allowsSelection]) should] beYes];
                });
            });
            context(@"allowsMultipleSelection", ^{
                it(@"should be no", ^{
                    [[@([tableView allowsMultipleSelection]) should] beNo];
                });
            });
            context(@"allowsSelectionDuringEditing", ^{
                it(@"should be no", ^{
                    [[@([tableView allowsSelectionDuringEditing]) should] beNo];
                });
            });
            context(@"allowsMultipleSelectionDuringEditing", ^{
                it(@"should be no", ^{
                    [[@([tableView allowsMultipleSelectionDuringEditing]) should] beNo];
                });
            });
            context(@"isEditing", ^{
                it(@"should be no", ^{
                    [[@([tableView isEditing]) should] beNo];
                });
            });
            context(@"dataSource", ^{
                it(@"should be nil", ^{
                    [[(NSObject*)[tableView dataSource] should] beNil];
                });
            });
            context(@"delegate", ^{
                it(@"should be nil", ^{
                    [[(NSObject*)[tableView delegate] should] beNil];
                });
            });
            context(@"sectionIndexMinimumDisplayRowCount", ^{
                it(@"should be 0", ^{
                    [[@([tableView sectionIndexMinimumDisplayRowCount]) should] equal:@(0)];
                });
            });
            context(@"sectionIndexColor", ^{
                it(@"should be nil", ^{
                    [[[tableView sectionIndexColor] should] beNil];
                });
            });
            context(@"sectionIndexTrackingBackgroundColor", ^{
                it(@"should be nil", ^{
                    [[[tableView sectionIndexTrackingBackgroundColor] should] beNil];
                });
            });
        });
        context(@"Method", ^{
            context(@"numberOfRowsInSection", ^{
                it(@"should be nil", ^{
                    [[@([tableView numberOfRowsInSection:0]) should] equal:@(0)];
                });
            });
            context(@"numberOfSections", ^{
                it(@"should be nil", ^{
                    [[@([tableView numberOfSections]) should] equal:@(1)];
                });
            });
            context(@"headerViewForSection", ^{
                it(@"should be nil", ^{
                    [[[tableView headerViewForSection:0] should] beNil];
                });
            });
            context(@"footerViewForSection", ^{
                it(@"should be nil", ^{
                    [[[tableView footerViewForSection:0] should] beNil];
                });
            });
            context(@"visibleCells", ^{
                it(@"should be empty", ^{
                    [[@([[tableView visibleCells] count]) should] equal:@(0)];
                });
            });
            context(@"indexPathsForVisibleRows", ^{
                it(@"should be empty", ^{
                    [[@([[tableView indexPathsForVisibleRows] count]) should] equal:@(0)];
                });
            });
            context(@"indexPathForSelectedRow", ^{
                it(@"should be empty", ^{
                    [[@([[tableView indexPathForSelectedRow] length]) should] equal:@(0)];
                });
            });
            context(@"indexPathsForSelectedRows", ^{
                it(@"should be empty", ^{
                    [[@([[tableView indexPathsForSelectedRows] count]) should] equal:@(0)];
                });
            });
            context(@"rectForSection", ^{
                it(@"should be origin with zero size", ^{
                    [[@(CGRectEqualToRect([tableView rectForSection:0], CGRectMake(0,0,0,0))) should] beYes];
                });
            });
            context(@"rectForFooterInSection", ^{
                it(@"should be origin with zero size", ^{
                    [[@(CGRectEqualToRect([tableView rectForFooterInSection:0], CGRectMake(0,0,0,0))) should] beYes];
                });
            });
            context(@"rectForHeaderInSection", ^{
                it(@"should be origin with zero size", ^{
                    [[@(CGRectEqualToRect([tableView rectForHeaderInSection:0], CGRectMake(0,0,0,0))) should] beYes];
                });
            });
            
        });
    });
});
SPEC_END
