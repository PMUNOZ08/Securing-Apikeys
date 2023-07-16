
# Securing Apikeys

This repository is part of NSCoder Night Madrid Talk "Securing Apikeys using Cloudkit".

The repository include:

- Talk Slides.
- Initial Project
- Final Project

The sample project is a simple app that uses an api service to show a grid with pictures. It present a picture on full screen when is selected and allow to make a mask with de logo of NSCoder Night Madrid
The app can be tested on iPhone, iPad, AppleTv o Mac



## Usage/Examples

The api used is [unsplash](https://unsplash.com)
In order to test sample projects yout need an access key. Your can register an create anew one in [Join Unsplash](https://unsplash.com/join)

To test initial project just replace the placeholder in class UnplashClient:

```swift
private let apikey_unsplash = "UNSPLASH ACCESS KEY"
```

To test final sample project, the slides information maybe is useful:

- You must create a container in CloudKit
- Create a new record type. Named it "ApiKeys"
- Add a field to new record type created. Named it "unplash"
- Add a new recor with your api unsplash access key.

After this steps you must replace this  with real values in class ApiKeyManager:

```swift
let ckRecordId = "CLOUDKIT RECORD ID"

```



## License

[MIT](https://choosealicense.com/licenses/mit/)


## Authors

- [@pmunoz08](https://www.github.com/pmunoz08)


## 🚀 About Me
I'm a iOS, tvOS and MacOS freelance developer since 2011

