//
//  ZYCycleFlowLayout.m
//  Investank
//
//  Created by 史泽东 on 2019/1/14.
//  Copyright © 2019 史泽东. All rights reserved.
//

#import "ZYCycleFlowLayout.h"

@implementation ZYCycleFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    // 设置item的大小
    self.itemSize = self.collectionView.bounds.size;
    
    // 间距
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    
    // 滚动方向
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

@end
