//
//  ZYCycleCell.m
//  Investank
//
//  Created by 史泽东 on 2019/1/14.
//  Copyright © 2019 史泽东. All rights reserved.
//

#import "ZYCycleCell.h"

@interface ZYCycleCell ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation ZYCycleCell

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

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    // -------- 把url转化成image
    // url -> data(二级制)
    NSData *data = [NSData dataWithContentsOfURL:imageURL];
    // data -> image
    UIImage *image = [UIImage imageWithData:data];
    // -------- 把url转化成image
    
    // 把数据放下控件上
    self.imageView.image = image;
}

- (void)setupUI {
    
    // cell上面就是一张图片
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.imageView = imageView;
}

@end
