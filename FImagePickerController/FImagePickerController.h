//
//  FImagePickerController.h
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAssetModel.h"

@protocol FImagePickerControllerDelegate;

@interface FImagePickerController : UINavigationController


//  初始化方法
- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount
                             delegate:(id<FImagePickerControllerDelegate>)delegate;

- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount
                         columnNumber:(NSInteger)columnNumber
                             delegate:(id<FImagePickerControllerDelegate>)delegate;


- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets
                        selectedPhotos:(NSMutableArray *)selectedPhotos
                                 index:(NSInteger)index;

// 最大可选照片数 ，默认为9
@property (nonatomic,assign) NSInteger maxImagesCount;

//是否按修改时间升序排列，默认为YES，最新的照片在最后面，拍照按钮也在最后面
@property (nonatomic,assign) BOOL sortAsendingByModificationDate;

//是否允许选择原图
@property (nonatomic,assign) BOOL allowPickingOriginalPhoto;
//是否已经选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, assign) BOOL allowPickingVideo;

@property (nonatomic, assign) BOOL allowPickingImage;

@property (nonatomic,assign) BOOL allowTakePhoto;


//选择图片后是否允许自动消失,默认为YES
@property (nonatomic,assign) BOOL autoDismiss;

@property (nonatomic,strong) NSMutableArray<FAssetModel *> *selectedAssetModels;


@property (nonatomic,copy) void(^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);


@property (nonatomic,weak) id<FImagePickerControllerDelegate> pickerDelegate;

@end


@protocol FImagePickerControllerDelegate <NSObject>

- (void)imagePickerController:(FImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets;

- (void)imagePickerController:(FImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectedOriginalPhoto infos:(NSArray<NSDictionary *>*)infos;


@end





#pragma mark - FAlbumPickerController

@interface FAlbumPickerController : UIViewController

@property (nonatomic,assign) NSUInteger columnNumber;

@end
