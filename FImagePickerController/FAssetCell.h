//
//  FAssetCell.h
//  FImagePickerController
//
//  Created by  apple on 16/9/22.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef  NS_ENUM(NSUInteger,FAssetCellMediaType) {
    FAssetCellMediaTypePhoto = 0,
    FAssetCellMediaTypeLivePhoto,
    FAssetCellMediaTypeVideo,
    FAssetCellMediaTypeAudio
};

@class FAssetModel;
@interface FAssetCell : UICollectionViewCell

@property (nonatomic,strong) FAssetModel *assetModel;
@property (nonatomic,assign) FAssetCellMediaType type;
@property (nonatomic,copy)   NSString *representedAssetIdentifier;
@property (nonatomic,assign)   PHImageRequestID imageRequestID;
 

@property (nonatomic,copy) void (^didSelectedPhotoBlock)(BOOL,UIButton *);

- (void)setTakePhotoImage:(UIImage *)image;

@end

@class FAlbumModel;

@interface FAlbumCell : UITableViewCell

@property (nonatomic,strong) FAlbumModel *model;

@property (nonatomic,weak) UIButton *selectedCountButton;

@end
