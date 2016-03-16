//
//  CodiaViewController.m
//  SSHARE
//
//  Created by wuhaibin on 16/2/20.
//  Copyright © 2016年 wuhaibin. All rights reserved.
//

#import "CodiaViewController.h"
#import "RecordViewController.h"
#import "CodiaService.h"
#import <MBProgressHUD.h>
#import <Masonry.h>
#import "NSData+GZIP.h"

#define winWidth [UIScreen mainScreen].bounds.size.width

@interface CodiaViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate> {
    
    UITextField *_inputTextField;
    
    UIButton *_goBtn;
    
    int currentState;
    
    UIImageView *_codiaImageView;
    
    UIView *_contentView;
    
    CodiaService * _codiaService;
    
    BOOL _isNewRecord;
    
//    NSString * _swipeString;
    
    MBProgressHUD * _mbProgressHUD;
    
    CGPoint _originPoint;
    
    UIImageView *_changeImagView;
    
    CGPoint _changeOriginCenter;
    
    UILabel * _tipsLabel;
    
    NSString * _originalKey;
    
}

@end

@implementation CodiaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupImageViewAndBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"UploadSuccess" object:nil];
    self.navigationController.navigationBar .hidden = YES;
    // 初始化的时候  GOBTN 应该是hidden 才对
    _changeOriginCenter = _changeImagView.center;
    _originPoint = _contentView.center;
    NSLog(@"%f",winWidth);
    _isNewRecord = NO;
    _goBtn.hidden = YES;
    _inputTextField.delegate = self;
    [self setTipsLabel];
    [self setPanGesture];
    [self codiaImageViewSetting];
    [self setupTapGesture];
    
}

- (void)viewWillAppear:(BOOL)animated {
    _swipeString = nil;
    if (_originalKey != nil) {
        NSString * string = [self getNewTextField:_originalKey];
        _inputTextField.text = string;
    }
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 按照比例计算 中间的imageview 的高度等等
- (void)setupImageViewAndBtn {
    
    CGRect winSize = [[UIScreen mainScreen]bounds];
    _contentView = [[UIView alloc]init];
    _codiaImageView = [[UIImageView alloc]init];
    _inputTextField = [[UITextField alloc]init];
    
    if (winWidth == 320) {
        // 判断是IPHONE5&&5S&&5C
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 95, winSize.size.width - 10, 85);
        _codiaImageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 85);
        
        _codiaImageView.image = [UIImage imageNamed:@"5IMAGEVIEW"];
        
        _inputTextField.frame = CGRectMake(14, 14, winSize.size.width - 66, 28);
        
        _inputTextField.textAlignment = UITextAlignmentCenter;
        [_contentView addSubview:_codiaImageView ];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];
        
        _goBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, winSize.size.height - 49, winSize.size.width, 50)];
        [_goBtn setImage:[UIImage imageNamed:@"5CODIABTN"] forState:UIControlStateNormal];
        [_goBtn addTarget:self action:@selector(goClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_goBtn];
    }else if(winWidth == 375) {
        //6 && 6S
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 110, winSize.size.width - 10, 100);
        _codiaImageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 100);
        _codiaImageView.image = [UIImage imageNamed:@"6IMAGEVIEW"];

        _inputTextField.frame = CGRectMake(15, 15, winSize.size.width - 70, 33);
        _inputTextField.textAlignment = UITextAlignmentCenter;
        
        [_contentView addSubview:_codiaImageView ];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];
        
        _goBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, winSize.size.height - 59, winSize.size.width, 60)];
        [_goBtn setImage:[UIImage imageNamed:@"6CODIABTN"] forState:UIControlStateNormal];

        [_goBtn addTarget:self action:@selector(goClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_goBtn];
    }else if(winWidth > 375) {
        //判断是6P HUOZHE 6SP
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 120, winSize.size.width - 10, 110);
        _codiaImageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 110);
        _codiaImageView.image = [UIImage imageNamed:@"6PIMAGEVIEW"];
        UIImage * image = [UIImage imageNamed:@"6PIMAGEVIEW"];
        _inputTextField.frame = CGRectMake(18, 18, winSize.size.width - 82, 36);
        _inputTextField.textAlignment = UITextAlignmentCenter;
        [_contentView addSubview:_codiaImageView];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];
        _goBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, winSize.size.height - 65, winSize.size.width, 67)];
