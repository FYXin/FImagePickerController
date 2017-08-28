//
//  FImagePreviewController.m
//  FImagePickerController
//
//  Created by  apple on 16/9/26.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "FImagePreviewController.h"
#import "FImagePickerController.h"
#import "UIView+frame.h"
#import "FImageManager.h"
#import "FImagePickerConfig.h"
#import "FAssetModel.h"
#import "FImagePreviewCell.h"

@interface FImagePreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    
    
    UIView      *_customNavView;
    UILabel     *_indexLabel;
    UIButton    *_selectedButton;
    
    UIView      *_bottomView;
    UIButton    *_originalPhotoButton;
    UILabel     *_originalPhotoLabel;
    UIButton    *_okButton;
}

@end

@implementation FImagePreviewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0)];
    }
    [self refreshCustomNavBarAndBottomView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCollectionView];
    [self configCustomNavigationView];
    [self configBottomView];
}


- (void)configCollectionView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource  =self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[FImagePreviewCell class] forCellWithReuseIdentifier:@"FImagePreviewCell"];
    [self.view addSubview:_collectionView];
}

- (void)configCustomNavigationView {
    _customNavView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    _customNavView.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    [self.view addSubview:_customNavView];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 44, 44)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [_customNavView addSubview:backButton];
    
    _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(backButton.right, 20, self.view.width - 2 * backButton.right, 44)];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.font = [UIFont boldSystemFontOfSize:18];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    [_customNavView addSubview:_indexLabel];
    
    _selectedButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 35, 27, 25, 25)];
    _selectedButton.centerY = _indexLabel.centerY;
    _selectedButton.backgroundColor = [UIColor clearColor];
    _selectedButton.layer.cornerRadius = _selectedButton.height / 2;
    _selectedButton.layer.masksToBounds = YES;
    _selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _selectedButton.layer.borderWidth = 1;
    _selectedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_selectedButton addTarget:self action:@selector(selectedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_customNavView addSubview:_selectedButton];
}

- (void)configBottomView {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
   
    if (FImagePickerVC.allowPickingOriginalPhoto) {
        NSString *fullImageText = @"原图";
        CGFloat fullImageWidth = [fullImageText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(20, 0, fullImageWidth + 26, bottomView.height);
        _originalPhotoButton.centerY = bottomView.height / 2;
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalPhotoButton setTitle:fullImageText forState:UIControlStateNormal];
        
        [_originalPhotoButton setTitleColor:MainColorForSelected forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:MainColorForSelected forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 26, 0, 80, bottomView.height);
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
    _okButton.centerY = bottomView.height / 2 + 1;
    _okButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _okButton.layer.cornerRadius = 3;
    
    [_okButton addTarget:self action:@selector(previewOKButtonClick) forControlEvents:UIControlEventTouchUpInside];
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
    
    [bottomView addSubview:_okButton];
    
    [bottomView addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)originalPhotoButtonClick {
    FImagePickerController *FImagePickerVc = (FImagePickerController *)self.navigationController;
    FImagePickerVc.isSelectOriginalPhoto = !FImagePickerVc.isSelectOriginalPhoto;
    if (FImagePickerVc.isSelectOriginalPhoto) {
        _originalPhotoLabel.hidden = NO;
        [self getSelectedPhotoBytes];
    } else {
        _originalPhotoLabel.hidden = YES;
    }
}

- (void)previewOKButtonClick {
    
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    for (NSInteger i = 0; i < FImagePickerVC.selectedAssetModels.count; i++) {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
    }
    
    
    for (NSInteger i = 0; i < FImagePickerVC.selectedAssetModels.count; i++) {
        
        FAssetModel *model = FImagePickerVC.selectedAssetModels[i];
        [[FImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return ;
            if (photo) {
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            
            if (info) {
                [infoArr replaceObjectAtIndex:i withObject:info];
                [assets replaceObjectAtIndex:i withObject:model.asset];
            }
            
            for (id item in photos) {
                if ([item isKindOfClass:[NSNumber class]]) {
                    return;
                }
            }
            
            
            if ([FImagePickerVC.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:)]) {
                [FImagePickerVC.pickerDelegate imagePickerController:FImagePickerVC didFinishPickingPhotos:photos sourceAssets:assets];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            
            if ([FImagePickerVC.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets: isSelectOriginalPhoto:infos:)]) {
                [FImagePickerVC.pickerDelegate imagePickerController:FImagePickerVC didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:FImagePickerVC.isSelectOriginalPhoto infos:infoArr];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        }];
    }
}

- (void)selectedButtonClick:(UIButton *)button {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    
    FAssetModel *model = _models[_currentIndex];
    if (model.selectedIndex > 0) {
        NSInteger index = model.selectedIndex;
        model.selectedIndex = 0;
        [FImagePickerVC.selectedAssetModels removeObject:model];

        NSArray *selectedModels = [NSArray arrayWithArray:FImagePickerVC.selectedAssetModels];
        for (FAssetModel *model_item in selectedModels) {
            if (model_item.selectedIndex > index) {
                model_item.selectedIndex -= 1;
            }
        }
        
    } else {
        model.selectedIndex = FImagePickerVC.selectedAssetModels.count + 1;
        [FImagePickerVC.selectedAssetModels addObject:model];
    }
    [self refreshCustomNavBarAndBottomView];
}

- (void)getSelectedPhotoBytes {
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    [[FImageManager manager] getPhotoBytesWithArray:FImagePickerVC.selectedAssetModels completion:^(NSString *totalBytes) {
        _originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

- (void)refreshCustomNavBarAndBottomView {
    _indexLabel.text = [NSString stringWithFormat:@"%zd/%zd",_currentIndex+1,_models.count];
    
    FAssetModel *model = _models[_currentIndex];
    if (model.isSelected) {
        _selectedButton.selected = YES;
        [_selectedButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedIndex] forState:UIControlStateSelected];
        _selectedButton.backgroundColor = MainColorForSelected;
    } else {
        _selectedButton.selected = NO;
        [_selectedButton setTitle:@"" forState:UIControlStateNormal];
        _selectedButton.backgroundColor = [UIColor clearColor];
    }
    
    
    FImagePickerController *FImagePickerVC = (FImagePickerController *)self.navigationController;
    BOOL valiable = FImagePickerVC.selectedAssetModels.count > 0;
    
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth + ((self.view.width) + 20) * 0.5;
    NSInteger index = offSetWidth / (self.view.width + 20);
    if (_currentIndex != index) {
        _currentIndex = index;
        [self refreshCustomNavBarAndBottomView];
    }
}


#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FImagePreviewCell" forIndexPath:indexPath];
    cell.model = _models[indexPath.row];
    
    cell.SingleTapGestureBlock = ^(){
        _customNavView.hidden = !_customNavView.hidden;
        _bottomView.hidden = !_bottomView.hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:_customNavView.hidden];
    };
    return cell;
}

- (void)dealloc {
    NSLog(@"%@销毁",NSStringFromClass([self class]));
}

@end
