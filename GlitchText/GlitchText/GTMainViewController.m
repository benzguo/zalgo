#import "GTMainViewController.h"

#import "GTZalgo.h"
#import "GTGlitchViewController.h"
#import "GTSymbolViewController.h"
#import "GTShapeViewController.h"
#import "GTFontTableViewController.h"
#import "GTTextRange.h"
#import "NSString+GlitchText.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GTMainViewController () <UITextViewDelegate, GTInputDelegate>

@property (strong, nonatomic) GTZalgo *zalgo;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) GTGlitchViewController *glitchVC;
@property (strong, nonatomic) GTSymbolViewController *symbolVC;
@property (strong, nonatomic) GTShapeViewController *shapeVC;
@property (strong, nonatomic) GTFontTableViewController *fontTVC;

// menu buttons
@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *glitchButton;
@property (weak, nonatomic) IBOutlet UIButton *symbolButton;
@property (weak, nonatomic) IBOutlet UIButton *shapeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) NSArray *buttons;

@end

@implementation GTMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttons = @[self.fontButton,
                     self.glitchButton,
                     self.symbolButton,
                     self.shapeButton,
                     self.shareButton];

    self.textView.delegate = self;

    self.zalgo = [GTZalgo sharedInstance];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.glitchVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"GlitchViewController"];
    self.glitchVC.delegate = self;
    self.symbolVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SymbolViewController"];
    self.symbolVC.delegate = self;
    self.shapeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShapeViewController"];
    self.shapeVC.delegate = self;

    [self.textView becomeFirstResponder];
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

- (IBAction)fontButtonAction:(id)sender
{
    [self deselectAllExcept:@[self.fontButton]];
    self.textView.inputView = nil;
    if (self.fontButton.selected) {
        self.fontButton.selected = NO;
        [self.textView becomeFirstResponder];
    }
    else {
        self.fontButton.selected = YES;
        [self.textView resignFirstResponder];
    }
}

- (IBAction)glitchButtonAction:(id)sender
{
    [self tapButton:self.glitchButton inputView:self.glitchVC.view];
}

- (IBAction)symbolButtonAction:(id)sender
{
    [self tapButton:self.symbolButton inputView:self.symbolVC.view];
}

- (IBAction)shapeButtonAction:(id)sender
{
    [self tapButton:self.shapeButton inputView:self.shapeVC.view];
}

- (IBAction)shareButtonAction:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.textView.text];
}

- (void)deselectAllExcept:(NSArray *)buttons
{
    for (UIButton *b in self.buttons) {
        if (![buttons containsObject:b]) {
            b.selected = NO;
        }
    }
}


- (void)tapButton:(UIButton *)button inputView:(UIView *)view
{
    [self deselectAllExcept:@[button]];
    if (button.selected) {
        button.selected = NO;
        [self.textView resignFirstResponder];
        self.textView.inputView = nil;
        [self.textView becomeFirstResponder];
    }
    else {
        button.selected = YES;
        [self.textView resignFirstResponder];
        self.textView.inputView = view;
        [self.textView becomeFirstResponder];
    }
}


#pragma mark - GTInputDelegate

- (void)shouldEnterText:(NSString *)text
{
    NSRange selectedRange = self.textView.selectedRange;
    NSString *currentText = self.textView.text;
    if (selectedRange.length) {
        NSString *selectedString = [currentText substringWithRange:selectedRange];
        NSString *newSelectedString = [selectedString appendToEachCharacter:text];
        self.textView.text = [currentText stringByReplacingCharactersInRange:selectedRange
                                                                  withString:newSelectedString];
        self.textView.textAlignment = self.textView.textAlignment;
        // reselect
        NSRange newRange = [self.textView.text rangeOfString:newSelectedString];
        self.textView.selectedRange = newRange;
    }
    else {
        NSString *firstHalf = [currentText substringToIndex:selectedRange.location];
        NSString *secondHalf = [currentText substringFromIndex:selectedRange.location];
        firstHalf = [firstHalf stringByAppendingString:text];
        self.textView.text = [firstHalf stringByAppendingString:secondHalf];
        NSRange newRange = NSMakeRange(selectedRange.location + text.length, 0);
        self.textView.selectedRange = newRange;
    }
}

- (void)shouldInvokeTheHiveMind
{
    self.textView.text = [[GTZalgo sharedInstance] process:self.textView.text mode:GTZalgoModeNormal];
    self.textView.textAlignment = self.textView.textAlignment;
}

- (void)showDefaultKeyboard;
{
    [self deselectAllExcept:nil];
    [self.textView resignFirstResponder];
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];   
}

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0) {
        return YES;
    }

    // zalgo
    else {
        NSString *processed = [self.zalgo process:text];
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:processed];
        textView.text = newText;
        textView.textAlignment = textView.textAlignment;
        return NO;
    }

    return YES;
}

@end
