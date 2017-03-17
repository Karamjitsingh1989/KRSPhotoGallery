//
//
//

#import "PhotoGalleryVC.h"
#import "ViewController.h"
@interface PhotoGalleryVC ()<PHPhotoLibraryChangeObserver>
{

    CGFloat SCREEN_WIDTH;
    NSMutableArray *selectedIndexArr,*photosArr;
}
@property CGRect previousPreheatRect;

@end

@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end

@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end



@implementation PhotoGalleryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    SCREEN_WIDTH = self.view.frame.size.width;
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    selectedIndexArr = [[NSMutableArray alloc] init];
    photosArr = [[NSMutableArray alloc] init];
    self.photoCollectionView.allowsMultipleSelection=YES;
   
    
   self.imageManager = [[PHCachingImageManager alloc] init];
   [self.imageManager stopCachingImagesForAllAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ViewController class]]) {
            self.delegate=(ViewController *)vc;
        }
    }
    
    

}


-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden=YES;
    self.tabBarController.tabBar.hidden=YES;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    
    self.tabBarController.tabBar.hidden=NO;
    
    
}

#pragma mark- collection view delegate and data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.resultArr count];;
    
   // return photosArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    UIImageView *imageView=(UIImageView *)[cell viewWithTag:1];
        PHAsset *asset = self.resultArr[indexPath.item];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:CGSizeMake((SCREEN_WIDTH/3)-4, (SCREEN_WIDTH/3)-10)
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                          [imageView setImage:result];
                                      }
                                  ];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:3];
    UIView *SelectedView = (UIView*)[cell viewWithTag:2];
    if ([_selectedImageArr containsObject:self.resultArr[indexPath.row]]) {
        [cell setSelected:YES];
    }
    
    if (cell.selected) {
        SelectedView.hidden=NO;
        checked.hidden = NO;
        }else{
        SelectedView.hidden=YES;
        checked.hidden = YES;
        }
    
    
    
    
     return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
        return CGSizeMake((SCREEN_WIDTH/3)-4, (SCREEN_WIDTH/3)-10);
}
#pragma mark -  Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalCount=30-_photoCount;
    if ([selectedIndexArr count]<totalCount){
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *checked = (UIImageView*)[cell viewWithTag:3];
        UIView *SelectedView = (UIView*)[cell viewWithTag:2];
        SelectedView.hidden=NO;
        checked.hidden = NO;
        PHAsset *asset = self.resultArr[indexPath.item];
        [selectedIndexArr addObject:asset];
        checked = nil;
        cell = nil;
    }else{
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:3];
    checked.hidden = YES;
    UIView *SelectedView = (UIView*)[cell viewWithTag:2];
    SelectedView.hidden=YES;
    PHAsset *asset = self.resultArr[indexPath.item];
    [selectedIndexArr removeObject:asset];
    cell = nil;
    checked = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)SelectDoneAction:(id)sender {
    
    
    if (selectedIndexArr.count==0) {
    //    [ProgressHUD showError:@"Please select at least one photo." Interaction:YES];
        return;
    }
    
    [_delegate func_selectedPhotos:selectedIndexArr];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
}
- (IBAction)CloseControllerAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    
    [selectedIndexArr removeAllObjects];
    
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.resultArr];
        if (collectionChanges) {
            
            // get the new fetch result
            self.resultArr = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.photoCollectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                      
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.photoCollectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.photoCollectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.photoCollectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.photoCollectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:CGSizeMake((SCREEN_WIDTH/3)-4, (SCREEN_WIDTH/3)-10)
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:CGSizeMake((SCREEN_WIDTH/3)-4, (SCREEN_WIDTH/3)-10)
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.resultArr[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}








@end
