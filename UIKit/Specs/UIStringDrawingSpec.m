
SPEC_BEGIN(UIStringDrawing)

static NSString* const string1 = @"The quick brown fox";
static NSString* const string2 = @"jumped over the";
static NSString* const string3 = @"lazy dog";

describe(@"UIStringDrawing", ^{
    context(@"with Baskerville, 17.0", ^{
        UIFont* font = [UIFont fontWithName:@"Baskerville" size:17.0];
        context(@"computing metrics for a single line of text", ^{
            
            context(@"-sizeWithFont:", ^{
                it(@"computes the correct size for string1", ^{
                    [[NSStringFromCGSize([string1 sizeWithFont:font]) should] equal:NSStringFromCGSize((CGSizeMake(144, 21)))];
                });
                it(@"computes the correct size for string2", ^{
                    [[NSStringFromCGSize([string2 sizeWithFont:font]) should] equal:NSStringFromCGSize((CGSizeMake(112, 21)))];
                });
                it(@"computes the correct size for string3", ^{
                    [[NSStringFromCGSize([string3 sizeWithFont:font]) should] equal:NSStringFromCGSize((CGSizeMake(57, 21)))];
                });
            });
            
            context(@"-sizeWithFont:forWidth:lineBreakMode:", ^{
                context(@"using UILineBreakModeWordWrap", ^{
                    NSDictionary* values = @{
                        @(130): @(118),
                        @(100): @(70),
                        @(70):  @(70),
                        @(20):  @(0),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeWordWrap];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });

                context(@"using UILineBreakModeCharacterWrap", ^{
                    NSDictionary* values = @{
                        @(130): @(127),
                        @(100): @(98),
                        @(70):  @(70),
                        @(20):  @(12),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeCharacterWrap];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });

                context(@"using UILineBreakModeClip", ^{
                    NSDictionary* values = @{
                        @(130): @(127),
                        @(100): @(98),
                        @(70):  @(70),
                        @(20):  @(12),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeClip];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });
                
#if 0
                context(@"using UILineBreakModeHeadTruncation", ^{
                    NSDictionary* values = @{
                        @(130): @(128),
                        @(100): @(87),
                        @(70):  @(64),
                        @(20):  @(0),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeHeadTruncation];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });
            
                context(@"using UILineBreakModeTailTruncation", ^{
                    NSDictionary* values = @{
                        @(130): @(126),
                        @(100): @(87),
                        @(70):  @(68),
                        @(20):  @(0),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeTailTruncation];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });

                context(@"using UILineBreakModeMiddleTruncation", ^{
                    NSDictionary* values = @{
                        @(130): @(127),
                        @(100): @(89),
                        @(70):  @(67),
                        @(20):  @(0),
                    };
                    for (NSNumber* widthNumber in values) {
                        context([NSString stringWithFormat:@"given width %@", widthNumber], ^{
                            CGSize size = [string1 sizeWithFont:font forWidth:[widthNumber floatValue] lineBreakMode:UILineBreakModeMiddleTruncation];
                            it(@"computes the correct size for string1", ^{
                                [[NSStringFromCGSize(size) should] equal:NSStringFromCGSize((CGSizeMake([[values objectForKey:widthNumber] floatValue], 21)))];
                            });
                        });
                    }
                });
#endif
            });
        });
    });

});

SPEC_END