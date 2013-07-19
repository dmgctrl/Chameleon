SPEC_BEGIN(UITableViewCellSpec)
describe(@"UITableViewCell", ^{
    context(@"default", ^{
        UITableViewCell* tableViewCell = [[UITableViewCell alloc]init];
        context(@"property", ^{
            context(@"textLabel", ^{                
                it(@"should be", ^{
                    [[[tableViewCell textLabel] should] beNonNil];
                });
            });
            context(@"detailTextLabel", ^{
                it(@"shouldn't be", ^{
                    [[[tableViewCell detailTextLabel] should] beNil];
                });
            });
            context(@"imageView", ^{
                it(@"should be", ^{
                    [[[tableViewCell imageView] should] beNonNil];
                });
            });
            context(@"contentView", ^{
                it(@"should be", ^{
                    [[[tableViewCell contentView] should] beNonNil];
                });
            });
            context(@"backgroundView", ^{
                it(@"shouldn't be", ^{
                    [[[tableViewCell backgroundView] should] beNil];
                });
            });
            context(@"selectedBackgroundView", ^{
                it(@"should be", ^{
                    [[[tableViewCell selectedBackgroundView] should] beNonNil];
                });
            });
            context(@"multipleSelectionBackgroundView", ^{
                it(@"shouldn't be", ^{
                    [[[tableViewCell multipleSelectionBackgroundView] should] beNil];
                });
            });
            context(@"accessoryType", ^{
                it(@"should be none", ^{
                    [[@([tableViewCell accessoryType]) should] equal:@(UITableViewCellAccessoryNone)];
                });
            });
            context(@"accessoryView", ^{
                it(@"shouldn't be", ^{
                    [[[tableViewCell accessoryView] should] beNil];
                });
            });
            context(@"editingAccessoryType", ^{
                it(@"should be none", ^{
                    [[@([tableViewCell editingAccessoryType]) should] equal:@(UITableViewCellAccessoryNone)];
                });
            });
            context(@"editingAccessoryView", ^{
                it(@"shouldn't be", ^{
                    [[[tableViewCell editingAccessoryView] should] beNil];
                });
            });
            context(@"selected", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell isSelected]) should] beNo];
                });
            });
            context(@"selectionStyle", ^{
                it(@"should be none", ^{
                    [[@([tableViewCell selectionStyle]) should] equal:@(UITableViewCellSelectionStyleBlue)];
                });
            });
            context(@"highlighted", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell isHighlighted]) should] beNo];
                });
            });
            context(@"editing", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell isEditing]) should] beNo];
                });
            });
            context(@"editingStyle", ^{
                it(@"should be none", ^{
                    [[@([tableViewCell editingStyle]) should] equal:@(UITableViewCellEditingStyleNone)];
                });
            });
            context(@"showingDeleteConfirmation", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell showingDeleteConfirmation]) should] beNo];
                });
            });
            context(@"showsReorderControl", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell showsReorderControl]) should] beNo];
                });
            });
            context(@"indentationLevel", ^{
                it(@"should be 0", ^{
                    [[@([tableViewCell indentationLevel]) should] equal:@(0)];
                });
            });
            context(@"indentationWidth", ^{
                it(@"should be 10", ^{
                    [[@([tableViewCell indentationWidth]) should] equal:10 withDelta:0.000001];
                });
            });
            context(@"shouldIndentWhileEditing", ^{
                it(@"should be no", ^{
                    [[@([tableViewCell shouldIndentWhileEditing]) should] beNo];
                });
            });
        });
    });
});
SPEC_END
