SPEC_BEGIN(UIButtonSpec)
describe(@"UIButton", ^{
    
    __block UIButton* button;
    NSString* text = @"The quick brown fox\n jumped over the lazy \ndog.";
    NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text];
    
    context(@"Plain Text title", ^{
        
        beforeEach(^{
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitle:text forState:UIControlStateNormal];
        });
        
        it(@"should have one line", ^{
            [[@([[button titleLabel] numberOfLines]) should] equal:@(1)];
        });
        it(@"should have middle trucation as linebreak mode", ^{
            [[[[button titleLabel] lineBreakMode] == UILineBreakModeTailTruncation should] beYes];
        });
        
    });
});

SPEC_END