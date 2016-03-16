//
//  RecordViewController.m
//  SSHARE
//
//  Created by wuhaibin on 16/2/20.
//  Copyright © 2016年 wuhaibin. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CodiaService.h"
#import <MBProgressHUD.h>
#import "NSData+GZIP.h"
#import <UIKit/UIKit.h>


#define winWidth [UIScreen mainScreen].bounds.size.width

@interface RecordViewController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate,UITextViewDelegate> {
    UILabel *_inputTextField;
    
    IBOutlet UIButton *_playBtn;
    
    UIView *_contentView;
    
    IBOutlet UILabel *_topLabel;
    
    IBOutlet UIImageView *_topBGView;
    
    AVAudioRecorder * _audioPlayer;
    
    NSURL * _tmpFile;
    
    UIImageView *_imageView;
    
    AVAudioPlayer * _avPlayer;
    
    CodiaService * _codiaService;
    
    NSString * alreadyUpload;
    
    NSTimer * _timer;
    
    BOOL _isRecord;
    
    int _secondCount;
    
    BOOL _isRecordSchemePlaying;
    
    BOOL _isPlaySchemePlaying;
    
    MBProgressHUD * _mbProgressHUD;
    
    int _playSchemeSecondCount;
    
    NSTimer * _playSchemeTimer;
    
    IBOutlet UITextView *_topTextView;
    
    CGPoint _originPoint;
    
    UILabel * _tipsLabel;
    
    BOOL _isNewPlaying;
    
    BOOL _shouldShowTotalSec;
    
    BOOL _isFinishUpload;
    
    BOOL _shouldTurnZero;
    
}

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * newTopString = [self getNewTextField:self.codiaNumber];
    
    _topTextView.text = newTopString;
    [self setupImageViewAndBtn];
    if (self.isPlayScheme) {
        _shouldShowTotalSec = YES;
        _playSchemeSecondCount = 0;
        _isRecordSchemePlaying = NO;
        [self setPlayScheme];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:self.codiaNumber forKey:@"codiaNumber"];
            [[NSUserDefaults standardUserDefaults]setObject:@"NOTRECORD" forKey:@"uploadState"];
        _secondCount = 0;
        _originPoint = _contentView.center;
        [self setTipsLabel];
        [self setPanGesture];
        [self setRecordScheme];
    }
    _topTextView.text = self.codiaNumber;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_playSchemeTimer invalidate];
    _playSchemeTimer = nil;
    [_timer invalidate];
    _timer = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
//    [[NSUserDefaults standardUserDefaults]setObject:self.codiaNumber forKey:@"codiaNumber"];
//    [[NSUserDefaults standardUserDefaults]setObject:@"Success" forKey:@"uploadState"];
}

- (void)viewWillAppear:(BOOL)animated {

    NSString * newTopString = [self getNewTextField:self.codiaNumber];
    _topTextView.text = newTopString;
}

#pragma mark - 按照比例计算 中间的imageview 的高度等等
- (void)setupImageViewAndBtn {
    
    CGRect winSize = [[UIScreen mainScreen]bounds];
    NSLog(@"%f",winSize.size.width);
    
    _contentView = [[UIView alloc]init];
    _imageView = [[UIImageView alloc]init];
    _inputTextField = [[UILabel alloc]init];
    
    if (winWidth == 320) {
        // 判断是IPHONE5&&5S&&5C
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 95, winSize.size.width - 10, 85);
        _imageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 85);
        
        _imageView.image = [UIImage imageNamed:@"5IMAGEVIEW"];
        
        _inputTextField.frame = CGRectMake(14, 14, winSize.size.width - 66, 28);
        
        _inputTextField.textAlignment = UITextAlignmentCenter;
        [_contentView addSubview:_imageView ];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];

    }else if(winWidth == 375) {
        //6 && 6S
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 110, winSize.size.width - 10, 100);
        _imageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 100);
        _imageView.image = [UIImage imageNamed:@"6IMAGEVIEW"];
        
        _inputTextField.frame = CGRectMake(15, 15, winSize.size.width - 70, 33);
        _inputTextField.textAlignment = UITextAlignmentCenter;
        
        [_contentView addSubview:_imageView ];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];

    }else if(winWidth > 375) {
        //判断是6P HUOZHE 6SP
        _contentView.frame = CGRectMake(5, winSize.size.height / 2 - 120, winSize.size.width - 10, 110);
        _imageView.frame = CGRectMake(0, 0, winSize.size.width - 10, 110);
        _imageView.image = [UIImage imageNamed:@"6PIMAGEVIEW"];
        UIImage * image = [UIImage imageNamed:@"6PIMAGEVIEW"];
        _inputTextField.frame = CGRectMake(18, 18, winSize.size.width - 82, 36);
        _inputTextField.textAlignment = UITextAlignmentCenter;
        [_contentView addSubview:_imageView];
        [_contentView addSubview:_inputTextField];
        [self.view addSubview:_contentView];

    }
    _inputTextField.font = [UIFont systemFontOfSize:22];
    _inputTextField.text = @"0“";
    _contentView.hidden = YES;
    
    if (_isPlayScheme) {
        _contentView.hidden = NO;
    }
    
}


