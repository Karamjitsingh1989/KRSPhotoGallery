
//

#import "KRSPhotoGalleryVC.h"
#import "KRSPhotoCell.h"
#import "PhotoGalleryVC.h"
@import Photos;
@interface KRSPhotoGalleryVC ()<PHPhotoLibraryChangeObserver>



@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (strong) PHCachingImageManager *imageManager;
@property (strong) NSArray *customSmartCollections;
@end
@implementation KRSPhotoGalleryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    
    
    _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
    
    
    
    self.imageManager = [[PHCachingImageManager alloc] init];

    
    self.tblAlbum.rowHeight = 100;

    self.tblAlbum.separatorStyle = UITableViewCellSeparatorStyleNone;
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
    self.collectionsLocalizedTitles = @[@"Albums", @"Smart Albums"];
    // Register for changes
    [self updateFetchResults];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{

    self.navigationController.navigationBarHidden=YES;
    self.tabBarController.tabBar.hidden=YES;

}
-(void)viewWillDisappear:(BOOL)animated{


 self.tabBarController.tabBar.hidden=NO;


}
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
-(void)updateFetchResults
{
    //What I do here is fetch both the albums list and the assets of each album.
    //This way I have acces to the number of items in each album, I can load the 3
    //thumbnails directly and I can pass the fetched result to the gridViewController.
    
    self.collectionsFetchResultsAssets=nil;
    self.collectionsFetchResultsTitles=nil;
    
    //Fetch PHAssetCollections:
    PHFetchResult *topLevelUserCollections = [self.collectionsFetchResults objectAtIndex:0];
    PHFetchResult *smartAlbums = [self.collectionsFetchResults objectAtIndex:1];
    
    //All album: Sorted by descending creation date.
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
        [allFetchResultArray addObject:assetsFetchResult];
        [allFetchResultLabel addObject:@"All photos"];
    }
    
    //User albums:
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in topLevelUserCollections)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@",  @[@(PHAssetMediaTypeImage)]];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Albums collections are allways PHAssetCollectionType=1 & PHAssetCollectionSubtype=2
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            [userFetchResultArray addObject:assetsFetchResult];
            [userFetchResultLabel addObject:collection.localizedTitle];
        }
    }
    
    
    //Smart albums: Sorted by descending creation date.
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Smart collections are PHAssetCollectionType=2;
            if(_customSmartCollections && [_customSmartCollections containsObject:@(assetCollection.assetCollectionSubtype)])
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@",  @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0)
                {
                    [smartFetchResultArray addObject:assetsFetchResult];
                    [smartFetchResultLabel addObject:collection.localizedTitle];
                }
            }
        }
    }
    
    self.collectionsFetchResultsAssets= @[allFetchResultArray,userFetchResultArray,smartFetchResultArray];
    self.collectionsFetchResultsTitles= @[allFetchResultLabel,userFetchResultLabel,smartFetchResultLabel];
    [self.tblAlbum reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResultsAssets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
    return fetchResult.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KRSPhotoCell";
    KRSPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    // Set the label
    cell.lblAlbum.text = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    
    // Retrieve the pre-fetched assets for this album:
    PHFetchResult *assetsFetchResult = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    cell.lblPhotoCount.text = [self tableCellSubtitle:assetsFetchResult];
    
    
    // Set the 3 images (if exists):
    if ([assetsFetchResult count] > 0) {
        
        PHAsset *asset = assetsFetchResult[0];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:CGSizeMake(160, 160)
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                          cell.Img3.image = result;
                                      
                                  }];
        
        if ([assetsFetchResult count] > 1) {
            //Compute the thumbnail pixel size:
            
            PHAsset *asset = assetsFetchResult[1];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:CGSizeMake(76, 76)
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                              cell.Img2.image = result;
                                          
                                      }];
        } else {
            cell.Img2.image = nil;
        }
        
        if ([assetsFetchResult count] > 2) {
           
            PHAsset *asset = assetsFetchResult[2];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:CGSizeMake(72, 72)
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                              cell.Img1.image = result;
                                         
                                      }];
        } else {
            cell.Img1.image = nil;
        }
    } else {
        cell.Img1.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.Img2.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.Img3.image = [UIImage imageNamed:@"GMEmptyFolder"];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    PHFetchResult *resultArr=[[_collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (resultArr.count !=0) {
        PhotoGalleryVC *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"PhotoGalleryVC"];
        controller.resultArr=[[_collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        controller.lblTitleName.text=(self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
        controller.photoCount=_photoCount;
        controller.selectedImageArr=_selectedImageArr;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
    
      //  [ProgressHUD showError:@"No photo to show"];
        return;
    
    }
    
  
    
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Tip: Returning nil hides the section header!
    
    NSString *title = nil;
    if (section > 0) {
        // Only show title for non-empty sections:
        PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
        if (fetchResult.count > 0) {
         //   title = self.collectionsLocalizedTitles[section - 1];
        }
    }
    return title;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        // This only affects to changes in albums level (add/remove/edit album)
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
        }
        
        // However, we want to update if photos are added, so the counts of items & thumbnails are updated too.
        // Maybe some checks could be done here , but for now is OKey.
        [self updateFetchResults];
        [self.tblAlbum reloadData];
        
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Cell Subtitle

- (NSString *)tableCellSubtitle:(PHFetchResult*)assetsFetchResult
{
    // Just return the number of assets. Album app does this:
    return [NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]];
}

- (IBAction)SelectBackController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
