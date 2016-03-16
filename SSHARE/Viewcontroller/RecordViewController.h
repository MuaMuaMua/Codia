//
//  RecordViewController.h
//  SSHARE
//
//  Created by wuhaibin on 16/2/20.
//  Copyright © 2016年 wuhaibin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecordViewController : UIViewController

@property (strong, nonatomic) NSData * voiceData;
@property BOOL isPlayScheme;
- (void)setPlayScheme;
- (void)setRecordScheme;
@property (strong, nonatomic) NSString * codiaNumber;

@end
