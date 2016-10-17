//
//  FPhotoPickerController.m
//  FImagePickerController
//
//  Created by  apple on 16/9/22.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "FPhotoPickerController.h"
#import "FImagePickerController.h"
#import "FImagePreviewController.h"
#import "FAssetModel.h"
#import "FAssetCell.h"
#import "UIView+frame.h"
#import "FImageManager.h"
#import "FImagePickerConfig.h"

@interface FPhotoPickerController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UIButton *_previewButton;           //预览按钮
    UIButton *_originalPhotoButton;     //原图按钮
    UILabel  *_originalPhotoLabel;
    
    UIButton    *_okButton;
}
//是否选择原图
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *assetModels;
@property (nonatomic,strong) UIImagePickerController *imagePickerVC;

@end

@implementation FPhotoPickerController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_collectionView reloadData];
    [self refreshBottomToolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _albumModel.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    _assetModels = [NSMutableArray arrayWithArray:_albumModel.assetModels];
    [self initSubViews];
}

- (void)initSubViews {
    [self checkSelectedModels];
    [self configCollectionView];
    [self configBottomToolBar];
}

- (void)checkSelectedModels {
    for (FAssetModel *model in _assetModels) {
        NSMutableArray *selectedModels = [NSMutableArray array];
        FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
        
    }
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    self.columnNumber = 4;
    CGFloat itemWH = (self.view.width - (self.columnNumber + 1) * margin) / self.columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    
    CGFloat top = 44;
    if (iOS7Later) top += 20;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height- top - 50) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[FAssetCell class] forCellWithReuseIdentifier:@"FAssetCell"];
}

