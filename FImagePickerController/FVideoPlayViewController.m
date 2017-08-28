//
//  FVideoPlayViewController.m
//  FImagePickerController
//
//  Created by FYXin on 2017/7/27.
//  Copyright © 2017年 FYXin. All rights reserved.
//

#import "FVideoPlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FAssetModel.h"
#import "FImageManager.h"
#import "FImagePickerController.h"

@interface FVideoPlayViewController ()
{
    AVPlayer *_player;
    AVPlayerLayer *_playerlayer;
    UIButton *_playButton;
    UIImage *_coverImage;
    
    UIView *_toolBar;
    UIButton *_doneButton;
    
    UIProgressView *_progress;
    
    UIStatusBarStyle _originStatusBarStyle;
    
}
@end

@implementation FVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    FImagePickerController *FImagePickVC = (FImagePickerController *)self.navigationController;
    
    
    [self configPlayer];
}


- (void)configPlayer {
    [[FImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _coverImage = photo;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
