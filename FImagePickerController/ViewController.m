//
//  ViewController.m
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "ViewController.h"
#import "FImagePickerController.h"


@interface ViewController ()<FImagePickerControllerDelegate>

@end

@implementation ViewController
- (IBAction)send:(id)sender {
    FImagePickerController *picker = [[FImagePickerController alloc] initWithMaxImageCount:9 columnNumber:4 delegate:self];
    picker.allowPickingImage = YES;
    picker.allowPickingVideo = YES;
    picker.allowPickingOriginalPhoto = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