//        [_goBtn setBackgroundImage:[UIImage imageNamed:@"6PGOBTN"] forState:UIControlStateNormal];
        [_goBtn setImage:[UIImage imageNamed:@"6PCODIABTN"] forState:UIControlStateNormal];
        [_goBtn addTarget:self action:@selector(goClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_goBtn];
    }
    _goBtn.userInteractionEnabled = YES;
    _inputTextField.font = [UIFont systemFontOfSize:14];
    _inputTextField.text = @"请输入16位数序列号或下拉重新获取";
    _inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    
}

- (void)uploadSuccess:(NSNotification *)notification {
    NSString * inputText = [notification object];
    _inputTextField.text = inputText;
}

#pragma mark - settipsLabel
- (void)setTipsLabel {
    CGRect winSize = [[UIScreen mainScreen]bounds];
    NSLog(@"%f",winSize.size.width);
    _tipsLabel = [[UILabel alloc]init];
    _tipsLabel.frame = CGRectMake(winSize.size.width/2 - 100, winSize.size.height/2 - 60, 200, 40);
    _tipsLabel.textAlignment = UITextAlignmentCenter;
    _tipsLabel.text = @"松手获取序列号";
    _tipsLabel.textColor = [UIColor colorWithRed:60.0/255 green:3.0/255 blue:114.0/255 alpha:1];
    [self.view addSubview:_tipsLabel];
    _tipsLabel.hidden = YES;
}

#pragma mark - 设置初始化的 下拉动作
- (void)setChangeAnimation {
    
}

#pragma mark - panGesture 
- (void)setPanGesture {
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    _contentView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:panGestureRecognizer];
    
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    _changeImagView.hidden = YES;
    CGRect winSize = [[UIScreen mainScreen]bounds];
    CGPoint touchPoint = [gesture locationInView:self.view];
    NSLog(@"获取当前X 的值%f",touchPoint.x);
    NSLog(@"获取当前Y 的值%f",touchPoint.y);
    if ((touchPoint.y >= (winSize.size.height - 260)) ) {
        _contentView.center = CGPointMake(winSize.size.width / 2, winSize.size.height - 260);
    }else if (touchPoint.y <= 150)   {
        _contentView.center = CGPointMake(winSize.size.width / 2, 150);
    }else {
        _contentView.center = CGPointMake(winSize.size.width / 2 , touchPoint.y);
    }
    // 如果大于三分之二，则显示那个View
    // 判断手势已经结束 返回到  之前的位置
    if (touchPoint.y >= winSize.size.height - 260) {
        _tipsLabel.text = @"松手获取序列号";
        _tipsLabel.hidden = NO;
    } else {
        _tipsLabel.hidden = YES;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _tipsLabel.hidden = YES;
        if (touchPoint.y >= winSize.size.height - 260) {
            [self swipeDown];
                    }else {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                _contentView.center = CGPointMake(winWidth/2, winSize.size.height/2-60);
            } completion:^(BOOL finished) {
                NSLog(@"手势结束");
                _changeImagView . hidden = NO;
            }];
        }
    }
}

#pragma mark - setupTapGesture
- (void)setupTapGesture {
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignTextField)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)resignTextField {
    [_inputTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_inputTextField.text isEqualToString:@"请输入16位数序列号或下拉重新获取"]) {
        _inputTextField.text = @"";
        _inputTextField.font = [UIFont systemFontOfSize:18];
    }else {
        _inputTextField.font = [UIFont systemFontOfSize:18];
    }
    _goBtn.hidden = NO;
    
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_inputTextField.text.length == 16) {
        _goBtn.hidden = NO;
    }
    if (_inputTextField.text .length == 0) {
        _goBtn.hidden = YES;
        _inputTextField.text = @"请输入16位数序列号或下拉重新获取";
        _inputTextField.font = [UIFont systemFontOfSize:14];
    }

    if (textField.text.length == 4) {
        _inputTextField.text = [_inputTextField.text stringByAppendingString:@" "];
    }else if(textField.text.length == 9) {
        _inputTextField.text = [_inputTextField.text stringByAppendingString:@" "];
    }
}

