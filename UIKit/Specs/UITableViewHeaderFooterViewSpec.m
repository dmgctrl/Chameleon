SPEC_BEGIN(UITableViewHeaderFooterViewSpec)
describe(@"UITableViewHeaderFooterView", ^{
    context(@"default", ^{
        UITableViewHeaderFooterView* tableViewHeaderFooterView = [[UITableViewHeaderFooterView alloc] init];
        it(@"should exist", ^{
            [[tableViewHeaderFooterView should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[tableViewHeaderFooterView should] beKindOfClass:[UITableViewHeaderFooterView class]];
        });
        context(@"property", ^{

            context(@"contentView", ^{
                it(@"should be", ^{
                    [[[tableViewHeaderFooterView contentView] should] beNonNil];
                });
            });
            context(@"backgroundView", ^{
                it(@"should not be", ^{
                    [[[tableViewHeaderFooterView backgroundView] should] beNil];
                });
            });
            context(@"reuseIdentifier", ^{
                it(@"should not be", ^{
                    [[[tableViewHeaderFooterView reuseIdentifier] should] beNil];
                });
            });
            context(@"textLabel", ^{
                it(@"should be", ^{
                    [[[tableViewHeaderFooterView textLabel] should] beNonNil];
                });
            });
            context(@"detailTextLabel", ^{
                it(@"should be", ^{
                    [[[tableViewHeaderFooterView detailTextLabel] should] beNonNil];
                });
            });
            context(@"tintColor", ^{
                it(@"should not be", ^{
                    [[[tableViewHeaderFooterView tintColor] should] beNil];
                });
            });
        });

        context(@"instance method", ^{
            context(@"prepareForReuse", ^{
                it(@"should be responded to", ^{
                    [[@([tableViewHeaderFooterView respondsToSelector:@selector(prepareForReuse)]) should] beYes];
                });
            });
        });
    });
});
SPEC_END