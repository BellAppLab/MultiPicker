import UIKit
import Photos


//MARK: Delegate
/**
    MultiPickerable

    An object that can handle a MultiPicker.

    - discussion    This is how you get your pictures. :)
*/
@objc public protocol MultiPickerable: NSObjectProtocol
{
    /**
     Did finish
     
     - param    multiPicker The MultiPicker instance calling its delegate
     - discussion   The MultiPicker only calls this method when its Cancel and Done buttons are visible (i.e. when it's being presented modally). You can access the selected assets by calling `multiPicker.picked`.
     */
    func didFinish(multiPicker: MultiPicker)
    optional func multi(picker: MultiPicker, shouldSelectAsset asset: PHAsset, atIndex index: Int) -> Bool
    optional func multi(picker: MultiPicker, didSelect asset: PHAsset, atIndex index: Int)
    optional func multi(picker: MultiPicker, shouldDeselectAsset asset: PHAsset, atIndex index: Int) -> Bool
    optional func multi(picker: MultiPicker, didDeselect asset: PHAsset, atIndex index: Int)
    optional func didClear(multiPicker: MultiPicker)
}


//MARK: - Main
/**
    Multi Picker
 
    This is how you display the pictures. :)
 */
public class MultiPicker: UINavigationController
{
    //MARK: Validation
    public enum Error: ErrorType, CustomDebugStringConvertible
    {
        case minimumItemsTooLow
        case minimumItemsTooHigh
        case maximumItemsTooLow
        
        public var debugDescription: String {
#if DEBUG
            switch self
            {
            case .MinimumItemsTooLow: return "MinimumItemsTooLow: Are you sure you haven't set the minimum items to a value below 1? Does it make sense to have a minimum below 1?"
            case .MinimumItemsTooHigh: return "MinimumItemsTooHigh: Are you sure you haven't set the minimum items to a value that's higher than 1 and ALSO set the 'multiple' property to false..."
            case .MaximumItemsTooLow: return "MaximumItemsTooLow: Are you sure you haven't set the maximum items to a value that's higher than the minumum?"
            }
#else
            return ""
#endif
        }
    }
    
    //MARK: Delegate
    
    /**
        Delegate
        
        Set the delegate to get the pictures the user selects.
    */
    @IBOutlet public weak var able: MultiPickerable?
    
    //MARK: Setup
    /**
        Make with delegate
    
        - param multiPickerable A delegate
        - discussion    If you init the MultiPicker this way, we assume you're creating it programmatically and therefore you need the UI to be created for you.
    */
    public class func make(multiPickerable: MultiPickerable) -> MultiPicker?
    {
        var bundle = NSBundle(forClass: MultiPicker.self)
        if let path = bundle.pathForResource("MultiPicker", ofType: "bundle") {
            bundle = NSBundle(path: path)!
        }
        
        if let picker = UIStoryboard(name: "MultiPicker", bundle: bundle).instantiateInitialViewController() as? MultiPicker {
            picker.able = multiPickerable
            return picker
        }
        return nil
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let controller = self.topViewController as? AlbumList {
            controller.multiPicker = self
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        try! self.validate()
    }
    
    /**
        Multiple
    
        Toggles the ability to select multiple assets.
    
        - discussion    It doesn't really make much sense to turn this off, since the Library is called MultiPicker, but still... Defaults to true.
    */
    @IBInspectable public var multiple: Bool = true
    
    /**
        Minimum items
     
        Sets the minimum number of items that need to be selected for the Cancel and Done buttons to be enabled and for the count toolbar to be visible. This value must not be lower than 1. Defaults to 1.
     */
    @IBInspectable public var minimumItems: Int = 1
    
    /**
        Maximum items
     
        Sets the maximum number of items that can be selected. Defaults to 100.
     */
    @IBInspectable public var maximumItems: Int = 100
    
    /**
        Shows count
        
        Toggles the ability to show the number of selected items (on a toolbar). Defaults to true.
    */
    @IBInspectable public var showsCount: Bool = true
    
    /**
        Prompt
     
        The navigationItem.prompt to be used.
     */
    @IBInspectable public var prompt: String? = nil
    
    /**
        Cell spacing
     
        The minimum space between grid cells.
     */
    @IBInspectable public var cellSpacing: CGFloat = 10
    
    //MARK: Assets
    
    /**
        Subtypes
     
        The Asset Collection Subtypes that should be used to fetch assets.
     */
    public var subtypes: [PHAssetCollectionSubtype] = [.SmartAlbumUserLibrary, .AlbumMyPhotoStream, .SmartAlbumPanoramas, .SmartAlbumVideos, .SmartAlbumBursts]
    
    /**
        Selected
     
        The currently selected assets.
     */
    public var picked: [PHAsset] = []
    
    //MARK: Private
    private func validate() throws {
        if self.minimumItems < 1 {
            throw Error.MinimumItemsTooLow
        }
        
        if !self.multiple {
            if self.minimumItems > 1 {
                throw Error.MinimumItemsTooHigh
            } else {
                self.maximumItems = self.minimumItems
            }
        }
        
        if self.maximumItems < self.minimumItems {
            throw Error.MaximumItemsTooLow
        }
        
        if self.cellSpacing < 0 {
            self.cellSpacing = 0
        }
    }
    
    func shouldAdd(asset: PHAsset) -> Bool {
        return self.picked.count < self.maximumItems && self.able?.multi?(self, shouldSelectAsset: asset, atIndex: self.picked.count) ?? true
    }
    
    func add(asset: PHAsset) {
        self.picked.append(asset)
        self.able?.multi?(self, didSelect: asset, atIndex: self.picked.count - 1)
    }
    
    func clear() {
        self.picked = []
    }
    
    func shouldRemove(asset: PHAsset) -> Bool {
        if let index = self.picked.indexOf(asset) {
            return self.able?.multi?(self, shouldDeselectAsset: asset, atIndex: index) ?? true
        }
        return false
    }
    
    func remove(asset: PHAsset) {
        if let index = self.picked.indexOf(asset) {
            self.picked.removeAtIndex(index)
            self.able?.multi?(self, didDeselect: asset, atIndex: index)
        }
    }
    
    var doneButtonVisible: Bool {
        return self.cancelButtonVisible
    }
    
    var cancelButtonVisible: Bool {
        return self.presentingViewController != nil || self.popoverPresentationController != nil
    }
    
    var doneButtonEnabled: Bool {
        return self.doneButtonVisible && self.picked.count >= self.minimumItems
    }
    
    var clearButtonVisible: Bool {
        return !self.doneButtonVisible && self.picked.count > 0
    }
    
    //Actions
    func donePressed(sender: UIBarButtonItem) {
        self.able?.didFinish(self)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        self.clear()
        self.able?.didFinish(self)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func clearPressed(sender: UIBarButtonItem) {
        self.clear()
        self.able?.didClear?(self)
    }
}


//MARK: - Children
internal protocol MultiPickerChild {
    weak var multiPicker: MultiPicker! { get set }
    func updateUI()
}


//MARK: - Aux
private func -=(lhs: inout [Int: PHAsset], rhs: inout Int)
{
    lhs.removeValueForKey(rhs)
    while let item = lhs[rhs + 1] {
        lhs.updateValue(item, forKey: rhs)
        rhs += 1
    }
    lhs.removeValueForKey(rhs)
}

internal extension Array
{
    func find(block: (Generator.Element) -> Bool) -> Generator.Element?
    {
        for e in self {
            if block(e) {
                return e
            }
        }
        return nil
    }
}
