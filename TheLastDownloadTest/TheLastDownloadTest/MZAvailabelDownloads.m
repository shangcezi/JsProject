//
//  ViewController.m
//  DownloadManager
//
//  Created by Muhammad Zeeshan on 5/6/14.
//  Copyright (c) 2014 Ideamakerz. All rights reserved.
//
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#import "MZAvailabelDownloads.h"
#import "MZDownloadManagerViewController.h"
#import "MZDownloadedViewController.h"
#import "MZUtility.h"

@interface MZAvailabelDownloads () <MZDownloadDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *availableDownloadTableView;
    
    NSMutableArray *availableDownloadsArray;
    
    MZDownloadManagerViewController *mzDownloadingViewObj;
}
@property (nonatomic ,strong ) MZDownloadManagerViewController *vc;
@property (nonatomic ,strong ) MZDownloadedViewController *vc2;
@property (nonatomic ,strong ) UITableView *myTableView ;
@end

@implementation MZAvailabelDownloads

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self settableViews];
    self.title = @"首页";
    
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"DownloadingStroyBoard" bundle:[NSBundle mainBundle]];
    
    
    self.vc = [story instantiateViewControllerWithIdentifier:@"MZDownloadManagerViewController"];
    
    
    UIStoryboard *story2 = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    
    
    self.vc2 = [story2 instantiateViewControllerWithIdentifier:@"DownloadedViewController"];
    
    
    

    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view, typically from a nib.
    
    availableDownloadsArray = [NSMutableArray arrayWithObjects:
                               @"http://vod.maxtv.cn/finance/20151221/20151221-154133-855-9680.mp4",
                               @"http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                               @"http://dl.dropbox.com/u/97700329/file3.mp4",
                               @"http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2",
                               @"http://dl.dropbox.com/u/97700329/GCDExample-master.zip", nil];
    
//    UINavigationController *mzDownloadingNav = [self.tabBarController.viewControllers objectAtIndex:1];
//    mzDownloadingViewObj = [mzDownloadingNav.viewControllers objectAtIndex:0];
    //[mzDownloadingViewObj setDelegate:self];
    
  self.vc.downloadingArray = [[NSMutableArray alloc] init];
    self.vc.sessionManager = [self.vc backgroundSession];
    [self.vc populateOtherDownloadTasks];
    
    
    
    NSLog(@"home%@",NSHomeDirectory());
    
    [self updateDownloadingTabBadge];
}




-(void)settableViews{
    
    
    UITableView *myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    
    myTable.backgroundColor = [UIColor lightGrayColor];
    
    myTable.delegate   = self;
    myTable.dataSource = self;
    _myTableView = myTable;
    
    [self.view addSubview:myTable];
    
    //跳到下载界面按钮
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 -50, SCREEN_HEIGHT-150, 100, 50)];
    
    button.backgroundColor = [UIColor magentaColor];
    
    [button setTitle:@"下载" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    //跳到已经下载界面按钮
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 -50, SCREEN_HEIGHT-80, 100, 50)];
    
    button2.backgroundColor = [UIColor cyanColor];
    
    [button2 setTitle:@"已下载" forState:UIControlStateNormal];
    
    [button2 addTarget:self action:@selector(downButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button2];

   // [button2 convertRect:button2.frame toView:button];
    
   // NSLog(@"button2的frame是%@",NSStringFromCGRect(button2.frame));
    
    
    
}
-(void)rightBarButtonClick{
    
    [self.navigationController pushViewController:self.vc animated:YES];
    
    
    NSLog(@"我惦记了啊");
    
}
-(void)downButtonClick{

    [self.navigationController pushViewController:self.vc2 animated:YES];

}



#pragma mark - My Methods -
- (void)updateDownloadingTabBadge
{
    UITabBarItem *downloadingTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    int badgeCount = mzDownloadingViewObj.downloadingArray.count;
    if(badgeCount == 0)
        [downloadingTab setBadgeValue:nil];
    else
        [downloadingTab setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
}
#pragma mark - Tableview Delegate and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return availableDownloadsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AvailableDownloadsCell";
     
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
    }
    
  // convertRect:<#(CGRect)#> toView:<#(nullable UIView *)#>
    
    [cell.textLabel setText:[[[availableDownloadsArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject]];
    
    
    return cell;
    

}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlLastPathComponent = [[[availableDownloadsArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject];
    NSString *fileName = [MZUtility getUniqueFileNameForName:urlLastPathComponent];
    [mzDownloadingViewObj addDownloadTask:fileName fileURL:[availableDownloadsArray objectAtIndex:indexPath.row]];
    
    [self updateDownloadingTabBadge];
    
    [availableDownloadsArray removeObjectAtIndex:indexPath.row];
    [availableDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
#pragma mark - MZDownloadManager Delegates -

-(void)downloadRequestFinished:(NSString *)fileName
{
   
    NSString *docDirectoryPath = [fileDest stringByAppendingPathComponent:fileName];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadCompletedNotif object:docDirectoryPath];
}

@end