- (NSString *)getNewTextField:(NSString *)oldText{
    NSString *text = oldText;
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    oldText = [oldText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([oldText rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
//        return NO;
    }
    
//    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    
//    if (newString.length >= 20) {
//        return NO;
//    }
    
//    [textField setText:newString];
    return newString;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField text];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    text = [text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    
    if (newString.length >= 20) {
        return NO;
    }
    
    [textField setText:newString];
    
    return NO;

}

- (void)goClick {
    if (_inputTextField.text.length != 19) {
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.mode = MBProgressHUDModeText;
        _mbProgressHUD.labelText = @"请输入16位的语音序列";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    //第一种情况  如果是自己输入的 只能够去搜索 swipe 的内容和 如今textfield 的内容不一致  而且上一次 录入的语音 是没上传成功。
    
    //if:newSwipe和输入的textfield的内容一致 直接进入搜索的模式
    
    NSString * codiaNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"codiaNumber"];
    NSString * uploadState = [[NSUserDefaults standardUserDefaults]objectForKey:@"uploadState"];
    NSString * newCodiaNumber = [self getNewTextField:codiaNumber];
    NSString * newSSS = [self getNewTextField:_swipeString];
    if ([newCodiaNumber isEqualToString:_inputTextField.text] &&[uploadState isEqualToString:@"Success"]) {
        NSLog(@"上次上传成功了");
    }
    NSString * newSwipe = [self getNewTextField:_swipeString];
    if ( ([newCodiaNumber isEqualToString:_inputTextField.text] && [uploadState isEqualToString:@"NOTRECORD"])||[newSwipe isEqualToString:_inputTextField.text]) {
        RecordViewController * recordViewController = [[RecordViewController alloc]init];
        recordViewController.codiaNumber = _originalKey;
        [self.navigationController pushViewController:recordViewController animated:YES];
    } else if ((_swipeString != nil&& ![newSwipe isEqualToString:_inputTextField.text]) || _swipeString == nil) {
        //直接进入搜索
        // 重新获取 _inputTextfield 的内容
        NSString * newString = [[NSString alloc]init];
        for (int i = 0; i < _inputTextField.text.length; i ++) {
            NSString * newChar = [_inputTextField.text substringWithRange:NSMakeRange(i, 1)];
            if (i != 4 && i != 9 && i != 14) {
                newString = [newString stringByAppendingString:newChar];
            }
        }
        NSLog(@"输出 %@",_inputTextField.text);
        //上网获取新的录音  获取到了 再跳转。
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.mode = MBProgressHUDModeIndeterminate;
        _mbProgressHUD.labelText = @"正在加载，请稍候";
        _codiaService = [CodiaService sharedInstance];
        //        NSLog(@"%@",_inputTextField.text);
        [_codiaService getVoiceRecordData:newString DTZDataBlock:^(NSData *dataSuccessBlock) {
            NSLog(@"%@",dataSuccessBlock);
            // 跳转到 录音部分。
            dataSuccessBlock = [dataSuccessBlock gunzippedData];
            _mbProgressHUD .labelText = @"加载成功";
            _mbProgressHUD.mode = MBProgressHUDModeText;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                RecordViewController * recordViewController = [[RecordViewController alloc]init];
                recordViewController.voiceData = [[NSData alloc]init];
                recordViewController.isPlayScheme = YES;
                recordViewController.voiceData = dataSuccessBlock;
                //重新设置 codiaNumber 不在传参出做传输
                recordViewController.codiaNumber = newString;
                [self.navigationController pushViewController:recordViewController animated:YES];
            });
                    } DTZErrorBlock:^(NSError *errorBlock) {
            //不存在该 录音记录
            _mbProgressHUD.mode = MBProgressHUDModeText;
            _mbProgressHUD.labelText = @"该录音不存在";
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
        }];

    }
    
    
    //第二种情况 自己输入的 但是和之前swipe的内容一致 可以进去录入语音。
    
    // 第三种情况 如果和 swipe 的内容一致直接进入录音。
    
    // 第四种情况 是自己输入的内容  直接进入搜索录音的模式。
    
    
//    if (((_swipeString != nil && [_swipeString isEqualToString:_originalKey]) || !([codiaNumber isEqualToString:_originalKey] && [uploadState isEqualToString:@"Success"]))) {
//        RecordViewController * recordViewController = [[RecordViewController alloc]init];
//        recordViewController.codiaNumber = _originalKey;
//        [self.navigationController pushViewController:recordViewController animated:YES];
//    }else {
//        //上网获取新的录音  获取到了 再跳转。
//        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        _mbProgressHUD.mode = MBProgressHUDModeIndeterminate;
//        _mbProgressHUD.labelText = @"正在加载，请稍候";
//        _codiaService = [CodiaService sharedInstance];
////        NSLog(@"%@",_inputTextField.text);
//        [_codiaService getVoiceRecordData:_originalKey DTZDataBlock:^(NSData *dataSuccessBlock) {
//            NSLog(@"%@",dataSuccessBlock);
//            // 跳转到 录音部分。
//            _mbProgressHUD .labelText = @"加载成功";
//            _mbProgressHUD.mode = MBProgressHUDModeText;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//            dataSuccessBlock = [dataSuccessBlock gunzippedData];
//            RecordViewController * recordViewController = [[RecordViewController alloc]init];
//            recordViewController.voiceData = [[NSData alloc]init];
//            recordViewController.isPlayScheme = YES;
//            recordViewController.voiceData = dataSuccessBlock;
//            //重新设置 codiaNumber 不在传参出做传输
//            recordViewController.codiaNumber = _originalKey;
//            [self.navigationController pushViewController:recordViewController animated:YES];
//        } DTZErrorBlock:^(NSError *errorBlock) {
//            // 不存在该 录音记录
//            _mbProgressHUD.mode = MBProgressHUDModeText;
//            _mbProgressHUD.labelText = @"该录音不存在";
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                // Do something...
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//            
//        }];
//    }
}

