import UIKit
import Photos
import UILoader


//MARK: - Cells
class ListImageView: UIView
{
    @IBOutlet private weak var imageView: UIImageView!
    
    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
}

class ListCell: UITableViewCell
{
    @IBOutlet var listImageViews: [ListImageView]!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    func view(atIndex index: Int) -> ListImageView?
    {
        for view in self.listImageViews {
            if view.tag == index {
                return view
            }
        }
        return nil
    }
}


class GridCell: UICollectionViewCell, UILoaderDelegate
{
    weak var asset: PHAsset!
    
    @IBOutlet weak var selectedView: UIView?
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spinningThing: UIActivityIndicatorView?
    var loader: UILoader?
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if self.loader == nil {
                self.loader = UILoader(delegate: self)
            }
            super.selected = newValue
            self.selectedView?.hidden = !newValue
        }
    }
    
    //MARK: Loader Delegate
    func didChangeLoadingStatus(loading: Bool) {
        
    }
}


//MARK: - Checkmark View
@IBDesignable class Checkmark: UIView
{
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var checkmarkLineWidth: CGFloat = 1.2
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor()
    @IBInspectable var bodyColor: UIColor = UIColor(red: 20.0 / 255.0, green: 111.0 / 255.0, blue: 223.0 / 255.0, alpha: 1)
    @IBInspectable var checkmarkColor: UIColor = UIColor.whiteColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        // Set shadow
        self.layer.shadowColor = UIColor.grayColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 2.0
    }
    
    override func drawRect(rect: CGRect) {
        // Border
        self.borderColor.setFill()
        UIBezierPath(ovalInRect: self.bounds).fill()
        
        // Body
        self.bodyColor.setFill()
        UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.borderWidth, self.borderWidth)).fill()
        
        // Checkmark
        let checkmarkPath = UIBezierPath()
        checkmarkPath.lineWidth = self.checkmarkLineWidth
        
        checkmarkPath.moveToPoint(CGPointMake(CGRectGetWidth(self.bounds) * (6.0 / 24.0), CGRectGetHeight(self.bounds) * (12.0 / 24.0)))
        checkmarkPath.addLineToPoint(CGPointMake(CGRectGetWidth(self.bounds) * (10.0 / 24.0), CGRectGetHeight(self.bounds) * (16.0 / 24.0)))
        checkmarkPath.addLineToPoint(CGPointMake(CGRectGetWidth(self.bounds) * (18.0 / 24.0), CGRectGetHeight(self.bounds) * (8.0 / 24.0)))
        
        self.checkmarkColor.setStroke()
        checkmarkPath.stroke()
    }
}
