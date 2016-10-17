//
//  FAssetModel.h
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  NS_ENUM(NSUInteger,FAssetModelMediaType) {
    FAssetModelMediaTypePhoto = 0,
    FAssetModelMediaTypeLivePhoto,
    FAssetModelMediaTypeVideo,
    FAssetModelMediaTypeAudio
};

@class PHAsset;

@interface FAssetModel : NSObject

// <PHAsset  或者 ALAsset>
@property (nonatomic,strong) id asset;

/*
 * 是否被选中
 */

@property (nonatomic,assign) BOOL isSeledted;

/*
 * 表示被选中的顺序，用来做标记
 */
@property (nonatomic,assign) NSInteger selectedIndex;

@property (nonatomic,assign) FAssetModelMediaType type;

/*
 * 如果文件类型是视频，表示视频的时间，其它情况则为nil
 */

@property (nonatomic,copy) NSString *timeLength;


/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(FAssetModelMediaType)type;

+ (instancetype)modelWithAsset:(id)asset type:(FAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end




@class PHFetchResult;

@interface FAlbumModel : NSObject

//相册名称
@property (nonatomic,strong) NSString *name;

//相册资源数
@property (nonatomic,assign) NSUInteger count;


//相册
@property (nonatomic, strong) id result;             //< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

//保存的资源数组
@property (nonatomic, strong) NSArray *assetModels;
//被选中的资源
@property (nonatomic, strong) NSArray *selectedAssetModels;
//被选中的资源数
@property (nonatomic, assign) NSUInteger selectedAssetCount;

@end
