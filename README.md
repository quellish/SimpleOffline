##SimpleOffline

Demonstrates handling of "offline" network mode following Apple best practices.

###What This Shows You

When the "Connect" button is pressed, the application makes a new connection to a remote host.

If the connection fails because there is no internet connection, the application error handling registers with the System Configuration framework (`SCNetworkReachability`) to be notified when the network configuration changes. The "Connect" button is disabled, preventing the user from attempting to connect while the device is offline.

When a notification arrives indicating that the failing host may be reachable the "Connect" button is enabled and the application stops observing network configuration changes.

This follows the recommended best practices documented in the [System Configuration Programming Guidelines](https://developer.apple.com/library/mac/documentation/Networking/Conceptual/SystemConfigFrameworks/SC_ReachConnect/SC_ReachConnect.html), [Networking Overview: Designing for Real-world Networks](https://developer.apple.com/library/mac/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/WhyNetworkingIsHard/WhyNetworkingIsHard.html#//apple_ref/doc/uid/TP40010220-CH13-SW1), [WWDC 2010 Session "Network Apps for iPhone OS, Part 2](https://developer.apple.com/videos/wwdc/2010/#208).

An easy way to see this in action is to run the application in the simulator and try connecting and disconnecting your network connection(s). Note that the Xcode 6.x simulator seems to have some bugs related to network connectivity and configuration changes, particularly with proxies. Your mileage may vary.