- (void)configBottomToolBar {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 44)];
    CGFloat rgb = 253 / 255.0;
    bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    NSString *previewText = @"预览";
    CGFloat previewWidth = [previewText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(10, 0, previewWidth+2, 44);
    _previewButton.centerY = bottomToolBar.height / 2 + 1;
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_previewButton setTitle:previewText forState:UIControlStateNormal];
    [_previewButton setTitle:previewText forState:UIControlStateDisabled];
    [_previewButton setTitleColor:MainColorForSelected forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = FImagePickerVC.selectedAssetModels.count;
    
    if (FImagePickerVC.allowPickingOriginalPhoto) {
        NSString *fullImageText = @"原图";
        CGFloat fullImageWidth = [fullImageText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), 0, fullImageWidth + 56, bottomToolBar.height);
        _originalPhotoButton.centerY = _previewButton.centerY;
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalPhotoButton setTitle:fullImageText forState:UIControlStateNormal];
        
        [_originalPhotoButton setTitleColor:MainColorForSelected forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:MainColorForSelected forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, bottomToolBar.height);
        _originalPhotoLabel.centerY = _originalPhotoButton.centerY;
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:14];
        _originalPhotoLabel.textColor = [UIColor blackColor];
        if (FImagePickerVC.isSelectOriginalPhoto && FImagePickerVC.selectedAssetModels.count > 0) {
            // 获取原图大小
            _originalPhotoButton.enabled = YES;
            _originalPhotoButton.selected = YES;
            [self getSelectedPhotoBytes];
        } else {
            _originalPhotoButton.enabled = NO;
        }
    }
    
    //OK  按钮
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(self.view.width- 80 - 12, 4, 80, 35);
    _okButton.centerY = bottomToolBar.height / 2 + 1;
    _okButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _okButton.layer.cornerRadius = 3;
    
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"完成" forState:UIControlStateNormal];
    [_okButton setTitle:@"完成" forState:UIControlStateDisabled];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _okButton.enabled = FImagePickerVC.selectedAssetModels.count;
    if (_okButton.enabled) {
        _okButton.backgroundColor = MainColorForSelected;
    } else {
        _okButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
    
    
    //顶部细线
    UIView *line = [[UIView alloc] init];
    CGFloat rgb2 = 222/255.0;
    line.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    line.frame = CGRectMake(0, 0, self.view.width, 1);
    
    [bottomToolBar addSubview:line];
    [bottomToolBar addSubview:_previewButton];
    [bottomToolBar addSubview:_okButton];
   
    [bottomToolBar addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    [self.view addSubview:bottomToolBar];
}

- (void)getSelectedPhotoBytes {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    [[FImageManager manager] getPhotoBytesWithArray:FImagePickerVC.selectedAssetModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 点击预览按钮
- (void)previewButtonClick {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    FImagePreviewController *previewVC = [[FImagePreviewController alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:FImagePickerVC.selectedAssetModels];
    previewVC.models = array;
    [self.navigationController pushViewController:previewVC animated:YES];
    
}

//选择原图按钮
- (void)originalPhotoButtonClick {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    FImagePickerVC.isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (FImagePickerVC.isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

//点击完成按钮
- (void)okButtonClick {
    NSLog(@"完成");
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    FAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FAssetCell" forIndexPath:indexPath];
    FAssetModel *model = _assetModels[indexPath.row];
    cell.assetModel = model;
    __weak typeof(self) weakSelf = self;
 //   __weak typeof(cell) weakCell = cell;
    
    cell.didSelectedPhotoBlock = ^(BOOL isSelected,UIButton *selectedButton){
        [weakSelf changeSelectedButton:selectedButton WithModel:model];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  //  FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    FImagePreviewController *imagePreviewVC = [[FImagePreviewController alloc] init];
    imagePreviewVC.currentIndex = indexPath.row;
    imagePreviewVC.models = _assetModels;
    [self.navigationController pushViewController:imagePreviewVC animated:YES];
}


- (void)changeSelectedButton:(UIButton *)button WithModel:(FAssetModel *)model {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    if (button.isSelected) {
        if (FImagePickerVC.selectedAssetModels.count < FImagePickerVC.maxImagesCount) {
             model.isSeledted = YES;
            model.selectedIndex = FImagePickerVC.selectedAssetModels.count + 1;
            [FImagePickerVC.selectedAssetModels addObject:model];
            [self changeSlectedButtonNumber:button WithModel:model];
            [self refreshBottomToolBar];
        } else {
            NSString *title = [NSString stringWithFormat:@"最多允许选择%zd张照片",FImagePickerVC.maxImagesCount];
            [self showAlertWithTitle:title];
        }
    } else {
        NSInteger index = model.selectedIndex;
        model.isSeledted = NO;
        [FImagePickerVC.selectedAssetModels removeObject:model];
        [self changeSlectedButtonNumber:button WithModel:model];
        NSArray *selectedModels = [NSArray arrayWithArray:FImagePickerVC.selectedAssetModels];
        for (FAssetModel *model_item in selectedModels) {
            if (model_item.selectedIndex > index) {
                model_item.selectedIndex -= 1;
            }
        }
        [_collectionView reloadData];
        [self refreshBottomToolBar];
    }
}

- (void)changeSlectedButtonNumber:(UIButton *)button WithModel:(FAssetModel *)model {
    if (model.selectedIndex != 0) {
        [button setTitle:[NSString stringWithFormat:@"%zd",model.selectedIndex] forState:UIControlStateNormal];
        button.backgroundColor = MainColorForSelected;
        [UIView showOscillatoryAnimationWithLayer:button.layer];
    } else {
        [button setTitle:@"" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
    }
}


- (void)refreshBottomToolBar {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    BOOL valiable = FImagePickerVC.selectedAssetModels.count > 0;
    
    _previewButton.enabled = valiable;
    _okButton.enabled = valiable;
    
    _originalPhotoButton.enabled = FImagePickerVC.selectedAssetModels.count > 0;
    _originalPhotoButton.selected = (FImagePickerVC.isSelectOriginalPhoto && _originalPhotoButton.enabled);
    
    if (_okButton.enabled) {
        _okButton.backgroundColor = MainColorForSelected;
        [_okButton setTitle:[NSString stringWithFormat:@"完成(%zd)",FImagePickerVC.selectedAssetModels.count] forState:UIControlStateNormal];
    } else {
        _okButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
    
    _originalPhotoLabel.hidden = !(_originalPhotoButton.isSelected && _originalPhotoButton.enabled);
    if (FImagePickerVC.isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
    
}

- (void)showAlertWithTitle:(NSString *)title {

}
@end
