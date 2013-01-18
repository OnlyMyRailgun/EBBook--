

#import "SMSCustomCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SMSCustomCell
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize contentLabel;
@synthesize avatarImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        [contentLabel setContentMode:UIViewContentModeTop];
        
    }
    return self;
}

- (void)initializeImageView
{
    avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    avatarImageView.layer.cornerRadius = 9.0;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    avatarImageView.layer.borderWidth = 1.0;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:avatarImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[nameLabel release];
	[dateLabel release];
	[contentLabel release];
    [avatarImageView release];
    [super dealloc];
}


@end
