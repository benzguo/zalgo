#import "GTTextView.h"
#import "NSString+GlitchText.h"

@implementation GTTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;

    self.cutCopyPasteEnabled = YES;

    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSString *normalizedAction = [NSStringFromSelector(action) lowercaseString];
    // Turn off these actions
    if ([normalizedAction containsString:@"define"] || [normalizedAction containsString:@"replace"]) {
        return NO;
    }

    // Turn off cut and copy if necessary
    if (!self.cutCopyPasteEnabled) {
        if ([normalizedAction containsString:@"copy"] ||
            [normalizedAction containsString:@"cut"] ||
            [normalizedAction containsString:@"paste"]) {
            return NO;
        }
    }
    return [super canPerformAction:action withSender:sender];
}

@end
