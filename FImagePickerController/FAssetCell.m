//
//  FAssetCell.m
//  FImagePickerController
//
//  Created by  apple on 16/9/22.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "FAssetCell.h"
#import "UIView+frame.h"
#import "FAssetModel.h"
#import "FImageManager.h"
#import "FImagePickerConfig.h"


@interface FAssetCell ()

@property (nonatomic,weak) UIImageView *imageView;
@property (nonatomic,weak) UIImageView *selectImageView;
@property (nonatomic,weak) UIButton *selectPhotoButton;;
@property (nonatomic,weak) UIView *bottomView;
@property (nonatomic,weak) UIImageView *iconImageView;
@property (nonatomic,weak) UILabel *timeLengthLabel;

@end

@implementation FAssetCell


// 当用register class 的方法注册cell的时候会调用这个方法初始化cell  所以需要设置默认属性的时候重写这个方法就行了
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    
    return self;
}


- (void)initSubViews {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    UIButton *selectedButton = [[UIButton alloc] init];
    selectedButton.frame = CGRectMake(self.width * 0.65, 5, self.width * 0.3, self.width * 0.3);
    selectedButton.layer.cornerRadius = selectedButton.height / 2;
    selectedButton.layer.masksToBounds = YES;
    selectedButton.layer.borderWidth = 1;
    selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    selectedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    selectedButton.backgroundColor = [UIColor clearColor];
    [selectedButton addTarget:self action:@selector(selectedPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.contentView addSubview:selectedButton];
    _selectPhotoButton = selectedButton;
}

- (void)setAssetModel:(FAssetModel *)assetModel {
    _assetModel = assetModel;
    [self cinfigSelectedButton];
    if (iOS8Later) {
        [[FImageManager manager] getAssetIdentifier:_assetModel.asset];
    }
    
    PHImageRequestID imageRequestID = [[FImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
         _imageView.image = photo;
    }];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = _assetModel.isSeledted;
    self.selectImageView.image = _assetModel.isSeledted ? [UIImage imageNamed:PhotoSelectedImageName] : [UIImage imageNamed:PhotoNornalImageName];
    self.type = FAssetCellMediaTypePhoto;
    if (assetModel.type == FAssetModelMediaTypeLivePhoto) {
        self.type = FAssetCellMediaTypeLivePhoto;
    } else if (assetModel.type == FAssetModelMediaTypeAudio) {
        self.type = FAssetCellMediaTypeAudio;
    } else if (assetModel.type == FAssetModelMediaTypeVideo) {
        self.type = FAssetCellMediaTypeVideo;
    }
}


- (void)cinfigSelectedButton {
    if (_assetModel.isSeledted && _assetModel.selectedIndex > 0) {
        [_selectPhotoButton setTitle:[NSString stringWithFormat:@"%zd",_assetModel.selectedIndex] forState:UIControlStateNormal];
        _selectPhotoButton.backgroundColor = [UIColor colorWithRed:46/255.0 green:178/255.0 blue:242/255.0 alpha:1];
    } else {
        [_selectPhotoButton setTitle:@"" forState:UIControlStateNormal];
        _selectPhotoButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)selectedPhotoButtonClick:(UIButton *)button {
  
    button.selected = !button.isSelected;
    if (self.didSelectedPhotoBlock) self.didSelectedPhotoBlock(button.isSelected,button);
}


#pragma mark - 懒加载
//- (UIButton *)selectPhotoButton {
//    if (_selectImageView == nil) {
//        UIButton *selectedPhotoButton = [[UIButton alloc] init];
//        selectedPhotoButton.frame = CGRectMake(44, 0, 44, 44);
//        [selectedPhotoButton addTarget:self action:@selector(selectedPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:selectedPhotoButton];
//        _selectPhotoButton = selectedPhotoButton;
//    }
//    return _selectPhotoButton;
//}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.width, self.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        [self.contentView bringSubviewToFront:_selectImageView];
    }
    return _imageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.height - 17, self.width, 17);
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.8;
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(8, 0, 17, 17);
        imageView.backgroundColor = [UIColor redColor];
        [self.bottomView addSubview:imageView];
        _iconImageView = imageView;
    }
    return _iconImageView;
}

- (UILabel *)timeLengthLabel {
    if (_timeLengthLabel == nil) {
        UILabel *timeLengthLabel = [[UILabel alloc] init];
        timeLengthLabel.font = [UIFont systemFontOfSize:11];
        timeLengthLabel.frame = CGRectMake(self.iconImageView.right, 0, self.width - self.iconImageView.right - 5, 17);
        timeLengthLabel.textColor = [UIColor whiteColor];
        timeLengthLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:timeLengthLabel];
        _timeLengthLabel = timeLengthLabel;
    }
    return _timeLengthLabel;
}

@end


@interface FAlbumCell ()

@property (weak, nonatomic) UIImageView *posterImageView;//相册封面图片
@property (weak, nonatomic) UILabel *titleLable; //相册名称Label
@property (weak, nonatomic) UIImageView *arrowImageView;

@end

@implementation FAlbumCell

- (void)setModel:(FAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:_model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSMutableAttributedString *countString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
    [[FImageManager manager] getPostImageWithAlbumModel:_model completion:^(UIImage *postImage) {
        _posterImageView.image = postImage;
    }];
}

#pragma mark - 懒加载
- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, 70, 70);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLable {
    if (_titleLable == nil) {
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        titleLable.frame = CGRectMake(80, CGRectGetMidY(self.posterImageView.frame) - self.height / 2, self.width - 80 - 50, self.height);
        titleLable.textColor = [UIColor blackColor];
        titleLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLable];
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGFloat arrowWH = 15;
        arrowImageView.frame = CGRectMake(self.width - arrowWH - 12, 28, arrowWH, arrowWH);
        
        [self.contentView addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}



@end