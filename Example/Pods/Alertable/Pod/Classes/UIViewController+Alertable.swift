import UIKit

/*
    This extension provides easy access to the Alertable interface.
*/
public extension UIViewController
{
    /*
        Easily check if we're currently alerting the user.
    */
    public var alerting: Bool {
        return Alert.on
    }
    
    /*
        Quickly present an alert to the user.
        
        @params alert: The alert to be presented. 
        @discussion This method assumes we're presenting the alert from the current View Controller. See Alert's documentation for more details.
    */
    public func alert(this alert: Alert)
    {
        alert.show(self)
    }
    
    /*
        Quickly present an alert to the user.
    
        @params alert: The alert to be presented.
        @discussion This method assumes we're presenting the alert from the View Controller that stored within the Alert. See Alert's documentation for more details.
    */
    public class func alert(this alert: Alert)
    {
        alert.show()
    }
    
    /*
        Quickly present an alert to the user.
    
        @params alert: The alert to be presented.
        @discussion This method assumes we're presenting the alert from the current View Controller. See Alert's documentation for more details.
    */
    public func alert(message: String, _ title: String? = nil, _ actions: [Alert.Action]? = nil)
    {
        Alert.show(message, title, self, actions)
    }
    
    /*
        Quickly present an alert to the user.
    
        @params alert: The alert to be presented.
        @discussion This method assumes we're presenting the alert from the View Controller that stored within the Alert. See Alert's documentation for more details.
    */
    public class func alert(message: String, _ title: String? = nil, _ sender: UIViewController? = nil, _ actions: [Alert.Action]? = nil)
    {
        Alert.show(message, title, sender, actions)
    }
}
