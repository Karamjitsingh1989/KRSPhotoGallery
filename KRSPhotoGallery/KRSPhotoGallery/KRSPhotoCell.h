//
//  KRSPhotoCell.h

//
//

#import <UIKit/UIKit.h>

@interface KRSPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *Img1;
@property (weak, nonatomic) IBOutlet UIImageView *Img2;
@property (weak, nonatomic) IBOutlet UIImageView *Img3;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotoCount;

@end