- (void)getUDIDandTimeStamp {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    NSLog(@"%@",result);
}

#pragma mark - codiaImageView Setting 
- (void)codiaImageViewSetting {
    
}

- (void)swipeDown {
    //重新发送请求，获取16位的key
    CGRect winSize = [[UIScreen mainScreen]bounds];
    _codiaService = [CodiaService sharedInstance];
    [_codiaService getTokenAndKey:^(NSDictionary *successBlock) {
        NSLog(@"%@",successBlock);
        NSString * key = [successBlock objectForKey:@"key"];
        _originalKey = key;
        key = [self getNewTextField:key];
        _inputTextField.text = key;
        _inputTextField.font = [UIFont systemFontOfSize:18];
        _inputTextField.hidden = NO;
        _isNewRecord = YES;
        _swipeString = _originalKey;
        _goBtn.hidden = NO;
        // 启动 转的位置
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.labelText = @"正在获取数据信息";
        _mbProgressHUD.mode = MBProgressHUDModeText;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            _contentView.center = CGPointMake(winWidth/2, winSize.size.height/2-60);
        } completion:^(BOOL finished) {
            NSLog(@"手势结束");
            _changeImagView . hidden = NO;
        }];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    } DTZFailBlock:^(NSDictionary  *failBlock) {
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.mode = MBProgressHUDModeText;
        _mbProgressHUD.labelText = @"网络故障,请稍后再试";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            _contentView.center = CGPointMake(winWidth/2, winSize.size.height/2-60);
        } completion:^(BOOL finished) {
            NSLog(@"手势结束");
            _changeImagView . hidden = NO;
        }];
    }];
}

@end
