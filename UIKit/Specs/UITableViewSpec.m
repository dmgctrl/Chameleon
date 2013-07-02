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
        });
    });
});
SPEC_END
