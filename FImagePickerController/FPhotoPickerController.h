//
//  FPhotoPickerController.h
//  FImagePickerController
//
//  Created by  apple on 16/9/22.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAlbumModel;

@interface FPhotoPickerController : UIViewController
/**每行展示的照片数量*/
@property (nonatomic,assign) NSInteger columnNumber;
@property (nonatomic,strong) FAlbumModel *albumModel;

@end
