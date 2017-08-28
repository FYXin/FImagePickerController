//
//  FImagePickerController.m
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import "FImagePickerController.h"
#import "FImageManager.h"
#import "UIView+frame.h"
#import "FAssetCell.h"
#import "FPhotoPickerController.h"
#import "FImagePickerConfig.h"

@interface FImagePickerController ()
{
    UILabel *_tipLabel;
    UIButton *_settingButton;
    NSTimer *_timer;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle; //保存初始状态栏样式
}

@property (nonatomic,assign) NSUInteger columnNumber;
@end

@implementation FImagePickerController
- (NSMutableArray<FAssetModel *> *)selectedAssetModels {
    if (_selectedAssetModels == nil) {
        _selectedAssetModels = [NSMutableArray array];
    }
    return _selectedAssetModels;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
   
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem = nil;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[FImagePickerController class]]];
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[FImagePickerController class], nil];
        #pragma clang diagnostic pop
    }
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15.0];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [UIApplication sharedApplication].statusBarStyle = iOS7Later ? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque;
    #pragma clang diagnostic pop
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount delegate:(id<FImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImageCount:maxImageCount columnNumber:4 delegate:delegate];
}

- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount columnNumber:(NSInteger)columnNumber delegate:(id<FImagePickerControllerDelegate>)delegate {
    FAlbumPickerController *albumPickerVC = [[FAlbumPickerController alloc] init];
    albumPickerVC.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVC];
    if (self) {
        self.maxImagesCount = maxImageCount > 0 ? maxImageCount : 9;  //这里默认设置为9
        self.pickerDelegate = delegate;
        
        //默认的初始化配置
        
        //是否允许选择原图
        self.allowPickingOriginalPhoto = YES;
        //是否允许选择照片
        self.allowPickingImage = YES;
        //是否允许选择视频
        self.allowPickingVideo = YES;
        //是否允许拍照
        self.allowTakePhoto = YES;
        //默认升序排列
        self.sortAsendingByModificationDate = YES;
        self.autoDismiss = YES;
        
        //每行的照片数量
        self.columnNumber = columnNumber;
        
        if ([[FImageManager manager] authorzationStatusAuthorized]) {
            [self pushToPhotoPickerVC];
        } else {
        // 没有相册的访问权限 或者 还未 授权（提示用户进行相关设置）
            UILabel *tipLabel = [[UILabel alloc] init];
            tipLabel.frame = CGRectMake(8, 120, self.view.width-16, 60);
            tipLabel.textAlignment = NSTextAlignmentCenter;
            tipLabel.numberOfLines = 0;
            tipLabel.font = [UIFont systemFontOfSize:16];
            tipLabel.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            }
            NSString *tipText = [NSString stringWithFormat:@"允许%@访问你的相册 在设置-> 隐私 -> 照片  中设置",appName];
            tipLabel.text = tipText;
            _tipLabel = tipLabel;
            [self.view addSubview:tipLabel];
            
            UIButton *settingButton = [[UIButton alloc] init];
            settingButton.frame = CGRectMake(0, 180, self.view.width, 44);
            settingButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [settingButton setTitle:@"设置" forState:UIControlStateNormal];
            [settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchUpInside];
            _settingButton = settingButton;
            [self.view addSubview:settingButton];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:YES];
            _timer = timer;
        }
        
    }
    
    return self;
}


- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)settingButtonClick {
    if (iOS8Later) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
    }
}

- (void)observeAuthrizationStatusChange {
    if ([[FImageManager manager] authorzationStatusAuthorized]) {
        [self pushToPhotoPickerVC];
        [_tipLabel removeFromSuperview];
        [_settingButton removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
    }
}

//相机胶卷这个相册
- (void)pushToPhotoPickerVC {
    FPhotoPickerController *photoPickerVC = [[FPhotoPickerController alloc] init];
    photoPickerVC.columnNumber = self.columnNumber;
    
    [[FImageManager manager] getCameraRollAlbum:YES allowPickingImage:YES completion:^(FAlbumModel *model) {
        photoPickerVC.albumModel = model;
        [self pushViewController:photoPickerVC animated:YES];
    }];
}

- (void)dealloc {
    NSLog(@"%@销毁",NSStringFromClass([self class]));
}

@end


@interface FAlbumPickerController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
}
@property (nonatomic,strong) NSMutableArray *albumArr;
@end


@implementation FAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configTableView];
}

- (void)configTableView {
    
    [[FImageManager manager] authorzationStatusAuthorized];
    [[FImageManager manager] getAllAlbums:YES allowPickingImage:YES completion:^(NSArray<FAlbumModel *> *models) {
        _albumArr = [NSMutableArray arrayWithArray:models];
        if (_tableView == nil) {
            CGFloat top = 44;
            if (iOS7Later) top += 20;
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top) style:UITableViewStylePlain];
            _tableView.rowHeight = 70;
            _tableView.tableFooterView = [[UIView alloc] init];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            [_tableView registerClass:[FAlbumCell class] forCellReuseIdentifier:@"FAlbumCell"];
            [self.view addSubview:_tableView];
        }
    }];
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAlbumCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    FAlbumModel *model = [_albumArr objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FPhotoPickerController *photoPickerVc = [[FPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    FAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.albumModel = model;
  
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)dealloc {
    NSLog(@"%@销毁",NSStringFromClass([self class]));
}
@end