#pragma mark - settipsLabel
- (void)setTipsLabel {
    CGRect winSize = [[UIScreen mainScreen]bounds];
    _tipsLabel = [[UILabel alloc]init];
    _tipsLabel.frame = CGRectMake(winSize.size.width / 2 - 100, winSize.size.height / 2 - 60, 200, 40);
    _tipsLabel.textAlignment = UITextAlignmentCenter;
    _tipsLabel.text = @"松手重置语音";
    _tipsLabel.font = [UIFont systemFontOfSize:18];
    _tipsLabel.textColor = [UIColor colorWithRed:60.0/255 green:3.0/255 blue:114.0/255 alpha:1];
    [self.view addSubview:_tipsLabel];
    _tipsLabel.hidden = YES;
}

#pragma mark - panGesture
- (void)setPanGesture {
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    _contentView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:panGestureRecognizer];
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
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
    // 判断手势已经结束 返回到之前的位置
    if (touchPoint.y  <= 165) {
        _tipsLabel.text = @"松手上传语音";
        _tipsLabel.hidden = NO;
        
    }else if (touchPoint.y >= winSize.size.height - 260) {
        _tipsLabel.text = @"松手重置语音";
        _tipsLabel.hidden = NO;
    }else {
        _tipsLabel.hidden = YES;
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _tipsLabel.hidden = YES;
        if (touchPoint.y >= winSize.size.height - 260) {
            [_avPlayer stop];
            [_playSchemeTimer invalidate];
            _playSchemeTimer = nil;
            [_timer invalidate];
            _timer = nil;
            _inputTextField.font = [UIFont systemFontOfSize:22];
            _inputTextField.text = @"0“";
            if (_tmpFile == nil) {
                _secondCount = 0;
                _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                _mbProgressHUD.labelText = @"重置语音成功";
                _mbProgressHUD.mode = MBProgressHUDModeText;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }else {
                _secondCount = 0;
                _tmpFile = nil;
                [_playBtn removeTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
                [self setRecordScheme];
                _isRecord = NO;
                _secondCount = 0;
            }
        }else if (touchPoint.y  <= 160){
            // 上传语音
            if (_tmpFile == nil) {
                _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                _mbProgressHUD.labelText = @"请录入语音后再上传";
                _mbProgressHUD.mode = MBProgressHUDModeText;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
//                        //原来的位置 设定 原来的位置的 中间位置 往上边移动 一点
//                        _contentView.center = CGPointMake(winSize.size.width / 2, _originPoint.y);
//                    } completion:^(BOOL finished) {
//                    }];
                });
            }else {
                // 启动上传
                _codiaService = [CodiaService sharedInstance];
                NSString * stringUrl = [_tmpFile absoluteString];
//                NSString * uploadKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"key"];
                NSString * uploadKey = self.codiaNumber;
                _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                _mbProgressHUD.mode = MBProgressHUDModeIndeterminate;
                _mbProgressHUD.labelText = @"正在上传";
                [_codiaService uploadRecordKey:uploadKey fileUrl:stringUrl DTZSuccessBlock:^(NSDictionary *successBlock) {
                    NSLog(@"上传成功");
                    _mbProgressHUD.labelText = @"上传成功";
                    _mbProgressHUD.mode = MBProgressHUDModeText;
                    [_timer invalidate];
                    _isFinishUpload = YES;
                    _inputTextField.font = [UIFont systemFontOfSize:20];
                    _inputTextField.text = [NSString stringWithFormat:@"%d”",(int)_avPlayer.duration];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        // Do something...
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"UploadSuccess" object:self.codiaNumber];
                        [[NSUserDefaults standardUserDefaults]setObject:self.codiaNumber forKey:@"codiaNumber"];
                        [[NSUserDefaults standardUserDefaults]setObject:@"Success" forKey:@"uploadState"];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } DTZFailBlock:^(NSDictionary *failBlock) {
                    NSLog(@"网络故障 上传失败");
                    [[NSUserDefaults standardUserDefaults]setObject:self.codiaNumber forKey:@"codiaNumber"];
                    [[NSUserDefaults standardUserDefaults]setObject:@"Fail" forKey:@"uploadState"];
                    _mbProgressHUD.mode = MBProgressHUDModeText;
                    _mbProgressHUD.labelText = @"网络故障";
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                }];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
//                        //原来的位置 设定 原来的位置的 中间位置 往上边移动 一点
//                        _contentView.center = CGPointMake(winSize.size.width / 2, _originPoint.y);
//                    } completion:^(BOOL finished) {
//                    }];
                });
            }
        }
        else{

        }
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            _contentView.center = CGPointMake(winWidth/2, winSize.size.height/2 - 60);
        } completion:^(BOOL finished) {
            NSLog(@"手势结束");
        }];
        
    }
}

