//
// XZButton.h
//
//  Created by XZ on 15/12/18.
//  Copyright © 2015年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XZButtonTypePicAbove = 0, // 图片和文字是上下的
    XZButtonTypePicTitleDistance,// 图片和文字是左右的，中间有一段距离
    XZButtonTypePicRight, // 文字在左边，图片在右边
} XZButtonType;

@interface XZButton : UIButton
@property (nonatomic, assign) XZButtonType buttonsType;
@end
