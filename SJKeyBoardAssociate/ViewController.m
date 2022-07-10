//
//  ViewController.m
//  SJKeyBoardAssociate
//
//  Created by 尚杰 on 2022/7/10.
//

#import "ViewController.h"

#import "UIColor+Hex.h"

@interface ViewController ()<UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clearButtonTrailingSpace;
@property (weak, nonatomic) IBOutlet UILabel *remarkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomSpace;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic, copy) NSString *remark;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.label1.text = @"我在本群聊的备注";
    self.label2.text = @"添加的姓名备注，只会在此群聊内显示，群聊成员都可以看见，";
    self.label3.text = @"在群聊中展示效果";
    self.textField.placeholder = @"请输入姓名备注";
    self.textField.tintColor = [UIColor sj_colorWithHex:0x333333];

    
    UIImage * imageBubbleLeft = [[UIImage imageNamed:@"yochat_group_remark_bubble"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bubbleImageView.tintColor = [UIColor sj_colorWithHex:0xf6f6f6];
    self.bubbleImageView.image = imageBubbleLeft;
    
    
    self.textField.text = self.remark;
    self.countLabel.text = [NSString stringWithFormat:@"%@/30", @([self convertToByte:self.remark])];
    if (self.remark.length) {
        self.remarkNameLabel.text = [NSString stringWithFormat:@"%@ %@", @"群聊名字", self.remark];
    } else {
        self.remarkNameLabel.text = [NSString stringWithFormat:@"%@", @"群聊名字"];
    }
    
    [self.textField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldChange
{
    NSInteger bitCount = [self convertToByte:self.textField.text];
    self.countLabel.text = [NSString stringWithFormat:@"%@/30", @(bitCount)];
    if (bitCount > 30) {
        [self.textField resignFirstResponder];
        [self.textField becomeFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self convertToByte:newStr] > 30) {
        return NO;
    }
    self.remarkNameLabel.text = [NSString stringWithFormat:@"%@ %@", @"群聊名字", newStr];
    if ([newStr isEqualToString:self.remark] || (!self.remark && newStr.length == 0)) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor sj_colorWithHex:0xb0b0b0]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor sj_colorWithHex:0x333333]];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    self.countLabel.text = [NSString stringWithFormat:@"%@/30", @([self convertToByte:newStr])];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.clearButtonTrailingSpace.constant = 10;
    self.countLabel.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.clearButtonTrailingSpace.constant = 60;
    self.countLabel.hidden = NO;
    return YES;
}

- (IBAction)clearRemark:(id)sender {
    self.textField.text = @"";
    self.countLabel.text = @"0/30";
    self.remarkNameLabel.text = @"群聊名字";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self.view endEditing:YES];
}


- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect kbFrame = [[noti userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.scrollViewBottomSpace.constant = kbFrame.size.height;
    [self.view addGestureRecognizer:self.tap];
}

- (void)keyboardWillHidden:(NSNotification *)noti
{
    self.scrollViewBottomSpace.constant = 0;
    [self.view removeGestureRecognizer:self.tap];
}

- (void)hidKeyboard
{
    [self.view endEditing:YES];
}

// 计算字符的个数
- (NSUInteger)convertToByte:(NSString *)str {
    NSInteger associateSpecialCount = 0;
    NSInteger start = 0;
    while (start < str.length) {
        NSString *sub = [str substringWithRange:NSMakeRange(start, 1)];
        if ([sub isEqualToString:@"\u2006"]) {
            associateSpecialCount++;
        }
        start++;
    }
    str = [str stringByReplacingOccurrencesOfString:@"\u2006" withString:@""];
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSUInteger strLength = 0;
    char *p = (char *)[str cStringUsingEncoding:encoding];
    
    NSUInteger lengthOfBytes = [str lengthOfBytesUsingEncoding:encoding];
    for (int i = 0; i < lengthOfBytes; i++) {
        if (*p) {
            p++;
            strLength++;
        }
        else {
            p++;
        }
    }
    return strLength + associateSpecialCount;
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidKeyboard)];
    }
    return _tap;
}

@end
