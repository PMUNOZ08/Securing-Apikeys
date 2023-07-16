
# Securing Apikeys

[![Swift Version][swift-image]][swift-url]
![platforms]
[![License][license-image]][license-url]


This repository is part of NSCoder Night Madrid Talk "Securing Apikeys using Cloudkit".

The repository include:

- Talk Slides.
- Initial Project
- Final Project

The sample project is a simple app that uses an api service to show a grid with pictures. It present a picture on full screen when is selected and allow to make a mask with de logo of NSCoder Night Madrid
The app can be tested on iPhone, iPad, AppleTv o Mac



## Usage

The api used is [unsplash](https://unsplash.com)
In order to test sample projects yout need an access key. Your can register and create a free new one on [Join Unsplash](https://unsplash.com/join)

To test initial project just replace the placeholder in class UnplashClient:

```swift
private let apikey_unsplash = "UNSPLASH ACCESS KEY"
```

To test final sample project, the slides information maybe is useful:

- You must create a container in CloudKit
- Create a new record type. Named it "ApiKeys"
- Add a field to new record type created. Named it "unplash"
- Add a new record with your api unsplash access key.

After this steps you must replace this  with real values in class ApiKeyManager:

```swift
let ckRecordId = "CLOUDKIT RECORD ID"

```


## Screenshots
![Alt text](/screenshots/screenshot1.png?raw=true)
![Alt text](/screenshots/screenshot2.png?raw=true)
![Alt text](/screenshots/screenshot3.png?raw=true)




## License

[MIT](https://choosealicense.com/licenses/mit/)


## Authors

- [@pmunoz08](https://www.github.com/pmunoz08)


## 🚀 About Me
I'm a iOS, tvOS and MacOS freelance developer since 2011

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[platforms]: https://img.shields.io/badge/platforms-iOS%20tvOS%20MacOS-oreen
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE

