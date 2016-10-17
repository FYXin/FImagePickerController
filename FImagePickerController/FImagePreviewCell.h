//
//  FImagePreviewCell.h
//  FImagePickerController
//
//  Created by  apple on 16/9/26.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAssetModel;
@interface FImagePreviewCell : UICollectionViewCell

@property (nonatomic,strong) FAssetModel *model;
@property (nonatomic,  copy) void (^SingleTapGestureBlock)();

@end
