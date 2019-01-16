//
//  ZYCycleView.m
//  Investank
//
//  Created by 史泽东 on 2019/1/14.
//  Copyright © 2019 史泽东. All rights reserved.
//

#import "ZYCycleView.h"
#import "ZYCycleCell.h"
#import "ZYCycleFlowLayout.h"

#define kSeed 999

@interface ZYCycleView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) ZYCycleFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

static NSString *cycleCellid = @"cycleCellid";

@implementation ZYCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    
    // collectionView
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(0);
    }];
    
    [self addTimer];
}

- (void)setImageURLs:(NSArray *)imageURLs {
    _imageURLs = imageURLs;
    
    // 刷新数据
    [self.collectionView reloadData];
    
    
    // 让屏幕显示中间的cell
    self.collectionView.contentOffset = CGPointMake(self.bounds.size.width * self.imageURLs.count * kSeed, 0);
    
    // 设置pageControl的总页数
    self.pageControl.numberOfPages = imageURLs.count;
}

// 定时轮播
- (void)nextImage {
    
    if (0 == self.imageURLs.count) return;
    
    //itemSize 一般与 collectionView's size 同样大小
    NSInteger currentPage = (self.collectionView.contentOffset.x + self.layout.itemSize.width*0.5) / self.layout.itemSize.width;
    
    NSInteger targetIndex = currentPage + 1;
    
    //若无限轮播即将滚动到的index超出所有预设的item数量
    if (targetIndex >= self.imageURLs.count * kSeed) {
        targetIndex = self.imageURLs.count * kSeed * 0.5;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];

}

- (void)pageControlChanged:(UIPageControl *)pageControl {
    CGFloat x = pageControl.currentPage * self.collectionView.frame.size.width;
//    NSLog(@"%ld", (long)pageControl.currentPage);
    [self.collectionView setContentOffset:CGPointMake(x, 0) animated:pageControl.currentPage == 0 ? NO : YES];;
}


#pragma mark ------------- UICollectionViewDelegate, UICollectionViewDataSource ------------

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%@", self.imageURLs[indexPath.item%3]);
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLs.count * 2 * kSeed;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZYCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cycleCellid forIndexPath:indexPath];
    
    cell.imageURL = self.imageURLs[indexPath.item % self.imageURLs.count];
    
    return cell;
}

#pragma mark ------------ uiscrollviewDelegate ---------------
// scrollView滑动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取offset
    CGFloat offsetX = scrollView.contentOffset.x;
    // 计算页数
    NSInteger page = (offsetX + self.bounds.size.width * .5) / self.bounds.size.width ;
    
    self.pageControl.currentPage = page % self.imageURLs.count;
    
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self removeTimer];
}

// 拖拽完成
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

// scrolView(collectionView)已经减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 获取offset
    CGFloat offsetX = scrollView.contentOffset.x;
    // 计算页数
    NSInteger page = offsetX / self.bounds.size.width;
    
    //    NSLog(@"%zd", page);
    
    // 获取某一组有多少个item
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    
    if (page == 0) { // 如果第0页
        self.collectionView.contentOffset = CGPointMake(offsetX + self.imageURLs.count * self.bounds.size.width * kSeed, 0);
    } else if (page == cellCount - 1) { // 最后一页
        self.collectionView.contentOffset = CGPointMake(offsetX - self.imageURLs.count * self.bounds.size.width * kSeed, 0);
    }
    
}

/**
 *  开启定时器
 */
- (void)addTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 *  关闭定时器
 */
- (void)removeTimer {
    [self.timer invalidate];
}


#pragma mark -------------- getter -------------
- (ZYCycleFlowLayout *)layout {
    if (!_layout) {
        _layout = [[ZYCycleFlowLayout alloc] init];
    }
    return _layout;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        
        // 设置数据源和代理
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        // 注册单元格
        [_collectionView registerClass:[ZYCycleCell class] forCellWithReuseIdentifier:cycleCellid];
        
        // 设置分页
        _collectionView.pagingEnabled = YES;
        
        // 取消滚动条
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.contentSize = CGSizeMake(self.imageURLs.count *UIScreenWidth, 0);
//        [_collectionView setContentOffset:CGPointMake(UIScreenWidth, 0) animated:NO];
        
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        // 创建pageControl
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 2;
        _pageControl.pageIndicatorTintColor = [UIColor blueColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
        _pageControl.userInteractionEnabled = YES;
        [_pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}








@end
