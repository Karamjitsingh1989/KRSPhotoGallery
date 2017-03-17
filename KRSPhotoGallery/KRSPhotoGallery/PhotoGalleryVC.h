
//

#import <UIKit/UIKit.h>
@import Photos;
//MARK: Delegate method for Discover Search
@protocol PhotoGalleryDelegate <NSObject>
-(void)func_selectedPhotos:(NSArray *)photos;
@end

@interface PhotoGalleryVC : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
- (IBAction)SelectDoneAction:(id)sender;
@property (nonatomic,retain)id<PhotoGalleryDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleName;

- (IBAction)CloseControllerAction:(id)sender;
@property NSInteger photoCount;
@property (strong) PHCachingImageManager *imageManager;
@property(nonatomic,retain)PHFetchResult *resultArr;

@property(nonatomic,retain)NSArray* selectedImageArr;
@end
