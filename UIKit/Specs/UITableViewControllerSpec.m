SPEC_BEGIN(UITableViewControllerSpec)
describe(@"UITableViewController", ^{
    context(@"default", ^{
        UITableViewController* tableViewController = [[UITableViewController alloc] init];
        context(@"property", ^{
            context(@"tableView", ^{
                it(@"should be", ^{
                    [[[tableViewController tableView] should] beNonNil];
                });
            });
            context(@"clearsSelectionOnViewWillAppear", ^{
                it(@"should be yes", ^{
                    [[@([tableViewController clearsSelectionOnViewWillAppear]) should] beYes];
                });
            });
            context(@"refreshControl", ^{
                it(@"should not be", ^{
                    [[[tableViewController refreshControl] should] beNil];
                });
            });
        });
    });
});
SPEC_END