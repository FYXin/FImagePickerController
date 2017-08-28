//
//  FImageManager.h
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class FAlbumModel,FAssetModel;
@interface FImageManager : NSObject

@property (nonatomic,strong) PHCachingImageManager *cachingImageeManager;

@property (nonatomic,assign) NSUInteger columnNumber;

@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

+ (instancetype)manager;

//检测用户是否授权访问相册
- (BOOL)authorzationStatusAuthorized;


//获取相册数组
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(FAlbumModel *))completion;
- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<FAlbumModel *> *models))completion;


//获取Asset 数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<FAssetModel *> *models))completion;

//获取特定index的Asset
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(FAssetModel *model))completion;

//获取相册封面图片
- (void)getPostImageWithAlbumModel:(FAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

- (void)getPhotoBytesWithArray:(NSArray *)assets completion:(void (^)(NSString *totalBytes))completion;

- (BOOL)isAssetArray:(NSArray *)assets containAsset:(id)asset;

- (NSString *)getAssetIdentifier:(id)asset;

- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

/// Save photo 保存照片
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion;
@end
