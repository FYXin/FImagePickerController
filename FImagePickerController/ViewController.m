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
{
    UIScrollView *_scrollView;
}
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
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, 300)];
    //
    [self.view addSubview:_scrollView];
}

- (void)imagePickerController:(FImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectedOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    int i = 0;
    for (UIImage *image in photos) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(300*i++, 0, 300, 300)];
        imageView.image = image;
        [_scrollView addSubview:imageView];
        NSLog(@"%@",infos[i-1]);
    }
    
    _scrollView.contentSize = CGSizeMake(300 * photos.count, 0);
}

@end
