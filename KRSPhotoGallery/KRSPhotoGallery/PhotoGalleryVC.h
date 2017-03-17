
//

#import <UIKit/UIKit.h>
@import Photos;
//MARK: Delegate method for PhotoSelection
@protocol PhotoGalleryDelegate <NSObject>
-(void)func_selectedPhotos:(NSArray *)photos;
@end

@interface PhotoGalleryVC : UIViewController
@property (nonatomic,retain)id<PhotoGalleryDelegate>delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleName;
@property (strong) PHCachingImageManager *imageManager;
@property(nonatomic,retain)PHFetchResult *resultArr;
@property(nonatomic,retain)NSArray* selectedImageArr;
@property NSInteger photoCount;
- (IBAction)SelectDoneAction:(id)sender;
- (IBAction)CloseControllerAction:(id)sender;
@end
