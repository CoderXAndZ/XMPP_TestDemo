//
//  XZEmoticonInputView.m
//  表情键盘
//
//  Created by XZ on 16/3/3.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "XZEmoticonInputView.h"
#import "XZEmoticonToolbar.h"
#import "UIImage+XZEmoticon.h"
#import "XZEmoticonManager.h"
#import "XZEmoticonCell.h"

/// 表情 Cell 可重用标识符号
NSString *const XZEmoticonCellIdentifier = @"XZEmoticonCellIdentifier";

#pragma mark - 表情键盘布局
@interface XZEmoticonKeyboardLayout : UICollectionViewFlowLayout

@end

@implementation XZEmoticonKeyboardLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemSize = self.collectionView.bounds.size;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
}

@end

#pragma mark - 表情输入视图
@interface XZEmoticonInputView() <UICollectionViewDataSource, UICollectionViewDelegate, XZEmoticonToolbarDelegate, XZEmoticonCellDelegate>

@end

@implementation XZEmoticonInputView {
    UICollectionView *_collectionView;
    XZEmoticonToolbar *_toolbar;
    UIPageControl *_pageControl;
    
    void (^_selectedEmoticonCallBack)(XZEmoticon * _Nullable, BOOL);
}

#pragma mark - 构造函数
- (instancetype)initWithSelectedEmoticon:(void (^)(XZEmoticon * _Nullable, BOOL))selectedEmoticon {
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height = 216;
    
    self = [super initWithFrame:frame];
    if (self) {
        _selectedEmoticonCallBack = selectedEmoticon;
        
        [self prepareUI];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        [_collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:NO];
        [self updatePageControlWithIndexPath:indexPath];
        [_toolbar selectSection:indexPath.section];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"请调用 initWithSelectedEmoticon: 实例化表情输入视图");
    return nil;
}

#pragma mark - XZEmoticonToolbarDelegate
- (void)emoticonToolbarDidSelectSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    [_collectionView scrollToItemAtIndexPath:indexPath
                            atScrollPosition:UICollectionViewScrollPositionLeft
                                    animated:NO];
    [self updatePageControlWithIndexPath:indexPath];
}

#pragma mark - XZEmoticonCellDelegate
- (void)emoticonCellDidSelectedEmoticon:(XZEmoticon *)emoticon isRemoved:(BOOL)isRemoved {
    if (_selectedEmoticonCallBack != nil) {
        _selectedEmoticonCallBack(emoticon, isRemoved);
    }
    
    /// 添加最近使用表情
    if (emoticon != nil) {
        [[XZEmoticonManager sharedManager] addRecentEmoticon:emoticon];
        
        // 如果当前停留不是在默认表情页，就更新默认表情页数据
        if ([_collectionView indexPathsForVisibleItems].firstObject.section != 0) {
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [XZEmoticonManager sharedManager].packages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[XZEmoticonManager sharedManager] numberOfPagesInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XZEmoticonCell *cell = [collectionView
                            dequeueReusableCellWithReuseIdentifier:XZEmoticonCellIdentifier
                            forIndexPath:indexPath];
    
    cell.emoticons = [[XZEmoticonManager sharedManager] emoticonsWithIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint center = scrollView.center;
    center.x += scrollView.contentOffset.x;
    
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    
    NSIndexPath *targetPath = nil;
    for (NSIndexPath *indexPath in indexPaths) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        
        if (CGRectContainsPoint(cell.frame, center)) {
            targetPath = indexPath;
            break;
        }
    }
    
    if (targetPath != nil) {
        [self updatePageControlWithIndexPath:targetPath];
        [_toolbar selectSection:targetPath.section];
    }
}

- (void)updatePageControlWithIndexPath:(NSIndexPath *)indexPath {
    _pageControl.numberOfPages = [[XZEmoticonManager sharedManager] numberOfPagesInSection:indexPath.section];
    _pageControl.currentPage = indexPath.item;
}

#pragma mark - 设置界面
- (void)prepareUI {
    // 1. 基本属性设置
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage xz_imageNamed:@"emoticon_keyboard_background"]];
    
    // 2. 添加工具栏
    _toolbar = [[XZEmoticonToolbar alloc] init];
    [self addSubview:_toolbar];
    
    // 设置工具栏位置
    CGFloat toolbarHeight = 42;
    CGRect toolbarRect = self.bounds;
    toolbarRect.origin.y = toolbarRect.size.height - toolbarHeight;
    toolbarRect.size.height = toolbarHeight;
    _toolbar.frame = toolbarRect;
    
    _toolbar.delegate = self;
    
    // 3. 添加 collectionView
    CGRect collectionViewRect = self.bounds;
    collectionViewRect.size.height -= toolbarHeight;
    _collectionView = [[UICollectionView alloc]
                       initWithFrame:collectionViewRect
                       collectionViewLayout:[[XZEmoticonKeyboardLayout alloc] init]];
    [self addSubview:_collectionView];
    
    // 设置 collectionView
    _collectionView.backgroundColor = [UIColor clearColor];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[XZEmoticonCell class] forCellWithReuseIdentifier:XZEmoticonCellIdentifier];
    
    // 4. 分页控件
    _pageControl = [[UIPageControl alloc] init];
    [self addSubview:_pageControl];
    
    // 设置分页控件
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
    
    [_pageControl setValue:[UIImage xz_imageNamed:@"compose_keyboard_dot_selected"] forKey:@"_currentPageImage"];
    [_pageControl setValue:[UIImage xz_imageNamed:@"compose_keyboard_dot_normal"] forKey:@"_pageImage"];
    
    // 自动布局
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_toolbar
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
}

@end
