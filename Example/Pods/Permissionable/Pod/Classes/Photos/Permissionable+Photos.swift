import Photos
import Alertable
import Backgroundable


extension Permissions.Photos
{
    @objc func hasAccess() -> NSNumber? {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status
        {
        case .Authorized: return NSNumber(bool: true)
        case .Denied, .Restricted: return NSNumber(bool: false)
        case .NotDetermined: return nil
        }
    }
    
    @objc func makeAction(sender: UIViewController, _ block: Permissions.Result?) -> AnyObject {
        return Alert.Action(title: NSLocalizedString("Yes", comment: ""), style: .Default, handler: { (UIAlertAction) -> Void in
            Alert.on = true
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
                Alert.on = false
                toMainThread {
                    block?(success: status == .Authorized)
                }
            }
        })
    }
}
