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
                    [[[tableView dataSource] should] beNil];
                });
            });
            context(@"delegate", ^{
                it(@"should be nil", ^{
                    [[[tableView delegate] should] beNil];
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
    });
});
SPEC_END
