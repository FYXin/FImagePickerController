//
//  FAssetModel.m
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "FAssetModel.h"
#import "FImageManager.h"

@implementation FAssetModel

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_selected == NO) {
        _selectedIndex = 0;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (_selectedIndex > 0) {
        _selected = YES;
    }
}


+ (instancetype)modelWithAsset:(id)asset type:(FAssetModelMediaType)type {
    FAssetModel *model = [[FAssetModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.selected = NO;
    
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(FAssetModelMediaType)type timeLength:(NSString *)timeLength {
    FAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    
    return model;
}

@end



@implementation FAlbumModel

- (void)setResult:(id)result {
    _result = result;
    
    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"F_allowPickingImage"] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"F_allowPickingVideo"] isEqualToString:@"1"];
    [[FImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<FAssetModel *> *models) {
        _assetModels = models;
        if (_selectedAssetModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void)setSelectedAssetModels:(NSArray *)selectedAssetModels {
    _selectedAssetModels = selectedAssetModels;
    if (_assetModels) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedAssetCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (FAssetModel *model in _selectedAssetModels) {
        [selectedAssets addObject:model.asset];
    }
    for (FAssetModel *model in _assetModels) {
        if ([[FImageManager manager] isAssetArray:selectedAssets containAsset:model.asset]) {
            self.selectedAssetCount++;
        }
    }
}

@end
