## WolMo - Networking iOS

[![Build Status](https://www.bitrise.io/app/ee14c324bf9e92ed.svg?token=RS3nJlQST8L2nG6tI_AsYg&branch=master)](https://www.bitrise.io/app/ee14c324bf9e92ed)
[![GitHub release](https://img.shields.io/github/release/Wolox/wolmo-networking-ios.svg)](https://github.com/Wolox/wolmo-networking-ios/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift 3](https://img.shields.io/badge/Swift-3-orange.svg)

WolMo - Networking iOS is a framework which provides an easy customizable HTTP request and session manager for iOS commonly used at [Wolox](http://www.wolox.com.ar/).


## Table of Contents

  * [Installation](#installation)
    * [Carthage](#carthage)
    * [Manually](#manually)
  * [Usage](#usage)
    * [Extending AbstractRepository](#extending-abstractrepository)
    * [Fetching an entity](#fetching-an-entity)
    * [Error handling](#error-handling)
    * [Error decoding reporting](#error-decoding-reporting)
    * [Creating a repository instance](#creating-a-repository-instance)
    * [Enable SSL Pinning](#enable-ssl-pinning)
    * [Session manager](#session-manager)
    * [Storing a User](#storing-a-user)
    * [Enable AlamofireNetworkActivityLogger](#enable-alamofirenetworkactivitylogger)
    * [Enable NetworkActivityIndicatorManager](#enable-networkactivityindicatormanager)
  * [Bootstrap](#bootstrap) 
  * [Contributing](#usage)
  * [About](#about)
  * [License](#license)

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```
To download wolmo-networking-iOS, add this to your Cartfile if you are using Swift 3.2 or 4:
```
github "Wolox/wolmo-networking-ios" "swift-3.2-compatibility"
```
Or if you are using an older version of Swift:
```
github "Wolox/wolmo-networking-ios" "master"
```

### Manually
[Bootstrap](#bootstrap) the project and then drag it to your workspace.

## Usage

The framework provides an easy way to build HTTP repositories to perform requests to a given API based on [Alamofire](https://github.com/Alamofire/Alamofire). The authentication method is based in a token provided in the HTTP header under the key `Authorization`.

### Extending AbstractRepository

The framework allows to create agile HTTP repositories by extending [AbstractRepository](Networking/Repository/AbstractRepository.swift). A simple example of this can be found in the class [DemoRepository](NetworkingDemo/DemoRepository.swift).

### Fetching an entity

In case a custom repository should fetch a single or a collection of models, they must implement `Decodable` (see [Argo](https://github.com/thoughtbot/Argo)). This way they can be automatically decoded by the framework. Check [UserDemo](NetworkingDemo/UserDemo.swift) or [Entity](NetworkingDemo/Entity.swift).

In case the entity is too complex, it's possible to get the error: `Expression was too complex to be solved in reasonable time`. In this case check this [Argo issue](https://github.com/thoughtbot/Argo/issues/5) for a workaround.

### Error handling

Every implemented repository is thought to return a `Result` instance (see [Result](https://github.com/antitypical/Result)) in which the value is typed in the expected response type, and the error is always a [RepositoryError](Networking/Repository/RepositoryError.swift).

The basic and expected errors are implemented, and a way to add custom errors related to the project itself is provided. In order to add new errors it should be necessary to create a new `enum` which implements the protocol `CustomRepositoryErrorType` as done in [EntityRepository](NetworkingTests/Tests/EntityRepository.swift) and match the expected status code in the HTTP response with each custom error. An example of this can be found in [EntityRepository](NetworkingTests/Tests/EntityRepository.swift) in the function `fetchCustomFailingEntity`.

Also, a custom `DecodeError` (see [Argo](https://github.com/thoughtbot/Argo)) can be sent manually. An example can be found in [EntityRepository](NetworkingTests/Tests/EntityRepository.swift) in the function `fetchEntities`. This is useful in case the response body does not match exactly the return type and some kind of decoding needs to be manually performed.

### Error decoding reporting

In case a `DecodeError` is get, the framwork offers a way to perform an action (for example reporting the error using a third party service to notify about a mismatch between API and the client).

To do this provide a closure `decodedErrorHandler` in `DecodedErrorHandler`. Check [DecodedExtension](Networking/Extensions/DecodedErrorHandler.swift). This closure receives the `Argo.DecodeError` and returns `Void`.

### Creating a repository instance

When creating a repository instance it expects an instance of [NetworkingConfiguration](Networking/Model/NetworkingConfiguration.swift), which is the struct intended to be the only place where the API settings are configured.

The properties configurable from there are:

- `useSecureConnection: Bool`: `true` for `https` and `false` for `http`. In case this is disabled, the proper exception must be added to `Info.plist` file in the project.
- `domainURL: String`: API domain.
- `port: String`: API port.
- `subdomainURL: String`: API subdomain (optional parameter). This URL must start with `/` as required by `URLComponents`.
- `usePinningCertificate: Bool`: enables SSL Pinning (false by default) (see next section).

### Enable SSL Pinning

If enabling SSL pinning a valid `.der` certificate must be provided. It needs to be added to the project and be present in "copy bundle resources" phase. The framework will automatically look for any certificate provided in bundle and use it.

### Session manager

The framework provides a [SessionManager](Networking/Services/SessionManager.swift) intended to manage the current session. It also stores the user session exposing a way to update it whenever the user logs in, logs out, updates and expires. These transitions are expected to be handled outside the framework, but always letting SessionManager know about them.

When a user is logged in or signed up, `login:` must be called providing the fetched user. This will make `SessionManager` know a valid session is being used, and the session token will be injected in every request for authentication.

The same way, when the user is logged out, `logout` must be called. This will make `SessionManager` remove the stored session token, and every request will return a `RepositoryError.unauthenticatedSession`.

The function `update:` receiving a user can be useful to make `SessionManager` store an updated `User`.

### Storing a User

`SessionManager` can provide the current user reading the property `currentUser`. This property is set when `bootstrapSession` is called, which must be called only once. 

This function fetches the current user if an instance of [CurrentUserFetcherType](Networking/Repository/CurrentUserFetcherType.swift) is provided. Since the user is not persisted in the device, and only stored in memory the user needs to be fetched every time the application is launched.

### Enable `AlamofireNetworkActivityLogger`

`AlamofireNetworkActivityLogger` (see [AlamofireNetworkActivityLogger](https://github.com/konkab/AlamofireNetworkActivityLogger)) can be enabled by doing `NetworkActivityLogger.shared.startLogging()`. This will log in the console every request and response made depending on the `logLevel`, which can be selected by assigning the property `NetworkActivityLogger.shared.level` with a value of `NetworkActivityLoggerLevel`. By default, it enables it in debug.

Check [NetworkingDemoLauncher](NetworkingDemo/NetworkingDemoLauncher.swift) for an example.

### Enable `NetworkActivityIndicatorManager`

`NetworkActivityIndicatorManager` (see [NetworkActivityIndicatorManager](https://github.com/Alamofire/AlamofireNetworkActivityIndicator)) is available to be enabled directly by doing `NetworkActivityIndicatorManager.shared.isEnabled = true` to automatically mananger the visibility of the network activity indicator.

Check [NetworkingDemoLauncher](NetworkingDemo/NetworkingDemoLauncher.swift) for an example.

## Bootstrap
```
git clone git@github.com:Wolox/wolmo-networking-ios.git
cd wolmo-networking-ios
script/bootstrap
```

## Contributing
1. Fork it
2. [Bootstrap](#bootstrap) using the forked repository (instead of `Wolox/wolmo-networking-ios.git`, `your-user/wolmo-networking-ios.git`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Run tests (`./script/test`)
6. Push your branch (`git push origin my-new-feature`)
7. Create a new Pull Request

## About

This project is maintained by [Pablo Giorgi](https://github.com/pablog) and it is written by [Wolox](http://www.wolox.com.ar).

![Wolox](https://raw.githubusercontent.com/Wolox/press-kit/master/logos/logo_banner.png)

## License
**WolMo - Core iOS** is available under the MIT [license](LICENSE.txt).

    Copyright (c) 2016 Pablo Giorgi <pablo.giorgi@wolox.com.ar>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
