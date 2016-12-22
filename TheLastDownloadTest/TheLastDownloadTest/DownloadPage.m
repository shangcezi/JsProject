//
//  ViewController.m
//  download
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 Huateng. All rights reserved.
//

#import "DownloadPage.h"

#import "MZDownloadManagerViewController.h"
#import "MZDownloadedViewController.h"



#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define MyColor(a,b,c,d) [UIColor colorWithRed:(a)/255. green:(b)/255. blue:(c)/255. alpha:(d)]



typedef BOOL (^ShouldBeginGestureCallBack)(UIGestureRecognizer *gesture);


@interface DownLoadScrollView : UIScrollView
@property (nonatomic ,copy)ShouldBeginGestureCallBack  shouldBeginGesture;

@end
@implementation DownLoadScrollView

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    BOOL forbid = self.shouldBeginGesture && !self.shouldBeginGesture(gestureRecognizer);
    
    
    if (forbid) {
        return NO;
    }else{
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}


@end








@interface DownloadPage ()<UIScrollViewDelegate>

@property (nonatomic ,strong ) UIView *topView ;
//已下载按钮
@property (nonatomic ,strong ) UIButton *alreadyDownloadBtn;
//正在下载的按钮
@property (nonatomic ,strong ) UIButton *downLoadingBtn;
//切换时滑动的线
@property (nonatomic ,strong ) UIView *scrollLine;

//左边已经下载的控制器
@property (nonatomic ,strong) UITableViewController *leftTabViewController;
//右边正在下载的控制器
@property (nonatomic ,strong) UITableViewController *rightTabViewController;

@property (nonatomic ,strong) DownLoadScrollView    *sv;

@property (nonatomic ,strong) MZDownloadedViewController   *downloadedCtr;

@property (nonatomic ,strong) MZDownloadManagerViewController *downloadingCtr;


@end

@implementation DownloadPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTopView];
    
    [self setupDownScrollView];
    
    
    
}

-(void)setTopView{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 54)];
    topView.backgroundColor =MyColor(240, 240, 240, 1);
    
    
    
    //已下载按钮
    CGFloat buttonY = 20;
    CGFloat buttonW = SCREEN_WIDTH/2-1;
    CGFloat buttonH = 20;
    UIButton *alreadyDownload = [[UIButton alloc]initWithFrame:CGRectMake(0, buttonY, buttonW, buttonH)];
    alreadyDownload.tag = 100;
    //默认为选中状态
    alreadyDownload.selected = YES;
    
    [alreadyDownload setTitle:@"已下载" forState:UIControlStateNormal];
    [alreadyDownload setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [alreadyDownload setTitleColor:[UIColor magentaColor] forState:UIControlStateSelected];
    
    [alreadyDownload addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    //下载中按钮
    UIButton *downloading = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, buttonY, buttonW, buttonH)];
    
    [downloading setTitle:@"下载中" forState:UIControlStateNormal];
    [downloading addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [downloading setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [downloading setTitleColor:[UIColor magentaColor] forState:UIControlStateSelected];
    
    //下面滑动的线
    UIView *scrollLine = [[UIView alloc]initWithFrame:CGRectMake(1, topView.frame.size.height-2, SCREEN_WIDTH/2-2, 2)];
    
    scrollLine.backgroundColor = [UIColor magentaColor];
    self.scrollLine = scrollLine;
    
    
    
    self.alreadyDownloadBtn =  alreadyDownload;
    
    self.downLoadingBtn     =  downloading;
    
    self.topView = topView;
    
    
    [self.view addSubview:topView];
    [topView addSubview:downloading];
    [topView addSubview:alreadyDownload];
    [topView addSubview:scrollLine];
    
    
}

-(void)setupDownScrollView{
    
    CGFloat scrollY =CGRectGetMaxY(self.topView.frame);
    DownLoadScrollView *sv =[[DownLoadScrollView alloc]initWithFrame:CGRectMake(0, scrollY, SCREEN_WIDTH, SCREEN_HEIGHT-scrollY)];
    
    sv.contentSize = CGSizeMake(SCREEN_WIDTH *2, sv.frame.size.height);
    sv.delegate = self;
    sv.backgroundColor = [UIColor cyanColor];
    sv.pagingEnabled = YES;
    sv.bounces = NO;
    sv.showsHorizontalScrollIndicator = NO;
    self.sv = sv;
    
    [self.view addSubview:sv];
    
    //完成下载的控制器
    //    self.downloadedCtr = [[DowloadedController  alloc]init];
    //    _downloadedCtr.view.frame = CGRectMake(0, 0, SCREEN_WIDTH,sv.frame.size.height);
    //
    //    [self addChildViewController:self.downloadedCtr];
    //     [sv addSubview:_downloadedCtr.view];
    //
    //正在下载的控制器
    self.downloadedCtr = [[MZDownloadedViewController alloc]init];
    _downloadedCtr.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, sv.frame.size.height);
    
    [self addChildViewController:self.downloadedCtr];
    [sv addSubview:_downloadedCtr.view];
    
    MZDownloadManagerViewController *mzviewController = [MZDownloadManagerViewController new];
    mzviewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, sv.frame.size.height);
    
    mzviewController.downloadingArray = self.myDownloadingArray;
    
    
    
    
    
    
    [self addChildViewController:mzviewController];
    [sv addSubview:mzviewController.view];
    
    
    
}

#pragma ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint point = scrollView.contentOffset;
    if (point.x <SCREEN_WIDTH/2 && point.x>0) {
        self.alreadyDownloadBtn.selected = YES;
        
        self.downLoadingBtn.selected     = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.scrollLine.transform = CGAffineTransformIdentity;
            
        }];
        
    }else if(point.x >SCREEN_WIDTH/2 && point.x <= SCREEN_WIDTH){
        self.alreadyDownloadBtn.selected =NO;
        self.downLoadingBtn.selected     = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollLine.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH/2, 0);
        }];
        
    }
    
    
    
}

//点击以切换视图
-(void)clickBtn:(UIButton *)button {
    
    int tag = (int)button.tag;
    
    //已经下载
    if(tag == 100){
        
        self.alreadyDownloadBtn.selected = YES;
        self.downLoadingBtn.selected     =  NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.scrollLine.transform = CGAffineTransformIdentity;
            
            self.sv.contentOffset = CGPointMake(0, 0);
            
        }];
    }else{//未下载
        self.alreadyDownloadBtn.selected = NO;
        self.downLoadingBtn .selected    = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.scrollLine.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH/2, 0);
            
            self.sv.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
            
        }];
        
        
    }
    
    
}



@end