#pragma mark - tapGesture
- (void)setTapGesture {
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapGesture {
    _topTextView.selectable = NO;
    [_topTextView resignFirstResponder];
}

#pragma mark - setupSwipeGesture 

- (void)setupSwipeGesture {

}

#pragma mark - 上传语音
- (void)uploadVoice {
    if (_isRecord) {
        NSString * stringUrl = [_tmpFile absoluteString];
        NSString * uploadKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"key"];
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.mode = MBProgressHUDModeIndeterminate;
        _mbProgressHUD.labelText = @"正在上传";
        [_codiaService uploadRecordKey:uploadKey fileUrl:stringUrl DTZSuccessBlock:^(NSDictionary *successBlock) {
            NSLog(@"上传成功");
            _mbProgressHUD.labelText = @"上传成功";
            _mbProgressHUD.mode = MBProgressHUDModeText;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        } DTZFailBlock:^(NSDictionary *failBlock) {
            NSLog(@"网络故障 上传失败");
            _mbProgressHUD.mode = MBProgressHUDModeText;
            _mbProgressHUD.labelText = @"网络故障";
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    }else {
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.labelText = @"请录入语音再上传";
    }
}

#pragma mark - 重置语音
- (void)resetRecord {
    _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _mbProgressHUD.labelText = @"重置语音成功";
    _mbProgressHUD.mode = MBProgressHUDModeText;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    _tmpFile = nil;
    [self setRecordScheme];
    _isRecord = NO;
    [_playBtn removeTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setPlayScheme {
    _playSchemeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playSchemeTimer) userInfo:nil repeats:YES];
//    [_playSchemeTimer invalidate];
    [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
    [self setupPlaySchemeDataSource];
    [_playBtn addTarget:self action:@selector(playSchemeClickPlay) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playSchemeTimer {
    
    if (_isFinishUpload) {
        
    }else {
        if (self.isPlayScheme) {
            if (_shouldShowTotalSec) {
                if (_avPlayer.duration == 0) {
                    return;
                }
                NSLog(@"%f",_avPlayer.duration);
                _inputTextField.text = [NSString stringWithFormat:@"%d“",(int)_avPlayer.duration];
            }else {
                _inputTextField.font = [UIFont systemFontOfSize:22];
                NSLog(@"还在计算");
                if ( _avPlayer.currentTime == _avPlayer.duration - 1) {
                    _shouldTurnZero = NO;
                }
                if (!_shouldTurnZero && _avPlayer.currentTime == 0) {
                    _shouldTurnZero = YES;
                    return;
                }
                _inputTextField.text = [NSString stringWithFormat:@"%d“",(int)_avPlayer.currentTime];
            }
        }else {
            if (_isNewPlaying) {
                _inputTextField.font = [UIFont systemFontOfSize:22];
                _playSchemeSecondCount ++;
                _inputTextField.text = [NSString stringWithFormat:@"%d“",(int)_avPlayer.currentTime];
            }else {
                _inputTextField.text = @"下拉进行重新录制，上拉完成录制上传";
                _inputTextField.font = [UIFont systemFontOfSize:14];
            }
        }
    }
}

- (void)setupPlaySchemeDataSource {
    NSError * error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    _avPlayer = [[AVAudioPlayer alloc]initWithData:self.voiceData error:nil];
    _avPlayer.delegate = self;
}

- (void)playSchemeClickPlay {
    _shouldShowTotalSec = NO;
    [_playSchemeTimer invalidate];
    _playSchemeTimer = nil;
    _playSchemeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playSchemeTimer) userInfo:nil repeats:YES];
    if (!_isPlaySchemePlaying) {
        _isPlaySchemePlaying = YES;
        [_playBtn setImage:[UIImage imageNamed:@"Btn4"] forState:UIControlStateNormal];
        [_avPlayer play];
    }else {
        _isPlaySchemePlaying = NO;
        [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
        [_avPlayer pause];
    }
}

#pragma mark - setupRecordScheme
- (void)setRecordScheme {
    // 设置 btn 样式 和设置btn的 addtarget
    [_playBtn addTarget:self action:@selector(recordSchemeOnClick) forControlEvents:UIControlEventTouchDown];
    [_playBtn setImage:[UIImage imageNamed:@"Btn1"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"Btn2"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(recordSchemeTouchUpinside) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn addTarget:self action:@selector(recordSchemeDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [_playBtn addTarget:self action:@selector(recordSchemeDragExit) forControlEvents:UIControlEventTouchDragExit];
}

- (void)recordSchemeOnClick {
    
    NSLog(@"点击了");
    
    _contentView.hidden = NO;
    
    [self setupAudioPlayer];
    [self recordTimerBegin];
}

- (void)recordSchemeTouchUpinside {
    
    NSLog(@"离开了");
    
    [_audioPlayer stop];
   
}

- (void)recordSchemeDragExit {
    NSLog(@"DragExit");
}

- (void)recordSchemeDragOutside {
    [_audioPlayer stop];
    NSLog(@"DragOutside");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"ssssss");
    _shouldShowTotalSec = YES;
    if (_isPlayScheme) {
        _isPlaySchemePlaying = NO;
//        _inputTextField.text = @"0“";
        [self setupPlaySchemeDataSource];
        _inputTextField.text = [NSString stringWithFormat:@"%d“",(int)_avPlayer.duration];
        [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
        [_playSchemeTimer invalidate];
        _playSchemeTimer = nil;
    }else {
        _isNewPlaying = NO;
        _inputTextField.text = @"下拉进行重新录制，上拉完成录制上传";
        _inputTextField.font = [UIFont systemFontOfSize:14];
        _isRecordSchemePlaying = NO;
        [self setupPlay];
//        _inputTextField.text = @"0“";
        [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
        [_playSchemeTimer invalidate];
        _playSchemeTimer = nil;
        _playSchemeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playSchemeTimer) userInfo:nil repeats:YES];
    }
}

- (void)playRecord {
//    _inputTextField.font = [UIFont systemFontOfSize:16];
    if (!_isRecordSchemePlaying) {
        _isRecordSchemePlaying = YES;
        [_playBtn setImage:[UIImage imageNamed:@"Btn4"] forState:UIControlStateNormal];
        [_avPlayer play];
    }else {
        _isRecordSchemePlaying = NO;
        [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
        [_avPlayer pause];
    }
    _isNewPlaying = YES;
}

- (void)setupPlay {
    NSError * error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    _avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:_tmpFile error:&error];
    _avPlayer.delegate = self;
    _avPlayer.volume = 1;
    if (error) {
        NSLog(@"DTZ 有毒");
        return;
    }
}

- (void)recordTimerBegin {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeLabelText) userInfo:nil repeats:YES];
}

- (void)changeLabelText {
    
    NSLog(@"录音部分的timer %d",_secondCount);
    
    _secondCount ++;
    _inputTextField.text = [NSString stringWithFormat:@"%d“",_secondCount];
    if (_secondCount == 30) {
        _secondCount = 0;
        [_audioPlayer stop];
        _inputTextField.text = 0;
        [_timer fire];
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - 初始化 录音器
- (void)setupAudioPlayer {
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
    NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: 44100.0],AVSampleRateKey, [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey, [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey, [NSNumber numberWithInt: 2], AVNumberOfChannelsKey, [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey, [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
    _tmpFile = [NSURL fileURLWithPath:
               [NSTemporaryDirectory() stringByAppendingPathComponent:
                [NSString stringWithFormat: @"%@.%@",
                 @"wangshuo",
                 @"caf"]]];
    _audioPlayer = [[AVAudioRecorder alloc]initWithURL:_tmpFile settings:setting error:nil];
    [_audioPlayer setDelegate:self];
    [_audioPlayer prepareToRecord];
    [_audioPlayer record];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"%@",recorder.url);
    _tmpFile = recorder.url;
    _isRecord = YES;
//    _timer
    [_timer invalidate];
    _timer = nil;
    _inputTextField.text = @"0“";

    AVAudioPlayer * player = [[AVAudioPlayer alloc]initWithContentsOfURL:_tmpFile error:nil];
    NSLog(@"%f",player.duration);
    
    if (player.duration <= 3) {
        _secondCount = 0;
        _tmpFile = nil;
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _mbProgressHUD.mode = MBProgressHUDModeText;
        _mbProgressHUD.labelText = @"录音时间不能短于3秒";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }else {
        [self setupPlay];
        [_playBtn removeTarget:self action:@selector(recordSchemeOnClick) forControlEvents:UIControlEventTouchDown];
        [_playBtn removeTarget:self action:@selector(recordSchemeTouchUpinside) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"Btn3"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        _playSchemeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playSchemeTimer) userInfo:nil repeats:YES];

        _inputTextField.text = @"下拉进行重新录制，上拉完成录制上传";
        _inputTextField.font = [UIFont systemFontOfSize:14];
    }
    
   
    
}

@end
