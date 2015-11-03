import UIKit
import Photos


//MARK: Delegate
/**
    Multi Picker Delegate

    This is how you get your pictures. :)
*/
@objc public protocol MultiPickerDelegate: NSObjectProtocol
{
    /**
     Did finish
     
     @params multiPicker: The MultiPicker instance calling its delegate
     @discussion The MultiPicker only calls this method when its Cancel and Done buttons are visible (i.e. when it's being presented modally). You can access the selected assets by calling `multiPicker.selectedAssets`.
     */
    func didFinish(multiPicker: MultiPicker)
    optional func multi(picker: MultiPicker, shouldSelectAsset asset: PHAsset) -> Bool
    optional func multi(picker: MultiPicker, didSelect asset: PHAsset)
    optional func multi(picker: MultiPicker, shouldDeselectAsset asset: PHAsset) -> Bool
    optional func multi(picker: MultiPicker, didDeselect asset: PHAsset)
}


//MARK: - Main
/**
    Multi Picker
 
    This is how you display the pictures. :)
 */
public class MultiPicker: UIViewController
{
    //MARK: Validation
    public enum Error: ErrorType, CustomDebugStringConvertible
    {
        case MinimumItemsTooLow
        case MinimumItemsTooHigh
        case MaximumItemsTooLow
        
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
    @IBOutlet public weak var delegate: MultiPickerDelegate?
    
    //MARK: Setup
    /**
        Make with delegate
    
        @params A delegate
        @discussion If you init the MultiPicker this way, we assume you're creating it programmatically and therefore you need the UI to be created for you.
    */
    class func make(delegate: MultiPickerDelegate) -> MultiPicker?
    {
        var bundle = NSBundle(forClass: MultiPicker.self)
        if let path = bundle.pathForResource("MultiPicker", ofType: "bundle") {
            bundle = NSBundle(path: path)!
        }
        
        return UIStoryboard(name: "MultiPicker", bundle: bundle).instantiateInitialViewController() as? MultiPicker
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        try! self.validate()
    }
    
    /**
        Multiple
    
        Toggles the ability to select multiple assets.
    
        @discussion It doesn't really make much sense to turn this off, since the Library is called MultiPicker, but still... Defaults to true.
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
    public var selected: [Int: PHAsset] = [:]
    
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
        return self.selected.count < self.maximumItems && self.delegate?.multi?(self, shouldSelectAsset: asset) ?? true
    }
    
    func add(asset: PHAsset) -> Int {
        let result = self.selected.count
        self.selected.updateValue(asset, forKey: result)
        self.delegate?.multi?(self, didSelect: asset)
        return result
    }
    
    func clear() {
        self.selected = [:]
    }
    
    func shouldRemove(assetAtIndex index: Int) -> Bool {
        if let asset = self.selected[index] {
            return self.delegate?.multi?(self, shouldDeselectAsset: asset) ?? true
        }
        return false
    }
    
    func remove(assetAtIndex index: Int) -> Int {
        if let asset = self.selected[index] {
            self.selected -= index
            self.delegate?.multi?(self, didDeselect: asset)
        }
        return 0
    }
    
    var doneButtonVisible: Bool {
        return self.cancelButtonVisible
    }
    
    var cancelButtonVisible: Bool {
        return self.presentingViewController != nil || self.popoverPresentationController != nil
    }
    
    var doneButtonEnabled: Bool {
        return self.doneButtonVisible && self.selected.count >= self.minimumItems
    }
    
    var clearButtonVisible: Bool {
        return !self.doneButtonVisible && self.selected.count > 0
    }
    
    //Actions
    func donePressed(sender: UIBarButtonItem) {
        self.delegate?.didFinish(self)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        self.clear()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}


//MARK: - Children
internal protocol MultiPickerChild {
    weak var multiPicker: MultiPicker! { get set }
    func updateUI()
}


//MARK: - Aux
private func -=(inout lhs: [Int: PHAsset], var rhs: Int)
{
    lhs.removeValueForKey(rhs)
    while let item = lhs[rhs + 1] {
        lhs.updateValue(item, forKey: rhs++)
    }
}
