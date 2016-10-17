//
//  FImagePickerConfig.h
//  FImagePickerController
//
//  Created by  apple on 16/9/21.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#ifndef FImagePickerConfig_h
#define FImagePickerConfig_h


#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)


#define MainColorForSelected  [UIColor colorWithRed:46/255.0 green:178/255.0 blue:242/255.0 alpha:1]

#define PhotoSelectedImageName      @""
#define PhotoNornalImageName        @""


#endif /* FImagePickerConfig_h */
