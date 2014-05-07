#import "GTMainViewController.h"

#import "GTZalgo.h"
#import "GTGlitchInputViewController.h"
#import "GTFontTableViewController.h"
#import "NSString+GlitchText.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GTMainViewController () <UITextViewDelegate, GTGlitchInputDelegate>

@property (strong, nonatomic) GTZalgo *zalgo;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) GTGlitchInputViewController *glitchInputVC;
@property (strong, nonatomic) GTFontTableViewController *fontTVC;

// menu buttons
@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *glitchButton;
@property (weak, nonatomic) IBOutlet UIButton *symbolButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation GTMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    
    self.zalgo = [GTZalgo new];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.glitchInputVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"GlitchInputViewController"];
    self.glitchInputVC.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"fontEmbedSegue"]) {
        self.fontTVC = segue.destinationViewController;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING");
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (void)deselectAllButtons
{
    self.fontButton.selected = NO;
    self.glitchButton.selected = NO;
    self.symbolButton.selected = NO;
    self.shareButton.selected = NO;
}

- (IBAction)fontButtonAction:(id)sender
{
    if (self.fontButton.selected) {
        self.fontButton.selected = NO;
        [self.textView becomeFirstResponder];
    }
    else {
        self.fontButton.selected = YES;
        [self.textView resignFirstResponder];
    }
}

- (IBAction)glitchButtonAction:(id)sender {
    if (self.glitchButton.selected) {
        self.glitchButton.selected = NO;
        [self.textView resignFirstResponder];
        self.textView.inputView = nil;
        [self.textView becomeFirstResponder];
    }
    else {
        self.glitchButton.selected = YES;
        [self.textView resignFirstResponder];
        self.textView.inputView = self.glitchInputVC.view;
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - GTGlitchInputDelegate

- (void)shouldEnterText:(NSString *)text
{
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.length) {
        NSString *selectedString = [self.textView.text substringWithRange:selectedRange];
        NSString *newSelectedString = [selectedString appendToEachCharacter:text];
        self.textView.text = [self.textView.text stringByReplacingCharactersInRange:selectedRange
                                                                         withString:newSelectedString];
    }
    else {
        self.textView.text = [self.textView.text stringByAppendingString:text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0) {
        return YES;
    }

    // zalgo
    NSString *processed = [GTZalgo process:text];
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:processed];
    textView.text = newText;
    return NO;
}

@end
